#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestCsvExportPlugin -- oddb.org -- 19.01.2012 -- mhatakeyama@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'drb/drb'
require 'plugin/csv_export'
require 'plugin/plugin'
require 'util/session'

module ODDB
  class TestCsvExportPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @app    = flexmock('app')
      @plugin = ODDB::CsvExportPlugin.new(@app)
    end
    def test_report
      counts = {'key', 12345}
      @plugin.instance_eval('@counts = counts')
      expected = "key                              12345\n"
      assert_equal(expected, @plugin.report)
    end
    def test_log_info
      @plugin.instance_eval do
        @file_path = 'file_path'
        @options   = {}
        @options[:compression] = 'compsression'
        @options[:iconv] = 'iconv'
      end
      expected = {:report => "", :files => {"file_path.compsression" => ["application/compsression", "iconv"]}, :recipients => [], :change_flags => {}}
      assert_equal(expected, @plugin.log_info)
    end
    def temporary_replace_constant(object, const, replace)
      require 'tempfile'
      $stderr = Tempfile.new('stderr')
      temp = nil
      object.instance_eval("temp = #{const}; #{const} = replace")
      yield
      object.instance_eval("#{const} = temp")
      $stderr.close
      $stderr = STDERR
    end
    def test_export_price_history
      export_server = flexmock('export_server', :export_price_history_csv => 'export_price_history_csv')
      package = flexmock('package', 
                         :has_price? => true,
                         :odba_id    => 123
                        )
      flexmock(@app, :packages => [package])
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do 
        assert_equal('export_price_history_csv', @plugin.export_price_history)
      end
    end
    def test_export_migel
      migel_product = flexmock('migel_product', 
                               :migel_code => 123,
                               :odba_id    => 123
                              )
      flexmock(@app, :migel_products => [migel_product])
      export_server = flexmock('export_server', :export_migel_csv => 'export_migel_csv')
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        assert_equal('export_migel_csv', @plugin.export_migel)
      end
    end
    def test_export_index_therapeuticus
      index   = flexmock('index', :odba_id => 123)
      package = flexmock('package', 
                         :ikskey  => 123,
                         :odba_id => 123
                        )
      flexmock(@app, 
               :indices_therapeutici => {'code' => index},
               :packages => [package]
              )
      export_server = flexmock('export_server', 
                               :export_idx_th_csv => 'export_idx_th_csv',
                               :export_ean13_idx_th_csv => 'export_ean13_idx_th_csv',
                               :compress_many => 'compress_many'
                              )
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        assert_equal('compress_many', @plugin.export_index_therapeuticus)
      end
    end
    def test_export_doctors
      doctor = flexmock('doctor', :odba_id => 'odba_id')
      flexmock(@app, :doctors => {'key' => doctor})
      export_server = flexmock('export_server', :export_doc_csv => 'export_doc_csv')
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        assert_equal('export_doc_csv', @plugin.export_doctors)
      end
    end
    def test_export_analysis
      position = flexmock('position', 
                          :code    => 123,
                          :odba_id => 123
                         )
      flexmock(@app, :analysis_positions => [position])
      export_server = flexmock('export_server', :export_analysis_csv => 'export_analysis_csv')
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        assert_equal('export_analysis_csv', @plugin.export_analysis)
      end
    end
    def test__export_drugs
      flexmock(FileUtils, 
               :mkdir_p => nil,
               :cp      => 'cp'
              )
      package   = flexmock('package', 
                           :ikskey => 123,
                           :keys   => 'keys'
                          )
      atc_class = flexmock('atc_class', 
                           :code => 123,
                           :description => 'description',
                           :packages => [package]
                          )
      log_group = flexmock('log_group', :newest_date => Time.local(2011,2,3))
      flexmock(@app, 
               :atc_classes => {'key' => atc_class},
               :log_group   => log_group
              )
      export_server = flexmock('export_server', :compress => 'compress')
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        assert_equal('cp', @plugin._export_drugs('export_name', 'keys'))
      end
    end
    def test__export_drugs__dups_empty
      flexmock(Log).new_instances do |l|
        l.should_receive(:report=)
        l.should_receive(:notify).and_return('notify')
      end
      flexmock(ODDB::View::Drugs::CsvResult).new_instances do |r|
        r.should_receive(:to_csv_file)
        r.should_receive(:duplicates).and_return(['csv_result'])
      end
      flexmock(FileUtils, 
               :mkdir_p => nil,
               :cp      => 'cp'
              )
      package   = flexmock('package', 
                           :ikskey => 123,
                           :keys   => 'keys'
                          )
      atc_class = flexmock('atc_class', 
                           :code => 123,
                           :description => 'description',
                           :packages => [package]
                          )
      log_group = flexmock('log_group', :newest_date => Time.local(2011,2,3))
      flexmock(@app, 
               :atc_classes => {'key' => atc_class},
               :log_group   => log_group
              )
      export_server = flexmock('export_server', :compress => 'compress')
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        assert_equal('cp', @plugin._export_drugs('export_name', 'keys'))
      end
    end
    def stdout_null
      require 'tempfile'
      $stdout = Tempfile.open('stdout')
      yield
      $stdout.close
      $stdout = STDERR
    end
    def test__export_drugs__error
      flexmock(FileUtils, 
               :mkdir_p => nil,
               :cp      => 'cp'
              )
      package   = flexmock('package', 
                           :ikskey => 123,
                           :keys   => 'keys'
                          )
      atc_class = flexmock('atc_class', 
                           :code => 123,
                           :description => 'description',
                           :packages => [package]
                          )
      log_group = flexmock('log_group', :newest_date => Time.local(2011,2,3))
      flexmock(@app, 
               :atc_classes => {'key' => atc_class},
               :log_group   => log_group
              )
      export_server = flexmock('export_server') do |e|
        e.should_receive(:compress).and_raise(StandardError)
      end
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        stdout_null do 
          assert_raise(StandardError) do 
            @plugin._export_drugs('export_name', 'keys')
          end
        end
      end
    end
    def test_export_drugs
      flexmock(FileUtils, 
               :mkdir_p => nil,
               :cp      => 'cp'
              )
      limitation_text = flexmock('limitation_text', :de => 'de')
      sl_entry  = flexmock('sl_entry', 
                           :bsv_dossier => 'bsv_dossier',
                           :limitation  => 'limitation',
                           :introduction_date => Time.local(2011,2,3),
                           :limitation_points => 'limitation_points',
                           :limitation_text   => limitation_text
                          )
      galenic_form = flexmock('galenic_form', :description => 'description')
      commercial_form = flexmock('commercial_form', :de => 'de')
      part      = flexmock('part', 
                           :multi => 'multi',
                           :count => 'count',
                           :measure => 'measure',
                           :commercial_form => commercial_form
                          )
      comparable_size = flexmock('comparable_size', :qty => 'qty')
      package   = flexmock('package',
                           :ikskey => 123,
                           :keys   => 'keys',
                           :iksnr  => 123,
                           :ikscd  => 123,
                           :parts  => [part],
                           :ikscat => 'ikscat',
                           :lppv   => 'lppv',
                           :barcode    => 'barcode',
                           :sl_entry   => sl_entry,
                           :pharmacode => 'pharmacode',
                           :name_base  => 'name_base',
                           :deductible => :generics,
                           :public?    => nil,
                           :narcotic?  => nil,
                           :vaccine    => 'vaccine',
                           :galenic_forms     => [galenic_form],
                           :most_precise_dose => 'most_precise_dose',
                           :comparable_size   => comparable_size,
                           :price_exfactory   => 'price_exfactory',
                           :price_public      => 'price_public',
                           :company_name      => 'company_name',
                           :registration_date => Time.local(2011,2,3),
                           :expiration_date   => Time.local(2011,2,3),
                           :inactive_date     => Time.local(2011,2,3),
                           :export_flag       => 'export_flag',
                           :sl_generic_type   => 'sl_generic_type',
                           :has_generic?      => nil,
                           :ith_swissmedic    => 'ith_swissmedic',
                           :complementary_type  => :generics,
                           :index_therapeuticus => 'index_therapeuticus',
                           :renewal_flag_swissmedic => 'renewal_flag_swissmedic'
                          )
      atc_class = flexmock('atc_class', 
                           :code => 123,
                           :description => 'description',
                           :packages => [package]
                          )
      log_group = flexmock('log_group', :newest_date => Time.local(2011,2,3))
      flexmock(@app, 
               :atc_classes => {'key' => atc_class},
               :log_group   => log_group
              )
      export_server = flexmock('export_server', :compress => 'compress')
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        assert_equal('cp', @plugin.export_drugs)
      end
    end
    def test_export_drugs_extended
      flexmock(FileUtils, 
               :mkdir_p => nil,
               :cp      => 'cp'
              )
      limitation_text = flexmock('limitation_text', :de => 'de')
      galenic_form    = flexmock('galenic_form', :description => 'description')
      galenic_group   = flexmock('galenic_group', 
                                 :de          => 'de',
                                 :description => 'description'
                                )
      commercial_form = flexmock('commercial_form', :de => 'de')
      sl_entry  = flexmock('sl_entry', 
                           :bsv_dossier => 'bsv_dossier',
                           :limitation  => 'limitation',
                           :introduction_date => Time.local(2011,2,3),
                           :limitation_points => 'limitation_points',
                           :limitation_text   => limitation_text
                          )
      part      = flexmock('part', 
                           :multi => 'multi',
                           :count => 'count',
                           :measure => 'measure',
                           :commercial_form => commercial_form
                          )
      package   = flexmock('package', 
                           :ikskey  => 123,
                           :keys    => 'keys',
                           :iksnr   => 123,
                           :ikscd   => 123,
                           :barcode => 'barcode',
                           :size    => 'size', 
                           :ikscat  => 'ikscat', 
                           :lppv    => 'lppv', 
                           :casrn   => 'casrn', 
                           :c_type  => :generics, 
                           :parts   => [part],
                           :public? => nil,
                           :sl_entry     => sl_entry, 
                           :bsv_dossier  => 'bsv_dossier', 
                           :pharmacode   => 'pharmacode', 
                           :limitation   => 'limitation', 
                           :price_public => 'price_public', 
                           :company_name => :generics, 
                           :export_flag  => 'export_flag', 
                           :generic_type => 'generic_type', 
                           :has_generic  => 'has_generic', 
                           :deductible   => :generics, 
                           :out_of_trade => 'out_of_trade', 
                           :name_base    => 'name_base',
                           :galenic_forms     => [galenic_form],
                           :inactive_date     => Time.local(2011,2,3), 
                           :galenic_form_de   => 'galenic_form_de', 
                           :galenic_form_fr   => 'galenic_form_fr', 
                           :most_precise_dose => 'most_precise_dose', 
                           :price_exfactory   => 'price_exfactory', 
                           :introduction_date => Time.local(2011,2,3), 
                           :limitation_points => 'limitation_points', 
                           :limitation_text   => 'limitation_text', 
                           :registration_date => Time.local(2011,2,3), 
                           :expiration_date   => Time.local(2011,2,3),
                           :sl_generic_type   => 'sl_generic_type',
                           :has_generic?      => nil,
                           :galenic_group     => galenic_group, 
                           :galenic_group_de  => 'galenic_group_de', 
                           :galenic_group_fr  => 'galenic_group_fr',
                           :complementary_type      => :generics,
                           :numerical_size_extended => 'numerical_size_extended', 
                           :route_of_administration => 'route_of_administration'
                          )
      atc_class = flexmock('atc_class', 
                           :code => 123,
                           :description => 'description',
                           :packages => [package]
                          )
      log_group = flexmock('log_group', :newest_date => Time.local(2011,2,3))
      flexmock(@app, 
               :atc_classes => {'key' => atc_class},
               :log_group   => log_group
              )
      export_server = flexmock('export_server', :compress => 'compress')
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        assert_equal('cp', @plugin.export_drugs_extended)
      end
    end
  end
end
