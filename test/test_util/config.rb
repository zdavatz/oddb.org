#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestConfig -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# ODDB::TestConfig -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com
# ODDB::TestConfig -- oddb.org -- 14.10.2004 -- hwyss@ywesee.com, usenguel@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("..", File.dirname(__FILE__))

require 'rclconf'
require 'stub/odba'
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'util/config'

module ODDB
  class TestConfig <Minitest::Test
    include FlexMock::TestCase
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
end
