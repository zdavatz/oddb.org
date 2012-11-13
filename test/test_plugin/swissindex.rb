#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestSwissindexPlugin -- oddb.org -- 13.11.2012 -- yasaka@ywesee.com
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
      # Process 1,3
      package = flexmock('package',
                         :barcode => 12345,
                         :pointer => 'pointer',
                        )
      flexmock(@app) do |app|
        app.should_receive(:update).times(2).and_return(package)
      end
      @plugin.instance_eval('@out_of_trade_false_list = [package]')
      @plugin.instance_eval('@out_of_trade_true_list  = [package]')
      # no debugging log
      assert_equal(nil, @plugin.update_out_of_trade)
    end
    def test_update_pharmacode
      # Process 2,4
      package = flexmock('package',
                         :barcode    => nil,
                         :pointer    => 'pointer',
                         :pharmacode => '00001',
                        )
      pharmacode = '00001'
      flexmock(@app) do |app|
        app.should_receive(:update).with(package.pointer, {:pharmacode => pharmacode}, :bag).\
          and_return(package)
        app.should_receive(:update).with(package.pointer, {:pharmacode => nil}, :bag).\
          and_return(package)
      end
      @plugin.instance_eval('@update_pharmacode_list = [[package, pharmacode]]')
      @plugin.instance_eval('@delete_pharmacode_list = [[package, nil]]')
      # no debugging log
      assert_equal(nil, @plugin.update_pharmacode)
    end
    def test_report
      package = flexmock('package',
                         :iksnr   => '00001',
                         :seqnr   => '01',
                         :ikscd   => '001',
                         :barcode => 12345,
                         :pointer => 'pointer',
                        )
      @plugin.instance_eval('@out_of_trade_false_list = [package]')
      @plugin.instance_eval('@out_of_trade_true_list  = [package]')
      @plugin.instance_eval('@delete_pharmacode_list  = [package]')
      @plugin.instance_eval('@update_pharmacode_list  = [package]')
      @plugin.instance_eval('@total_packages  = 123')
      expected = <<REPORT
Checked 123 packages
Updated in trade     (out_of_trade:false): 1 packages
Updated out of trade (out_of_trade:true) : 1 packages
Updated pharmacode: 1 packages
Deleted pharmacode: 1 packages

Updated in trade     (out_of_trade:false): 1 packages
Check swissindex by eancode and then check if the package is out of trade (true) in ch.oddb,
if so the package becomes in trade (false)
        12345: http://ch.oddb.org/de/gcc/drug/reg/00001/seq/01/pack/001

Updated out of trade (out_of_trade:true) : 1 packages
If there is no eancode in swissindex and the package is in trade in ch.oddb,
then the package becomes out of trade (true) in ch.oddb
        12345: http://ch.oddb.org/de/gcc/drug/reg/00001/seq/01/pack/001

Updated pharmacode: 1 packages
If the package does not have a pharmacode and there is a pharmacode found in swissindex,
then put the pharmacode into ch.oddb
        12345: http://ch.oddb.org/de/gcc/drug/reg/00001/seq/01/pack/001

Deleted pharmacode: 1 packages
If there is no eancode in swissindex then delete the according pharmacode in ch.oddb
        12345: http://ch.oddb.org/de/gcc/drug/reg/00001/seq/01/pack/001
REPORT
      assert_equal(expected.chomp, @plugin.report)
    end
    def test_update_package_trade_status__process1
      item = {:phar => 'pharmacode'}
      swissindex = flexmock('swissindex')
      swissindex.should_receive(:download_all).and_return(true)
      swissindex.should_receive(:check_item).and_return('00001')
      swissindex.should_receive(:cleanup_items)
      flexmock(ODDB::SwissindexPharmaPlugin::SWISSINDEX_PHARMA_SERVER).should_receive(:session).and_yield(swissindex)
      package = flexmock('package',
                         :barcode      => 12345,
                         :pointer      => 'pointer',
                         :out_of_trade => true,
                         :pharmacode   => '00001'
                        )
      flexmock(@app) do |app|
        app.should_receive(:each_package).and_yield(package)
        app.should_receive(:packages).and_return([package])
        app.should_receive(:update).and_return(package)
      end
      assert_equal(true, @plugin.update_package_trade_status)
      assert_equal(0,    @plugin.instance_eval('@out_of_trade_true_list.length'))
      assert_equal(1,    @plugin.instance_eval('@out_of_trade_false_list.length'))
      assert_equal(0,    @plugin.instance_eval('@update_pharmacode_list.length'))
      assert_equal(0,    @plugin.instance_eval('@delete_pharmacode_list.length'))
    end
    def test_update_package_trade_status__process2
      item = {:phar => 'pharmacode'}
      swissindex = flexmock('swissindex')
      swissindex.should_receive(:download_all).and_return(true)
      swissindex.should_receive(:check_item).and_return('00001')
      swissindex.should_receive(:cleanup_items)
      flexmock(ODDB::SwissindexPharmaPlugin::SWISSINDEX_PHARMA_SERVER).should_receive(:session).and_yield(swissindex)
      package = flexmock('package',
                         :barcode      => 12345,
                         :pointer      => 'pointer',
                         :out_of_trade => false,
                         :pharmacode   => '99999',
                        )
      flexmock(@app) do |app|
        app.should_receive(:each_package).and_yield(package)
        app.should_receive(:packages).and_return([package])
        app.should_receive(:update).and_return(package)
      end
      assert_equal(true, @plugin.update_package_trade_status)
      assert_equal(0,    @plugin.instance_eval('@out_of_trade_true_list.length'))
      assert_equal(0,    @plugin.instance_eval('@out_of_trade_false_list.length'))
      assert_equal(1,    @plugin.instance_eval('@update_pharmacode_list.length'))
      assert_equal(0,    @plugin.instance_eval('@delete_pharmacode_list.length'))
    end
    def test_update_package_trade_status__process3_status_inactive
      item = {:phar => 'pharmacode'}
      swissindex = flexmock('swissindex')
      swissindex.should_receive(:download_all).and_return(true)
      swissindex.should_receive(:check_item).and_return(false) # inactive
      swissindex.should_receive(:cleanup_items)
      flexmock(ODDB::SwissindexPharmaPlugin::SWISSINDEX_PHARMA_SERVER).should_receive(:session).and_yield(swissindex)
      package = flexmock('package',
                         :barcode      => 12345,
                         :pointer      => 'pointer',
                         :out_of_trade => false,
                         :pharmacode   => '00001',
                        )
      flexmock(@app) do |app|
        app.should_receive(:each_package).and_yield(package)
        app.should_receive(:packages).and_return([package])
        app.should_receive(:update).and_return(package)
      end
      assert_equal(true, @plugin.update_package_trade_status)
      assert_equal(1,    @plugin.instance_eval('@out_of_trade_true_list.length'))
      assert_equal(0,    @plugin.instance_eval('@out_of_trade_false_list.length'))
      assert_equal(0,    @plugin.instance_eval('@update_pharmacode_list.length'))
      assert_equal(0,    @plugin.instance_eval('@delete_pharmacode_list.length'))
    end
    def test_update_package_trade_status__process3_pharmacode_not_found
      item = {:phar => 'pharmacode'}
      swissindex = flexmock('swissindex')
      swissindex.should_receive(:download_all).and_return(true)
      swissindex.should_receive(:check_item).and_return(nil) # not found
      swissindex.should_receive(:cleanup_items)
      flexmock(ODDB::SwissindexPharmaPlugin::SWISSINDEX_PHARMA_SERVER).should_receive(:session).and_yield(swissindex)
      package = flexmock('package',
                         :barcode      => 12345,
                         :pointer      => 'pointer',
                         :out_of_trade => false,
                         :pharmacode   => '00001',
                         :sl_entry     => true,
                        )
      flexmock(@app) do |app|
        app.should_receive(:each_package).and_yield(package)
        app.should_receive(:packages).and_return([package])
        app.should_receive(:update).and_return(package)
      end
      assert_equal(true, @plugin.update_package_trade_status)
      assert_equal(1,    @plugin.instance_eval('@out_of_trade_true_list.length'))
      assert_equal(0,    @plugin.instance_eval('@out_of_trade_false_list.length'))
      assert_equal(0,    @plugin.instance_eval('@update_pharmacode_list.length'))
      assert_equal(0,    @plugin.instance_eval('@delete_pharmacode_list.length'))
    end
    def test_update_package_trade_status__process4
      item = {:phar => 'pharmacode'}
      swissindex = flexmock('swissindex')
      swissindex.should_receive(:download_all).and_return(true)
      swissindex.should_receive(:check_item).and_return(nil) # not found
      swissindex.should_receive(:cleanup_items)
      flexmock(ODDB::SwissindexPharmaPlugin::SWISSINDEX_PHARMA_SERVER).should_receive(:session).and_yield(swissindex)
      package = flexmock('package',
                         :barcode      => 12345,
                         :pointer      => 'pointer',
                         :out_of_trade => true,
                         :pharmacode   => '00001',
                         :sl_entry     => nil,
                        )
      flexmock(@app) do |app|
        app.should_receive(:each_package).and_yield(package)
        app.should_receive(:packages).and_return([package])
        app.should_receive(:update).and_return(package)
      end
      assert_equal(true, @plugin.update_package_trade_status)
      assert_equal(0,    @plugin.instance_eval('@out_of_trade_true_list.length'))
      assert_equal(0,    @plugin.instance_eval('@out_of_trade_false_list.length'))
      assert_equal(0,    @plugin.instance_eval('@update_pharmacode_list.length'))
      assert_equal(1,    @plugin.instance_eval('@delete_pharmacode_list.length'))
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
