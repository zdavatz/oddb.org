#!/usr/bin/env ruby
# ODDB::TestSwissindexPlugin -- oddb.org -- 30.05.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'ext/swissindex/src/swissindex'
require 'plugin/swissindex'

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
end # ODDB
