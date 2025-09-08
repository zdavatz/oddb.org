#!/usr/bin/env ruby

# ODDB::LogGroupTest -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com
# ODDB::LogGroupTest -- oddb.org -- 16.05.2003 -- hwyss@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "util/loggroup"
require "util/currency"

module ODDB
  class LogGroup
    attr_accessor :logs
  end
end

class TestLogGroup < Minitest::Test
  def setup
    @group = ODDB::LogGroup.new(:swissmedic_journal)
  end

  def test_newest_date
    assert_nil(@group.newest_date)
    date = Date.new(1975, 8, 21)
    date1 = date.dup
    @group.logs = {
      date =>	Object.new
    }
    assert_equal(date, @group.newest_date)
    date >> 1
    assert_equal(date1, @group.newest_date)
  end

  def test_log
    foo = Object.new
    date = Date.new(1975, 8, 21)
    @group.logs = {
      date =>	foo
    }
    assert_equal(foo, @group.log(date))
  end

  def test_create_log
    date = Date.new(1975, 8, 21)
    @group.create_log(date)
    assert_equal([date], @group.logs.keys)
    assert_equal(ODDB::Log, @group.logs[date].class)
  end

  def test_latest
    assert_nil(@group.latest)
  end

  def test_months
    @group.instance_eval('@logs = {Time.local(2011,2,3) => "value"}', __FILE__, __LINE__)
    assert_equal([2], @group.months(2011))
  end

  def test_years
    @group.instance_eval('@logs = {Time.local(2011,2,3) => "value"}', __FILE__, __LINE__)
    assert_equal([2011], @group.years)
  end

  def test_marshall
    hexdump = "0408553a09446174655b0b690069006902c0a8553a0d526174696f6e616c5b076c2b0800001a71180269029dff6900660c32323939313631"
    # 0408553a09446174655b0b69006900690069006900660c32323939313631
    binary = [hexdump].pack("H*")
    obj = ::Marshal.load(binary)
    assert_equal(Date, obj.class)
    assert_equal(-4712, obj.year)
    assert_equal(1, obj.month)
    assert_equal(1, obj.day)
  end
end
