#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../test", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'ext/refdata/src/refdata'
require 'plugin/refdata'
require 'fileutils'
require 'test_helpers' # for VCR setup

module ODDB
  class TestLogging <Minitest::Test
    @@thread = nil
    def setup
      ODDB::RefdataPlugin::Logging.flag = true
      TestHelpers.vcr_setup
      @uri = ODDB::Refdata::RefdataArticle::URI.sub('127.0.0.1', "")
      GC.start; sleep 0.01
      unless @@thread
        @@thread =  DRb.start_service(@uri, ODDB::Refdata)
     end
    end

    def test_flag
      assert(ODDB::RefdataPlugin::Logging.flag)
    end
    def test_start
      flexmock(FileUtils, :mkdir_p => nil)
      file = flexmock('file')
      flexmock(File, :open => file)
      flexmock(file, 
               :close => nil,
               :print => nil
              )
      ODDB::RefdataPlugin::Logging.start('file') do |f|
        assert_equal(file, f)
      end
    end
    def test_append
      flexmock(FileUtils, :mkdir_p => nil)
      file = flexmock('file')
      flexmock(File, :open => file)
      flexmock(file, :close => nil)
      ODDB::RefdataPlugin::Logging.append('file') do |f|
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
      ODDB::RefdataPlugin::Logging.start('file') do |f|
        assert_equal(file, f)
      end
      assert_equal(file, ODDB::RefdataPlugin::Logging.append_estimate_time('file', 1, 2))
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
      ODDB::RefdataPlugin::Logging.start('file') do |f|
        assert_equal(file, f)
      end
      assert_equal(file, ODDB::RefdataPlugin::Logging.append_estimate_time('file', 1, 2))
    end
  end # TestLogging
  class TestRefdataPlugin <Minitest::Test
    def setup
      @update = flexmock('update', :barcode => 'barcode')
      @app = flexmock('app', :update => @update)
      @plugin = ODDB::RefdataPlugin.new(@app)
      log = flexmock('log', :print => nil)
      flexmock(ODDB::RefdataPlugin::Logging) do |logging|
        logging.should_receive(:start).and_yield(log)
        logging.should_receive(:append).and_yield(log)
      end
    end
    def test_update_out_of_trade
      # Process 1,3
      package = flexmock("package_#{__LINE__}",
                         :barcode => TestHelpers::LEVETIRACETAM_GTIN,
                         :pointer => 'pointer',
                         :sl_entry => 'sl_entry',
                        )
      @app = flexmock('app')
      @plugin = ODDB::RefdataPlugin.new(@app)
      flexmock(@app) do |app|
        app.should_receive(:update).with('pointer', {:out_of_trade=>false, :refdata_override=>false}, :refdata).once.and_return(package)
        app.should_receive(:update).with('pointer', {:out_of_trade=>true}, :refdata).once.and_return(package)
      end
      @plugin.instance_eval('@out_of_trade_false_list = [package]')
      @plugin.instance_eval('@out_of_trade_true_list  = [package]')
      # no debugging log
      assert_nil(@plugin.update_out_of_trade)
    end

    def test_update_pharmacode
      # Process 2,4
      package = flexmock("package_#{__LINE__}",
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
      assert_nil(@plugin.update_pharmacode)
    end
    def test_report
      package = flexmock("package_#{__LINE__}",
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
        12345: https://#{SERVER_NAME}/de/gcc/drug/reg/00001/seq/01/pack/001

Updated out of trade (out_of_trade:true) : 1 packages
If there is no eancode in swissindex and the package is in trade in ch.oddb,
then the package becomes out of trade (true) in ch.oddb
        12345: https://#{SERVER_NAME}/de/gcc/drug/reg/00001/seq/01/pack/001

Updated pharmacode: 1 packages
If the package does not have a pharmacode and there is a pharmacode found in swissindex,
then put the pharmacode into ch.oddb
        12345: https://#{SERVER_NAME}/de/gcc/drug/reg/00001/seq/01/pack/001

Deleted pharmacode: 1 packages
If there is no eancode in swissindex then delete the according pharmacode in ch.oddb
        12345: https://#{SERVER_NAME}/de/gcc/drug/reg/00001/seq/01/pack/001
REPORT
      assert_equal(expected.chomp, @plugin.report)
    end
    def test_update_package_trade_status__process1
      item = {:phar => 'pharmacode'}
      swissindex = flexmock('swissindex')
      swissindex.should_receive(:download_all).and_return(true)
      swissindex.should_receive(:get_refdata_info).and_return( {:atype=>"PHARMA", :gtin=>"7680437880869", :phar=>"00001"})
      swissindex.should_receive(:cleanup_items).never
      package = flexmock("package_#{__LINE__}",
                         :barcode      => "7680437880869",
                         :pointer      => 'pointer',
                         :sl_entry      => 'sl_entry',
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
      assert_equal(0,    @plugin.instance_eval('@update_pharmacode_list.length'))
      assert_equal(0,    @plugin.instance_eval('@delete_pharmacode_list.length'))
      assert_equal(1,    @plugin.instance_eval('@out_of_trade_false_list.length'))
    end
    def test_update_package_trade_status
      @plugin = ODDB::RefdataPlugin.new(@app)
      package = flexmock("package_#{__LINE__}",
                         :barcode      =>  TestHelpers::LEVETIRACETAM_GTIN,
                         :pointer      => 'pointer',
                         :out_of_trade => true,
                         :sl_entry   => 'sl_entry '
                        )
      flexmock(@app) do |app|
        app.should_receive(:each_package).and_yield(package)
        app.should_receive(:packages).and_return([package])
        app.should_receive(:update).and_return(package)
      end
      assert_equal(true, @plugin.update_package_trade_status)
      assert_equal(0,    @plugin.instance_eval('@out_of_trade_true_list.length'))
      assert_equal(0,    @plugin.instance_eval('@update_pharmacode_list.length'))
      assert_equal(0,    @plugin.instance_eval('@delete_pharmacode_list.length'))
      assert_equal(1,    @plugin.instance_eval('@out_of_trade_false_list.length'))
    end
    def test_update_package_trade_status__process2
      @plugin = ODDB::RefdataPlugin.new(@app)
      package = flexmock("package_#{__LINE__}",
                         :barcode      => 7680437880869,
                         :pointer      => 'pointer',
                         :sl_entry      => 'sl_entry',
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
      assert_equal(0,    @plugin.instance_eval('@delete_pharmacode_list.length'))
      skip("2020.07.15: As the pharmacode was removed, this situation process 2 cannot happen")
      assert_equal(1,    @plugin.instance_eval('@update_pharmacode_list.length'))
    end
    def test_update_package_trade_status__process3_status_inactive
      item = {:phar => 'pharmacode'}
      swissindex = flexmock('swissindex')
      swissindex.should_receive(:download_all).and_return(true)
      swissindex.should_receive(:get_refdata_info).and_return( {}) # inactive
      swissindex.should_receive(:cleanup_items).never
      flexmock(ODDB::RefdataPlugin::REFDATA_SERVER).should_receive(:session).and_yield(swissindex)
      package = flexmock("package_#{__LINE__}",
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
    def test_update_package_trade_status__process3_pharmacode_not_found
      item = {:phar => 'pharmacode'}
      swissindex = flexmock('swissindex')
      swissindex.should_receive(:download_all).and_return(true)
      swissindex.should_receive(:get_refdata_info).and_return( {}) #  not found
      swissindex.should_receive(:cleanup_items).never
      flexmock(ODDB::RefdataPlugin::REFDATA_SERVER).should_receive(:session).and_yield(swissindex)
      package = flexmock("package_#{__LINE__}",
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
      swissindex.should_receive(:get_refdata_info).and_return( {}) #  not found
      swissindex.should_receive(:cleanup_items).never
      flexmock(ODDB::RefdataPlugin::REFDATA_SERVER).should_receive(:session).and_yield(swissindex)
      package = flexmock("package_#{__LINE__}",
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
      flexmock(ODDB::RefdataPlugin::REFDATA_SERVER).should_receive(:session).and_yield(swissindex)
      assert_equal('56789012', @plugin.load_ikskey('pahrmacode'))
    end
  end
end # ODDB
