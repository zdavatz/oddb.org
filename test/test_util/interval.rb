#!/usr/bin/env ruby
# TestInterval -- oddb -- 03.07.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'util/interval'

class TestInterval < Test::Unit::TestCase
	class StubSession
		attr_accessor :user_input
		def user_input(key)
			(@user_input ||= {})[key]
		end
		def language
			:to_s
		end
	end
	class Stub
		include ODDB::Interval
		public :get_intervals
		attr_accessor :model
		def initialize(session, model)
			@session = session
			@model = model
		end
		def init
		end
	end

	def setup
		@model = [
		'abc', 'def', 'ghi', 'jkl', 'mno', 'pqr', 'stu', 'vwx', 'yz0', '123',
		]
		@session = StubSession.new
		@interval = Stub.new(@session, @model)
	end
	def test_get_intervals
		assert_equal(7, @interval.get_intervals.size)
		@interval.model = [ 'abc' ]
		assert_equal(1, @interval.get_intervals.size)
		ad = 'a-d'
		assert_equal(ad, @interval.get_intervals.first)
		@interval.model = [ 'abc', '123' ]
		assert_equal(2, @interval.get_intervals.size)
		assert_equal([ad, 'unknown'], @interval.get_intervals)
	end
	def test_default_interval1
		ad = 'a-d'
		assert_equal(ad, @interval.default_interval)
	end
	def test_default_interval2
		@interval.model = [
			'ghi', 'jkl', 'mno', 'pqr', 'stu', 'vwx', 'yz0', '123',
		]
		eh = 'e-h'
		assert_equal(eh, @interval.default_interval)
	end
	def test_empty_range_patterns
		@interval.model = []
		assert_not_nil(@interval.default_interval)
	end
end
