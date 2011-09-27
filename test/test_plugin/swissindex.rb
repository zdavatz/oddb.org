#!/usr/bin/env ruby
# ODDB::TestSwissindexPlugin -- oddb.org -- 16.09.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'ext/swissindex/src/swissindex'
require 'plugin/swissindex'
require 'fileutils'

module ODDB
  class TestLogging < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      ODDB::SwissindexPlugin::Logging.flag = true
    end
    def test_flag
      assert(ODDB::SwissindexPlugin::Logging.flag)
    end
    def test_start
      flexmock(FileUtils, :mkdir_p => nil)
      file = flexmock('file')
      flexmock(File, :open => file)
      flexmock(file, 
               :close => nil,
               :print => nil
              )
      ODDB::SwissindexPlugin::Logging.start('file') do |f|
        assert_equal(file, f)
      end
    end
    def test_append
      flexmock(FileUtils, :mkdir_p => nil)
      file = flexmock('file')
      flexmock(File, :open => file)
      flexmock(file, :close => nil)
      ODDB::SwissindexPlugin::Logging.append('file') do |f|
        assert_equal(file, f)
      end
    end
    def test_append_estimate_time
      flexmock(FileUtils, :mkdir_p => nil)
      file = flexmock('file')
      log = flexmock('log', :print => nil)
      flexmock(File).should_receive(:open).once.and_return(file)
      flexmock(File).should_receive(:open).once.and_yield(log).and_return(file)
      flexmock(file, 
               :close => nil,
               :print => nil
              )
      ODDB::SwissindexPlugin::Logging.start('file') do |f|
        assert_equal(file, f)
      end
      assert_equal(file, ODDB::SwissindexPlugin::Logging.append_estimate_time('file', 1, 2))
    end
    def test_append_estimate_time__over_one_hour
      time_now = Time.now
      flexmock(Time).should_receive(:now).twice.and_return(time_now - 40000)
      flexmock(Time).should_receive(:now).twice.and_return(time_now)
      flexmock(FileUtils, :mkdir_p => nil)
      file = flexmock('file')
      log = flexmock('log', :print => nil)
      flexmock(File).should_receive(:open).once.and_return(file)
      flexmock(File).should_receive(:open).once.and_yield(log).and_return(file)
      flexmock(file, 
               :close => nil,
               :print => nil
              )
      ODDB::SwissindexPlugin::Logging.start('file') do |f|
        assert_equal(file, f)
      end
      assert_equal(file, ODDB::SwissindexPlugin::Logging.append_estimate_time('file', 1, 2))
    end
  end # TestLogging

  class StubDRbObject
    def export_oddbdat(*args)
      ['export_oddbdat']
    end
    def compress_many(*args)
    end
  end
  class SwissindexPharmaPlugin
    remove_const :SWISSINDEX_PHARMA_SERVER
    SWISSINDEX_PHARMA_SERVER = StubDRbObject.new
  end

  class TestSwissindexPharmaPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @app = flexmock('app', :update => 'update')
      @plugin = ODDB::SwissindexPharmaPlugin.new(@app)
      log = flexmock('log', :print => nil)
      flexmock(ODDB::SwissindexPharmaPlugin::Logging) do |logging|
        logging.should_receive(:start).and_yield(log)
        logging.should_receive(:append).and_yield(log)
      end
    end
    def test_update_out_of_trade
      package = flexmock('package', 
                         :barcode => nil,
                         :pointer => nil
                        )
      @plugin.instance_eval('@out_of_trade_false_list = [package]')
      @plugin.instance_eval('@out_of_trade_true_list  = [package]')
      assert_equal([package], @plugin.update_out_of_trade)
    end
    def test_update_pharmacode
      package = flexmock('package', 
                         :barcode => nil,
                         :pointer => nil
                        )
      @plugin.instance_eval('@delete_pharmacode_list = [package]')
      @plugin.instance_eval('@update_pharmacode_list = [package]')
      assert_equal([package], @plugin.update_pharmacode)
    end
    def test_report
      package = flexmock('package', 
                         :barcode => 12345,
                         :pointer => 'pointer' 
                        )
      @plugin.instance_eval('@out_of_trade_false_list = [package]')
      @plugin.instance_eval('@out_of_trade_true_list  = [package]')
      @plugin.instance_eval('@delete_pharmacode_list  = [package]')
      @plugin.instance_eval('@update_pharmacode_list  = [package]')
      @plugin.instance_eval('@total_packages  = 123')

      expected = "Checked 123 packages\nUpdated in trade     (out_of_trade:false): 1 packages\nUpdated out of trade (out_of_trade:true) : 1 packages\nUpdated pharmacode: 1 packages\nDeleted pharmacode: 1 packages\n\nUpdated in trade     (out_of_trade:false): 1 packages\nCheck swissindex by eancode and then check if the package is out of trade (true) in ch.oddb,\nif so the package becomes in trade (false)\n        12345: http://ch.oddb.org/de/gcc/resolve/pointer/pointer\n\nUpdated out of trade (out_of_trade:true) : 1 packages\nIf there is no eancode in swissindex and the package is in trade in ch.oddb,\nthen the package becomes out of trade (true) in ch.oddb\n        12345: http://ch.oddb.org/de/gcc/resolve/pointer/pointer\n\nUpdated pharmacode: 1 packages\nIf the package does not have a pharmacode and there is a pharmacode found in swissindex,\nthen put the pharmacode into ch.oddb\n        12345: http://ch.oddb.org/de/gcc/resolve/pointer/pointer\n\nDeleted pharmacode: 1 packages\nIf there is no eancode in swissindex then delete the according pharmacode in ch.oddb\n        12345: http://ch.oddb.org/de/gcc/resolve/pointer/pointer"
      assert_equal(expected, @plugin.report)
    end
    def test_update_package_trade_status__process12
      item = {:phar => 'pharmacode'}
      swissindex = flexmock('swissindex', :search_item => item)
      flexmock(ODDB::SwissindexPharmaPlugin::SWISSINDEX_PHARMA_SERVER).should_receive(:session).and_yield(swissindex)
      package = flexmock('package',
                         :barcode => 12345,
                         :pointer => 'pointer',
                         :out_of_trade => true,
                         :pharmacode => nil
                        )
      flexmock(@app) do |app|
        app.should_receive(:each_package).and_yield(package)
        app.should_receive(:packages).and_return([package])
      end
      assert_equal(true, @plugin.update_package_trade_status)
    end
    def test_update_package_trade_status__process34
      swissindex = flexmock('swissindex', :search_item => nil)
      flexmock(ODDB::SwissindexPharmaPlugin::SWISSINDEX_PHARMA_SERVER).should_receive(:session).and_yield(swissindex)
      package = flexmock('package',
                         :barcode => 12345,
                         :pointer => 'pointer',
                         :out_of_trade => false,
                         :pharmacode => 'pharmacode',
                         :sl_entry => 'sl_entry'
                        )
      flexmock(@app) do |app|
        app.should_receive(:each_package).and_yield(package)
        app.should_receive(:packages).and_return([package])
      end
      assert_equal(true, @plugin.update_package_trade_status)
    end
    def test_load_ikskey
      item = {:gtin => '1234567890123'}
      swissindex = flexmock('swissindex', :search_item => item)
      flexmock(ODDB::SwissindexPharmaPlugin::SWISSINDEX_PHARMA_SERVER).should_receive(:session).and_yield(swissindex)
      assert_equal('56789012', @plugin.load_ikskey('pahrmacode'))
    end
  end # TestSwissindexPharmaPlugin

  class SwissindexNonpharmaPlugin
    remove_const :SWISSINDEX_NONPHARMA_SERVER
    SWISSINDEX_NONPHARMA_SERVER = StubDRbObject.new
  end

  class TestSwissindexNonpharmaPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @app = flexmock('app', :update => 'update')
      @plugin = ODDB::SwissindexNonpharmaPlugin.new(@app)
      log = flexmock('log', :print => nil)
      flexmock(ODDB::SwissindexNonpharmaPlugin::Logging) do |logging|
        logging.should_receive(:start).and_yield(log)
        logging.should_receive(:append).and_yield(log)
      end
    end
    def test_report
      @plugin.instance_eval('@output_file = "output_file"')
      expected = File.expand_path('output_file')
      assert_equal(expected, @plugin.report)
    end
    def test_log_info
      @plugin.instance_eval('@output_file = "output_file"')
      report = File.expand_path('output_file')
      expected = {
        :files        => {"output_file"=>"text/csv"},
        :recipients   => [],
        :report       => report,
        :change_flags => {}
      }
      assert_equal(expected, @plugin.log_info)
    end
    def test_migel_nonpharma
      pharmacode_list = ['pharmacode']
      flexmock(File, 
               :readlines => pharmacode_list,
               :exist?    => true
              )
      flexmock(FileUtils, :mkdir_p => nil)
      search_item = {
        :gtin => 'gtin',
        :dt   => 'dt',
        :status => 'status',
        :stdate => 'stdate',
        :lang   => 'lang',
        :dscr   => 'dscr',
        :addscr => 'addscr',
        :comp   => {:name => 'name', :gln => 'gln'}
      }
      swissindex = flexmock('swissindex', 
                            :search_migel => [],
                            :search_migel_position_number => nil,
                            :search_item  => search_item
                           )
      flexmock(ODDB::SwissindexNonpharmaPlugin::SWISSINDEX_NONPHARMA_SERVER).should_receive(:session).and_yield(swissindex)
      file = flexmock('file', :print => nil)
      flexmock(@plugin).should_receive(:open).and_yield(file)
      assert(@plugin.migel_nonpharma('pharmacode_file'))
    end
    def test_migel_nonpharma__no_company_data
      pharmacode_list = ['pharmacode']
      flexmock(File, 
               :readlines => pharmacode_list,
               :exist?    => true
              )
      flexmock(FileUtils, :mkdir_p => nil)
      search_item = {
        :gtin => 'gtin',
        :dt   => 'dt',
        :status => 'status',
        :stdate => 'stdate',
        :lang   => 'lang',
        :dscr   => 'dscr',
        :addscr => 'addscr',
        :comp   => nil
      }
      swissindex = flexmock('swissindex', 
                            :search_migel => [1,2,3],
                            :search_migel_position_number => nil,
                            :search_item  => search_item
                           )
      flexmock(ODDB::SwissindexNonpharmaPlugin::SWISSINDEX_NONPHARMA_SERVER).should_receive(:session).and_yield(swissindex)
      file = flexmock('file', :print => nil)
      flexmock(@plugin).should_receive(:open).and_yield(file)
      assert(@plugin.migel_nonpharma('pharmacode_file'))
    end
    def test_migel_nonpharma__no_company_data__no_migel_data
      pharmacode_list = ['pharmacode']
      flexmock(File, 
               :readlines => pharmacode_list,
               :exist?    => true
              )
      flexmock(FileUtils, :mkdir_p => nil)
      search_item = {
        :gtin => 'gtin',
        :dt   => 'dt',
        :status => 'status',
        :stdate => 'stdate',
        :lang   => 'lang',
        :dscr   => 'dscr',
        :addscr => 'addscr',
        :comp   => nil
      }
      swissindex = flexmock('swissindex', 
                            :search_migel => [],
                            :search_migel_position_number => nil,
                            :search_item  => search_item
                           )
      flexmock(ODDB::SwissindexNonpharmaPlugin::SWISSINDEX_NONPHARMA_SERVER).should_receive(:session).and_yield(swissindex)
      file = flexmock('file', :print => nil)
      flexmock(@plugin).should_receive(:open).and_yield(file)
      assert(@plugin.migel_nonpharma('pharmacode_file'))
    end

    def test_migel_nonpharma__no_swissindex_data
      pharmacode_list = ['pharmacode']
      flexmock(File, 
               :readlines => pharmacode_list,
               :exist?    => true
              )
      flexmock(FileUtils, :mkdir_p => nil)
      swissindex = flexmock('swissindex', 
                            :search_migel => [1,2,3],
                            :search_migel_position_number => nil,
                            :search_item  => nil
                           )
      flexmock(ODDB::SwissindexNonpharmaPlugin::SWISSINDEX_NONPHARMA_SERVER).should_receive(:session).and_yield(swissindex)
      file = flexmock('file', :print => nil)
      flexmock(@plugin).should_receive(:open).and_yield(file)
      assert(@plugin.migel_nonpharma('pharmacode_file'))
    end

    def test_migel_nonpharma__no_swissindex_data__no_migel_data
      pharmacode_list = ['pharmacode']
      flexmock(File, 
               :readlines => pharmacode_list,
               :exist?    => true
              )
      flexmock(FileUtils, :mkdir_p => nil)
      swissindex = flexmock('swissindex', 
                            :search_migel => [],
                            :search_migel_position_number => nil,
                            :search_item  => nil
                           )
      flexmock(ODDB::SwissindexNonpharmaPlugin::SWISSINDEX_NONPHARMA_SERVER).should_receive(:session).and_yield(swissindex)
      file = flexmock('file', :print => nil)
      flexmock(@plugin).should_receive(:open).and_yield(file)
      assert(@plugin.migel_nonpharma('pharmacode_file'))
    end
  end # TestSwissindexNonpharmaPlugin



end # ODDB
