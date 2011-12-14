#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::LogGroupTest -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com 
# ODDB::LogGroupTest -- oddb.org -- 16.05.2003 -- hwyss@ywesee.com 


$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'util/loggroup'

module ODDB
	class LogGroup
		attr_accessor :logs
	end
end

class TestLogGroup < Test::Unit::TestCase
	def setup
		@group = ODDB::LogGroup.new(:swissmedic_journal)
	end
	def test_newest_date
		assert_nil(@group.newest_date)
		date = Date.new(1975,8,21)
		date1 = date.dup
		@group.logs = {
			date =>	Object.new
		}
		assert_equal(date, @group.newest_date)
		date = date >> 1
		assert_equal(date1, @group.newest_date)
	end
	def test_log
		foo = Object.new
		date = Date.new(1975,8,21)
		@group.logs = {
			date =>	foo
		}
		assert_equal(foo, @group.log(date))
	end
	def test_create_log
		date = Date.new(1975,8,21)
		@group.create_log(date)
		assert_equal([date], @group.logs.keys)
		assert_equal(ODDB::Log, @group.logs[date].class)
	end
  def test_latest
    assert_nil(@group.latest)
  end
  def test_months
    @group.instance_eval('@logs = {Time.local(2011,2,3) => "value"}')
    assert_equal([2], @group.months(2011))
  end
  def test_years
    @group.instance_eval('@logs = {Time.local(2011,2,3) => "value"}')
    assert_equal([2011], @group.years)
  end
end
