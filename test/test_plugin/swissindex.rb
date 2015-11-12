#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestSwissindexPlugin -- oddb.org -- 13.11.2012 -- yasaka@ywesee.com
# ODDB::TestSwissindexPlugin -- oddb.org -- 16.09.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'ext/swissindex/src/swissindex'
require 'plugin/swissindex'
require 'fileutils'

module ODDB
  class TestLogging <Minitest::Test
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
    def compress_many(*args)
    end
  end

  class SwissindexMigelPlugin
    remove_const :SWISSINDEX_MIGEL_SERVER
    SWISSINDEX_MIGEL_SERVER = StubDRbObject.new
  end

  class TestSwissindexMigelPlugin <Minitest::Test
    include FlexMock::TestCase
    def setup
      @app = flexmock('app', :update => 'update')
      @plugin = ODDB::SwissindexMigelPlugin.new(@app)
      log = flexmock('log', :print => nil)
      flexmock(ODDB::SwissindexMigelPlugin::Logging) do |logging|
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
      flexmock(ODDB::SwissindexMigelPlugin::SWISSINDEX_MIGEL_SERVER).should_receive(:session).and_yield(swissindex)
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
      flexmock(ODDB::SwissindexMigelPlugin::SWISSINDEX_MIGEL_SERVER).should_receive(:session).and_yield(swissindex)
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
      flexmock(ODDB::SwissindexMigelPlugin::SWISSINDEX_MIGEL_SERVER).should_receive(:session).and_yield(swissindex)
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
      flexmock(ODDB::SwissindexMigelPlugin::SWISSINDEX_MIGEL_SERVER).should_receive(:session).and_yield(swissindex)
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
      flexmock(ODDB::SwissindexMigelPlugin::SWISSINDEX_MIGEL_SERVER).should_receive(:session).and_yield(swissindex)
      file = flexmock('file', :print => nil)
      flexmock(@plugin).should_receive(:open).and_yield(file)
      assert(@plugin.migel_nonpharma('pharmacode_file'))
    end
  end # TestSwissindexMigelPlugin



end # ODDB
