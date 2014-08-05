#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestYamlExporter -- oddb.org -- 22.11.2012 -- yasaka@ywesee.com
# ODDB::TestYamlExporter -- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com
# ODDB::TestYamlExporter -- oddb.org -- 02.09.2003 -- rwaltert@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'plugin/yaml'
require 'util/today'
require 'util/logfile'

module ODDB
  @@today = Date.new(2014,7,8)
  class TestYamlExporter <Minitest::Test
    include FlexMock::TestCase
    def stderr_null
      require 'tempfile'
      $stderr = Tempfile.open('stderr')
      yield
      $stderr.close
      $stderr = STDERR
    end
    def replace_constant(constant, temp)
      stderr_null do
        keep = eval constant
        eval "#{constant} = temp"
        yield
        eval "#{constant} = keep"
      end
    end
    def setup
      @app    = flexmock('app')
      @server = flexmock('server', :export_yaml => 'export_yaml')
      @plugin = ODDB::YamlExporter.new(@app)
    end
    def test_export_array
      array = ['item']
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        assert_equal('export_yaml', @plugin.export_array('name', array))
      end
    end
    def test_export_obj
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        assert_equal('export_yaml', @plugin.export_obj('name', 'obj'))
      end
    end
    def test_export
      flexmock(@app, :companies => {'key' => 'companies'})
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        assert_equal('export_yaml', @plugin.export)
      end
    end
    def test_export_atc_classes
      atc = flexmock('atc', :code => 'code')
      flexmock(@app, :atc_classes => {'key' => atc})
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        assert_equal('export_yaml', @plugin.export_atc_classes)
      end
    end
    def test_export_doctors
      flexmock(@app, :doctors => {'key' => 'doctors'})
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        assert_equal('export_yaml', @plugin.export_doctors)
      end
    end
    def test_export_galenic_forms
      flexmock(@app, :galenic_forms => {'key' => 'galenic_forms'})
      skip "Don't know how to stub each_galenic_form"
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        assert_equal('export_yaml', @plugin.export_galenic_forms)
      end
    end
    def test_export_galenic_groups
      flexmock(@app, :galenic_groups => {'key' => 'galenic_groups'})
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        assert_equal('export_yaml', @plugin.export_galenic_groups)
      end
    end
    def test_export_interactions
      epha_interaction = flexmock('epha_interaction', :atc_code_self => 'atc_code_self')
      flexmock(@app, :epha_interactions => [epha_interaction])
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        assert_equal('export_yaml', @plugin.export_interactions)
      end
    end
    def test_check_infos__valid_fachinfo
      fachinfo = flexmock('fachinfo',
                          :descriptions => {'de' => 'description', 'fr' => 'description'},
                          :iksnrs       => ['iksnr'],
                          :company_name => 'company_name',
                          :name_base    => 'name_base'
                         )
      flexmock(@app, :fachinfos => {'key' => fachinfo})
      # no warning
      flexmock(Log).new_instances do |log|
        log.should_receive(:report=).never
        log.should_receive(:notify).and_return('notify').never
      end
      result = @plugin.check_infos('fachinfo.yaml', 'Registration') do |no_descr, valid_infos|
        @app.fachinfos.values.each do |fachinfo|
          no_descr.keys.each do |language|
            unless fachinfo.descriptions[language]
              no_descr[language].push(
                [fachinfo.company_name, fachinfo.name_base].concat(fachinfo.iksnrs)
              )
            end
          end
        end
      end
      assert_empty(result)
    end
    def test_check_infos__no_descr_fachinfo
      fachinfo = flexmock('fachinfo',
                          :descriptions => {'de' => 'description', 'fr' => ''},
                          :iksnrs       => ['iksnr'],
                          :company_name => 'company_name',
                          :name_base    => 'name_base'
                         )
      flexmock(@app, :fachinfos => {'key' => fachinfo})
      # warn empty description
      flexmock(Log).new_instances do |log|
        log.should_receive(:report=)
        log.should_receive(:notify).and_return('notify')
      end
      result = @plugin.check_infos('fachinfo.yaml', 'Registration') do |no_descr, valid_infos|
        @app.fachinfos.values.each do |fachinfo|
          no_descr.keys.each do |language|
            unless fachinfo.descriptions[language]
              no_descr[language].push(
                [fachinfo.company_name, fachinfo.name_base].concat(fachinfo.iksnrs)
              )
            end
          end
        end
      end
      assert_empty(result)
    end
    def test_export_patinfos__no_descr_patinfo
      registration = flexmock('registration', :iksnr => 'iksnr')
      sequence = flexmock('sequence',
                          :registration => registration,
                          :seqnr        => 'seqnr',
                         )
      patinfo = flexmock('patinfo',
                         :odba_id      => 1,
                         :descriptions => {'fr' => ''},
                         :sequences    => [sequence],
                         :company_name => 'company_name',
                         :name_base    => 'name_base',
                        )
      flexmock(ODBA.cache, :fetch => patinfo)
      flexmock(@app, :effective_patinfos => [patinfo])
      # warn empty description
      flexmock(Log).new_instances do |log|
        log.should_receive(:report=)
        log.should_receive(:notify).and_return('notify')
      end
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        assert_equal('export_yaml', @plugin.export_patinfos)
      end
    end
    def test_export_patinfos__valid_patinfo
      patinfo  = flexmock('patinfo',
                          :odba_id      => 1,
                          :descriptions => {'de' => 'description', 'fr' => 'description'},
                          :sequences    => ['sequence'],
                         )
      flexmock(ODBA.cache, :fetch => patinfo)
      flexmock(@app, :effective_patinfos => [patinfo])
      # no warning
      flexmock(Log).new_instances do |log|
        log.should_receive(:report=).never
        log.should_receive(:notify).and_return('notify').never
      end
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        assert_equal('export_yaml', @plugin.export_patinfos)
      end
    end
    def test_export_effective_patinfos__no_descr_patinfo
      registration = flexmock('registration', :iksnr => 'iksnr')
      sequence = flexmock('sequence',
                          :registration => registration,
                          :seqnr        => 'seqnr',
                         )
      patinfo = flexmock('patinfo',
                         :odba_id      => 1,
                         :descriptions => {'de' => nil, 'fr' => nil},
                         :sequences    => [sequence],
                         :company_name => 'company_name',
                         :name_base    => 'name_base',
                        )
      flexmock(ODBA.cache, :fetch => patinfo)
      flexmock(@app, :effective_patinfos => [patinfo])
      # warn empty description
      flexmock(Log).new_instances do |log|
        log.should_receive(:report=)
        log.should_receive(:notify).and_return('notify')
      end
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        assert_equal('export_yaml', @plugin.export_effective_patinfos)
      end
    end
    def test_export_effective_patinfos__valid_patinfo
      patinfo  = flexmock('patinfo',
                          :odba_id      => 1,
                          :descriptions => {'de' => 'description', 'fr' => 'description'},
                          :sequences    => ['sequence'],
                         )
      flexmock(ODBA.cache, :fetch => patinfo)
      flexmock(@app, :effective_patinfos => [patinfo])
      # no warning
      flexmock(Log).new_instances do |log|
        log.should_receive(:report=).never
        log.should_receive(:notify).and_return('notify').never
      end
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        assert_equal('export_yaml', @plugin.export_effective_patinfos)
      end
    end
    def test_export_effective_patinfos__skip_unexpected_patinfo
      patinfo  = flexmock('patinfo',
                          :odba_id      => 1,
                          :descriptions => {'de' => nil, 'fr' => 'description'},
                          :sequences    => ['invalid seqence', nil]
                         )
      flexmock(ODBA.cache, :fetch => patinfo)
      flexmock(@app, :effective_patinfos => [patinfo])
      # no warning
      flexmock(Log).new_instances do |log|
        log.should_receive(:report=)
        log.should_receive(:notify).and_return('notify')
      end
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        @plugin.export_effective_patinfos
      end
    end
    def test_export_fachinfos__no_descr_fachinfo
      fachinfo = flexmock('fachinfo',
                          :descriptions => {},
                          :iksnrs       => ['iksnr'],
                          :company_name => 'company_name',
                          :name_base    => 'name_base'
                         )
      flexmock(ODBA.cache, :fetch => fachinfo)
      flexmock(@app, :fachinfos => {'key' => fachinfo})
      # warn empty description
      flexmock(Log).new_instances do |log|
        log.should_receive(:report=)
        log.should_receive(:notify).and_return('notify')
      end
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        assert_equal('export_yaml', @plugin.export_fachinfos)
      end
    end
    def test_export_fachinfos__valid_fachinfo
      fachinfo = flexmock('fachinfo',
                          :descriptions => {'de' => 'description', 'fr' => 'description'},
                          :iksnrs       => ['iksnr'],
                          :company_name => 'company_name',
                          :name_base    => 'name_base'
                         )
      flexmock(@app, :fachinfos => {'key' => fachinfo})
      # no warning
      flexmock(Log).new_instances do |log|
        log.should_receive(:report=).never
        log.should_receive(:notify).and_return('notify').never
      end
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        assert_equal('export_yaml', @plugin.export_fachinfos)
      end
    end
    def test_export_effective_fachinfos__no_descr_fachinfo
      fachinfo = flexmock('fachinfo',
                          :odba_id      => 1,
                          :descriptions => {'de' => nil},
                          :iksnrs       => ['iksnr'],
                          :company_name => 'company_name',
                          :name_base    => 'name_base'
                         )
      flexmock(ODBA.cache, :fetch => fachinfo)
      flexmock(@app, :effective_fachinfos => [fachinfo])
      # warn empty description
      flexmock(Log).new_instances do |log|
        log.should_receive(:report=)
        log.should_receive(:notify).and_return('notify')
      end
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        assert_equal('export_yaml', @plugin.export_effective_fachinfos)
      end
    end
    def test_export_effective_fachinfos__valid_fachinfo
      fachinfo = flexmock('fachinfo',
                          :descriptions => {'de' => 'description', 'fr' => 'description'},
                          :iksnrs       => ['iksnr'],
                          :company_name => 'company_name',
                          :name_base    => 'name_base'
                         )
      flexmock(@app, :effective_fachinfos => [fachinfo])
      # no warning
      flexmock(Log).new_instances do |log|
        log.should_receive(:report=).never
        log.should_receive(:notify).and_return('notify').never
      end
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        assert_equal('export_yaml', @plugin.export_effective_fachinfos)
      end
    end
    def test_export_prices
      package = flexmock('package', :prices => {'key' => 'price'})
      flexmock(@app, :packages => [package])
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do
        assert_equal('export_yaml', @plugin.export_prices)
      end
    end
  end
end # ODDB
