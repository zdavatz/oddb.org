#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestConfig -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# ODDB::TestConfig -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com
# ODDB::TestConfig -- oddb.org -- 14.10.2004 -- hwyss@ywesee.com, usenguel@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("..", File.dirname(__FILE__))

require 'rclconf'
require 'stub/odba'

require 'minitest/autorun'
require 'flexmock/minitest'
require 'util/config'
require 'logger'

module ODDB
  class TestConfig <Minitest::Test
    def setup
      ##### OBSOLETE ######
      @config = Config.new
    end
    def test_respond_to
      assert_equal(false, @config.respond_to?(:marshal_load))
      assert_equal(true, @config.respond_to?(:xxx))
    end
    def test_method
      @config.instance_eval('@values.store("xxx", "yyy")')
      @config.method(:xxx)
      assert_equal('yyy', @config.xxx)
    end
    def test_method_missing_create
      assert_equal(@config, @config.create_xxx)
    end
    def test_method_missing_assignment
      xxx = flexmock('xxx', :odba_isolated_store => 'odba_isolated_store')
      bbb = flexmock('bbb', :odba_delete => 'odba_delete')
      @config.instance_eval('@values.store("aaa", bbb)')
      assert_equal(xxx, @config.aaa=xxx)
    end
    def test_method_missing__odba_instance_nil
      values = flexmock('values', :odba_instance => nil)
      @config.instance_eval('@values = values')
      assert_nil(@config.xxx)
    end
    def test_reader
      assert_nil(@config.foo)
      assert_nil(@config.bar)
      assert_nil(@config.hatto)
    end
  end
  def ODDB.config
  defaults = {
    'text_info_searchform'  => nil,
    'text_info_searchform2' => nil,
    'testenvironment1'      => '/var/www/oddb.org/test/testenvironment1.rb',
    'testenvironment2'      => '/var/www/oddb.org/test/testenvironment2.rb'
  }
  @config = RCLConf::RCLConf.new(ARGV, defaults)
  @config
  end
  class TestConfigLog <Minitest::Test
    def setup
      sleep 0.1
      dir = File.expand_path(File.join(__FILE__, '..', '..', '..'))
      @config_ru = File.join(dir, 'config.ru')
      load 'config.rb'
    end
    def test_log_pattern
      # this will be the apache rack_log. The app will be replace in the config.ru
      assert(ODDB.config.log_pattern.index('log/%Y/%m/%d/app_log'))
    end
    def test_log_pattern_default_app
      skip('Test does not work under Ruby 3.4') if RUBY_VERSION.to_f >= 3.4 # TODO:
      eval("::APPNAME=  nil")
      args1 = {:shift_age=>0, :shift_size=>1048576, :shift_period_suffix=>"%Y%m%d", :binmode=>false}
      args2 = {:shift_age=>"daily", :shift_size=>1048576, :shift_period_suffix=>"%Y%m%d", :binmode=>false}
      flexmock(Logger::LogDevice) do
        |klass|
        klass.should_receive(:new).once.with(
           File.expand_path(File.join(File.dirname(__FILE__), '..', '..', "log/#{Date.today.year}/oddb.log")), args2)
        klass.should_receive(:new).at_most.once.with(STDERR, args1) # may be called here or in test_log_pattern_with_appname
      end
      load @config_ru
      assert_equal('oddb', SBSM.logger.progname)
    end
    def test_log_pattern_with_appname
      skip('Test does not work under Ruby 3.4') if RUBY_VERSION.to_f >= 3.4 # TODO:
      eval("::APPNAME='crawler'")
      args1 = {:shift_age=>0, :shift_size=>1048576, :shift_period_suffix=>"%Y%m%d", :binmode=>false}
      args2 = {:shift_age=>"daily", :shift_size=>1048576, :shift_period_suffix=>"%Y%m%d", :binmode=>false}
      flexmock(Logger::LogDevice) do
        |klass|
        klass.should_receive(:new).once.with(
           File.expand_path(File.join(File.dirname(__FILE__), '..', '..', "log/#{Date.today.year}/crawler.log")), args2)
        klass.should_receive(:new).at_most.once.with(STDERR, args1) # may be called here or in test_log_pattern_default_app
      end
      load @config_ru
      assert_equal('crawler', SBSM.logger.progname)
    end
  end
end


