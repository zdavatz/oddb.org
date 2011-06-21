#!/usr/bin/env ruby
# ODDB::TestYamlExporter -- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com
# ODDB::TestYamlExporter -- oddb.org -- 02.09.2003 -- rwaltert@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'plugin/yaml'
require 'util/today'
require 'util/logfile'

module ODDB
  class TestYamlExporter < Test::Unit::TestCase
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
      flexmock(@app, :companies => 'companies')
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
    def test_export_interactions
      substance = flexmock('substance', :substrate_connections => {'key' => 'value'})
      flexmock(@app, :substances => [substance])
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do 
        assert_equal('export_yaml', @plugin.export_interactions)
      end
    end
    def test_export_narcotics
      flexmock(@app, :narcotics => {'key' => 'value'})
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do 
        assert_equal('export_yaml', @plugin.export_narcotics)
      end
    end
    def test_export_patinfos
      flexmock(@app, :patinfos => {'key' => 'value'})
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do 
        assert_equal('export_yaml', @plugin.export_patinfos)
      end
    end
    def test_export_prices
      package = flexmock('package', :prices => {'key' => 'price'})
      flexmock(@app, :packages => [package])
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do 
        assert_equal('export_yaml', @plugin.export_prices)
      end
    end
    def test_check_fachinfos
      fachinfo = flexmock('fachinfo', 
                          :descriptions => 'descriptions',
                          :iksnrs       => ['iksnr'],
                          :company_name => 'company_name',
                          :name_base    => 'name_base'
                         )
      flexmock(ODBA.cache, :fetch => fachinfo)
      flexmock(@app, :fachinfos => {'key' => fachinfo})
      flexmock(Log).new_instances do |log|
        log.should_receive(:report=)
        log.should_receive(:notify).and_return('notify')
      end
      expected = {"fr" => [["company_name", "name_base", "iksnr"]], "de" => []}
      assert_equal(expected, @plugin.check_fachinfos)
    end
    def test_export_fachinfos
      fachinfo = flexmock('fachinfo', 
                          :descriptions => 'descriptions',
                          :iksnrs       => ['iksnr'],
                          :company_name => 'company_name',
                          :name_base    => 'name_base'
                         )
      flexmock(ODBA.cache, :fetch => fachinfo)
      flexmock(@app, :fachinfos => {'key' => fachinfo})
      flexmock(Log).new_instances do |log|
        log.should_receive(:report=)
        log.should_receive(:notify).and_return('notify')
      end
      replace_constant('ODDB::YamlExporter::EXPORT_SERVER', @server) do 
        assert_equal('export_yaml', @plugin.export_fachinfos)
      end
    end
  end
end # ODDB

