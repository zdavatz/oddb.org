#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestCsvExportPlugin -- oddb.org -- 17.10.2012 -- yasaka@ywesee.com
# ODDB::TestCsvExportPlugin -- oddb.org -- 19.01.2012 -- mhatakeyama@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'stub/odba'
require 'minitest/autorun'
require 'flexmock/minitest'
require 'drb/drb'
require 'plugin/plugin'
require 'plugin/csv_export'
require 'test_plugin/plugin'
require 'view/drugs/csv_result'
require 'util/log'
require 'util/workdir'
require 'model/galenicgroup'

module ODDB
  class TestCsvExportPlugin <Minitest::Test
    def setup
      FileUtils.rm_rf(ODDB::WORK_DIR)
#      FileUtils.cp(File.join(ODDB::TEST_DATA_DIR, 'csv/*.csv'), File.mo)
      @app    = flexmock('app')
      @plugin = ODDB::CsvExportPlugin.new(@app)
    end
    def stdout_null
      require 'tempfile'
      $stdout = Tempfile.open('stdout')
      yield
      $stdout.close
      $stdout = STDERR
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
    def test_report
      counts = {'key' => 12345}
      @plugin.instance_eval('@counts = counts')
      time   = 60 * 15
      @plugin.instance_eval('@time = time')
      expected = "key:                             12345\n" \
                 "\n" \
                 "Duration:                        15 min.\n"
      assert_equal(expected, @plugin.report)
    end
    def test_log_info
      @plugin.instance_eval do
        @file_path = 'file_path'
        @options   = {}
        @options[:compression] = 'compsression'
      end
      expected = {:change_flags => {}, :report => "", :recipients => [], :files => {"file_path.compsression" => "application/compsression"}}
      assert_equal(expected, @plugin.log_info)
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
                               :export_idx_th_csv       => 'export_idx_th_csv',
                               :export_ean13_idx_th_csv => 'export_ean13_idx_th_csv',
                               :compress_many           => 'compress_many'
                              )
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        @plugin.instance_eval('@options = {}')
        assert_equal('compress_many', @plugin.export_index_therapeuticus)
      end
    end
    def test_export_index_therapeuticus_nil_package
      index   = flexmock('index', :odba_id => 123)
      package = nil
      flexmock(@app,
               :indices_therapeutici => {'code' => index},
               :packages => [package]
              )
      export_server = flexmock('export_server',
                               :export_idx_th_csv       => 'export_idx_th_csv',
                               :export_ean13_idx_th_csv => 'export_ean13_idx_th_csv',
                               :compress_many           => 'compress_many'
                              )
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        @plugin.instance_eval('@options = {}')
        assert_equal('compress_many', @plugin.export_index_therapeuticus)
      end
    end
    def test_export_index_therapeuticus_nil_package
      index   = flexmock('index', :odba_id => 123)
      package = nil
      flexmock(@app,
               :indices_therapeutici => {'code' => index},
               :packages => [package]
              )
      export_server = flexmock('export_server',
                               :export_idx_th_csv       => 'export_idx_th_csv',
                               :export_ean13_idx_th_csv => 'export_ean13_idx_th_csv',
                               :compress_many           => 'compress_many'
                              )
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        @plugin.instance_eval('@options = {}')
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
    def test__export_drugs
      flexmock(FileUtils,
               :mkdir_p => nil,
               :cp      => 'cp'
              )
      package   = flexmock('package',
                           :ikskey          => 123,
                           :keys            => 'keys',
                           :sl_generic_type => :original,
                           :export_flag     => 1,
                          )
      atc_class = flexmock('atc_class',
                           :code        => 123,
                           :description => 'description',
                           :packages    => [package]
                          )
      log_group = flexmock('log_group', :newest_date => Time.local(2011,2,3))
      flexmock(@app,
               :atc_classes => {'key' => atc_class},
               :log_group   => log_group
              )
      export_server = flexmock('export_server', :compress => 'compress')
      
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        @plugin.instance_eval('@options = {}')
        assert_equal('cp', @plugin._export_drugs('export_name', [:generic_type, :export_flag]))
        assert_equal(1,    @plugin.instance_eval("@counts['originals']"))
        assert_equal(1,    @plugin.instance_eval("@counts['export_registrations']"))
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
                           :code        => 123,
                           :description => 'description',
                           :packages    => [package, nil]
                          )
      log_group = flexmock('log_group', :newest_date => Time.local(2011,2,3))
      flexmock(@app,
               :atc_classes => {'key' => atc_class},
               :log_group   => log_group
              )
      export_server = flexmock('export_server', :compress => 'compress')
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        @plugin.instance_eval('@options = {}')
        assert_equal('cp', @plugin._export_drugs('export_name', ['keys']))
        assert_equal([0],  @plugin.instance_eval('@counts.values.uniq'))
      end
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
        @plugin.instance_eval('@options = {}')
        stdout_null do
          assert_raises(StandardError) do
            @plugin._export_drugs('export_name', ['keys'])
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
                           :bsv_dossier       => 'bsv_dossier',
                           :limitation        => 'limitation',
                           :introduction_date => Time.local(2011,2,3),
                           :limitation_points => 'limitation_points',
                           :limitation_text   => limitation_text
                          )
      galenic_form = flexmock('galenic_form', :description => 'description')
      commercial_form = flexmock('commercial_form', :de => 'de')
      part      = flexmock('part',
                           :multi           => 'multi',
                           :count           => 'count',
                           :measure         => 'measure',
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
                           :code        => 123,
                           :description => 'description',
                           :packages    => [package, nil]
                          )
      log_group = flexmock('log_group', :newest_date => Time.local(2011,2,3))
      flexmock(@app,
               :atc_classes => {'key' => atc_class},
               :log_group   => log_group
              )
      export_server = flexmock('export_server', :compress => 'compress')
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        @plugin.instance_eval('@options = {}')
        assert_equal('cp', @plugin.export_drugs)
        assert_equal(1,    @plugin.instance_eval("@counts['galenic_forms']"))
        assert_equal(1,    @plugin.instance_eval("@counts['limitations']"))
        assert_equal(0,    @plugin.instance_eval("@counts['originals']"))
      end
    end
    def test_export_drugs_sl_entry_nil
      flexmock(FileUtils,
               :mkdir_p => nil,
               :cp      => 'cp'
              )
      limitation_text = flexmock('limitation_text', :de => 'de')
      galenic_form = flexmock('galenic_form', :description => 'description')
      commercial_form = flexmock('commercial_form', :de => 'de')
      part      = flexmock('part',
                           :multi           => 'multi',
                           :count           => 'count',
                           :measure         => 'measure',
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
                           :sl_entry   => nil,
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
                           :code        => 123,
                           :description => 'description',
                           :packages    => [package, nil]
                          )
      log_group = flexmock('log_group', :newest_date => Time.local(2011,2,3))
      flexmock(@app,
               :atc_classes => {'key' => atc_class},
               :log_group   => log_group
              )
      export_server = flexmock('export_server', :compress => 'compress')
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        @plugin.instance_eval('@options = {}')
        assert_equal('cp', @plugin.export_drugs)
        assert_equal(1,    @plugin.instance_eval("@counts['galenic_forms']"))
        assert_equal(0,    @plugin.instance_eval("@counts['limitations']"))
        assert_equal(0,    @plugin.instance_eval("@counts['originals']"))
      end
    end
    def test_export_drugs_sl_entry_nil
      flexmock(FileUtils,
               :mkdir_p => nil,
               :cp      => 'cp'
              )
      limitation_text = flexmock('limitation_text', :de => 'de')
      galenic_form = flexmock('galenic_form', :description => 'description')
      commercial_form = flexmock('commercial_form', :de => 'de')
      part      = flexmock('part',
                           :multi           => 'multi',
                           :count           => 'count',
                           :measure         => 'measure',
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
                           :sl_entry   => nil,
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
                           :code        => 123,
                           :description => 'description',
                           :packages    => [package, nil]
                          )
      log_group = flexmock('log_group', :newest_date => Time.local(2011,2,3))
      flexmock(@app,
               :atc_classes => {'key' => atc_class},
               :log_group   => log_group
              )
      export_server = flexmock('export_server', :compress => 'compress')
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        @plugin.instance_eval('@options = {}')
        assert_equal('cp', @plugin.export_drugs)
        assert_equal(1,    @plugin.instance_eval("@counts['galenic_forms']"))
        assert_equal(0,    @plugin.instance_eval("@counts['limitations']"))
        assert_equal(0,    @plugin.instance_eval("@counts['originals']"))
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
                           :bsv_dossier       => 'bsv_dossier',
                           :limitation        => 'limitation',
                           :introduction_date => Time.local(2011,2,3),
                           :limitation_points => 'limitation_points',
                           :limitation_text   => limitation_text
                          )
      part      = flexmock('part',
                           :multi           => 'multi',
                           :count           => 'count',
                           :measure         => 'measure',
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
                           :code        => 123,
                           :description => 'description',
                           :packages    => [package]
                          )
      log_group = flexmock('log_group', :newest_date => Time.local(2011,2,3))
      flexmock(@app,
               :atc_classes => {'key' => atc_class},
               :log_group   => log_group
              )
      export_server = flexmock('export_server', :compress => 'compress')
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        @plugin.instance_eval('@options = {}')
        assert_equal('cp', @plugin.export_drugs_extended)
        assert_equal(1,    @plugin.instance_eval("@counts['routes_of_administration']"))
        assert_equal(1,    @plugin.instance_eval("@counts['galenic_groups']"))
      end
    end
    def test_export_drugs_extended_nil_package
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
                           :bsv_dossier       => 'bsv_dossier',
                           :limitation        => 'limitation',
                           :introduction_date => Time.local(2011,2,3),
                           :limitation_points => 'limitation_points',
                           :limitation_text   => limitation_text
                          )
      part      = flexmock('part',
                           :multi           => 'multi',
                           :count           => 'count',
                           :measure         => 'measure',
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
                           :code        => 123,
                           :description => 'description',
                           :packages    => [package, nil]
                          )
      log_group = flexmock('log_group', :newest_date => Time.local(2011,2,3))
      flexmock(@app,
               :atc_classes => {'key' => atc_class},
               :log_group   => log_group
              )
      export_server = flexmock('export_server', :compress => 'compress')
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        @plugin.instance_eval('@options = {}')
        assert_equal('cp', @plugin.export_drugs_extended)
        assert_equal(1,    @plugin.instance_eval("@counts['routes_of_administration']"))
        assert_equal(1,    @plugin.instance_eval("@counts['galenic_groups']"))
      end
    end

    def test_export_fachinfo_chapter
      skip('test_export_fachinfo_chapter pending')
      # pending
    end
    def test_export_fachinfo_chapter__no_match
      skip('test_export_fachinfo_chapter__no_match pending')
      # pending
    end
    def test_export_oddb_dat
      flexmock(FileUtils,
               :mkdir_p => nil,
               :cp      => 'cp'
              )
      log_group = flexmock('log_group', :newest_date => Time.local(2011,2,3))
      flexmock(@app,
               :log_group => log_group
              )
      export_server = flexmock('export_server', :compress => 'compress')
      src = File.join(ODDB::TEST_DATA_DIR, 'csv/oddb.csv')
      assert(File.exist?(src), "#{src} must exist")
      dest = File.join(ODDB::EXPORT_DIR, 'oddb.csv')
      FileUtils.makedirs(ODDB::EXPORT_DIR)
      res = FileUtils.copy_file(src, dest, preserve: true, verbose: true)
      assert(File.exist?(dest), "#{dest} must exist")
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        @plugin.instance_eval('@options = {}')
        assert_equal('compress', @plugin.export_oddb_dat(nil))
      end
    end
    def test_export_oddb_dat_with_migel
      flexmock(FileUtils,
               :mkdir_p => nil,
               :cp      => 'cp'
              )
      log_group = flexmock('log_group', :newest_date => Time.local(2011,2,3))
      flexmock(@app,
               :log_group => log_group
              )
      export_server = flexmock('export_server', :compress => 'compress')
      export_dir = File.join(ODDB::TEST_DATA_DIR, 'csv')
      src = File.join(ODDB::TEST_DATA_DIR, 'csv/oddb.csv')
      assert(File.exist?(src), "#{src} must exist")
      dest = File.join(ODDB::EXPORT_DIR, 'oddb.csv')
      FileUtils.makedirs(ODDB::EXPORT_DIR)
      res = FileUtils.copy_file(src, dest, preserve: true, verbose: true)
      assert(File.exist?(dest), "#{dest} must exist")
      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::MIGEL_EXPORT_DIR', export_dir ) do
        temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
          @plugin.instance_eval('@options = {}')
          assert_equal('compress', @plugin.export_oddb_dat_with_migel(nil))
        end
      end
    end
    def test_export_teilbarkeit
      skip('test_export_fachinfo_chapter__no_match pending')
    end
    def test_export_flirkr_photo
      skip('test_export_fachinfo_chapter__no_match pending')
    end
    def test_export_ddd
     flexmock(FileUtils,
               :mkdir_p => nil,
               :cp      => 'cp'
              )
      log_group = flexmock('log_group', :newest_date => Time.local(2011,2,3))
      @package = ODDB::Package.new('02')
      @pharmacode = 123456
      @package.pharmacode= @pharmacode
      assert_equal(@pharmacode.to_s, @package.pharmacode.to_s)
      ddd = ODDB::AtcClass::DDD.new('O')
      ddd.dose = ODDB::Dose.new(95 , 'mg')
      atc = flexmock :has_ddd? => true, :ddds => { 'O' => ddd }, :code => 'C01DA02'
      gal_group =  ODDB::GalenicGroup.new
      gal_group.add(ODDB::GalenicForm.new)
      gal_group.route_of_administration = 'O'
      gal_group.galenic_forms.values.first.descriptions['de'] = 'Tabletten'
      seq = flexmock ODDB::Sequence.new('01'), :atc_class => atc,
                    :galenic_group => gal_group,
                    :galenic_forms => [gal_group.galenic_forms.values.first],
                    :dose => ODDB::Dose.new(125, 'mg'),
                    :name => 'seqname',
                    :longevity => nil
      @package.price_public = ODDB::Util::Money.new(103.4, 'CHF')
      @package.sequence = seq
      assert_equal(1, atc.ddds.size)
      assert_equal('O', atc.ddds.values.first.administration_route)
      part = ODDB::Part.new
      part.count = 3
      part.multi = 1
      part.addition = 0
      part.measure = ODDB::Dose.new(125, 'mg')
      @package.parts.push part
      flexmock(@app,
               :atc_classes => {'key' => atc},
               :log_group   => log_group,
               :active_packages => [@package]
              )
      export_server = flexmock('export_server', :compress => 'compress')

      temporary_replace_constant(@plugin, 'ODDB::CsvExportPlugin::EXPORT_SERVER', export_server ) do
        result =  @plugin.export_ddd_csv # no exception should be raised here
        assert_equal(true, File.exist?(result))
        lines = IO.readlines(result)
        assert_equal(2, lines.size)
        # We did not setup a IKSNR and we do not have ddd_price
        assert_equal('iksnr;package;pharmacode;description;atc_code;available_roas;ddd_roa;ddd_dose;package_roa;package_dose;galenic_forms;price_public;ddd_price;calculation;variant',
                     lines.first.chomp)
        assert_equal(';002;123456;seqname;C01DA02;O;O;95 mg;125 mg;O;Tabletten;103.40;;no calculation done;-1', lines.last.chomp)
      end

    end
  end
end 
