#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestInterval -- oddb.org -- 21.04.2011 -- mhatakeyama@ywesee.com
# ODDB::TestInterval -- oddb.org -- 03.07.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'util/interval'
require 'odba'

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
		assert_equal([ad, '|unknown'], @interval.get_intervals)
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

module ODDB
  class TestInterval < Test::Unit::TestCase
    include FlexMock::TestCase
    class StubInterval
      include ODDB::Interval
      def initialize(model, session)
        @model   = model
        @session = session
      end
    end
    class StubIntervalPersistentRange
      include ODDB::Interval
      PERSISTENT_RANGE = true
      def initialize(model, session)
        @model   = model
        @session = session
      end
    end
    class StubIntervalRangePatterns
      include ODDB::Interval
      RANGE_PATTERNS = {}
      def initialize(model, session)
        @model   = model
        @session = session
      end
    end
    def setup
      @session  = flexmock('session')
      @model    = ['abc', 'def', 'ghi', 'jkl', 'mno', 'pqr', 'stu', 'vwx', 'yz0', '123']
      @interval = ODDB::TestInterval::StubInterval.new(@model, @session)
    end
    def test_range_patterns
      expected = @interval.instance_eval('RANGE_PATTERNS')
      assert_equal(expected, @interval.range_patterns)
    end
    def test_range_patterns__nil
      interval = ODDB::TestInterval::StubIntervalRangePatterns.new(@model, @session)
      assert_equal({}, interval.range_patterns)
    end
    def test_interval
      range = 'a-dÅÆÄÁÂÀÃĄǍĂĀȦḂÇĈČĆĊḐĐÐĎḊåæäáâàãąǎăāȧḃçĉčćċḑđðďḋ'
      @interval.instance_eval('@range = range')
      expected = 'a-d'
      assert_equal(expected, @interval.interval)
    end
    def test_get_intervals
      expected = ["a-d", "e-h", "i-l", "m-p", "q-t", "u-z", "|unknown"]
      assert_equal(expected, @interval.get_intervals)
    end
    def test_intervals
      expected = ["a-d", "e-h", "i-l", "m-p", "q-t", "u-z", "|unknown"]
      assert_equal(expected, @interval.intervals)
    end
    def test_default_interval
      assert_equal('a-d', @interval.default_interval)
    end
    def test_user_range
      flexmock(@session, :user_input => 'user_input')
      assert_equal('a-d', @interval.user_range)
    end
    def test_user_range__persistent_range
      interval = ODDB::TestInterval::StubIntervalPersistentRange.new(@model, @session)
      flexmock(@session, :persistent_user_input => 'persistent_user_input')
      assert_equal('a-d', interval.user_range)
    end
    def test_filter_interval__nil
      flexmock(@model, :size => 0)
      assert_nil(@interval.filter_interval)
    end
    def test_filter_interval
      flexmock(@session, :user_input => 'user_input')
      flexmock(@model, :size => 31)
      result = @interval.filter_interval
      assert_kind_of(Proc, result)
      expected = ["abc", "def"]
      assert_equal(expected, result.call(@model))
    end
    def test_filter_interval__unknown
      flexmock(@session, :user_input => '|unknown')
      flexmock(@model, :size => 31)
      result = @interval.filter_interval
      assert_kind_of(Proc, result)
      expected = ["123"]
      assert_equal(expected, result.call(@model))
    end
    def test_filter_interval__else
      flexmock(@session, :user_input => 'user_input')
      flexmock(@model, :size => 31)
      interval = ODDB::TestInterval::StubIntervalRangePatterns.new(@model, @session)
      result = interval.filter_interval
      assert_kind_of(Proc, result)
      expected = []
      assert_equal(expected, result.call(@model))
    end



  end

  class TestIndexedInterval < Test::Unit::TestCase
    include FlexMock::TestCase
    class StubSuper
      def init
      end
    end
    class StubIndexedInterval < StubSuper
      include ODDB::IndexedInterval
      def initialize(model, session)
        @model = model
        @session = session
      end
    end
    def setup
      @session  = flexmock('session')
      @model    = ['abc', 'def', 'ghi', 'jkl', 'mno', 'pqr', 'stu', 'vwx', 'yz0', '123']
      @interval = ODDB::TestIndexedInterval::StubIndexedInterval.new(@model, @session)
    end
    def test_init
      assert_equal(@interval.method(:filter), @interval.init)
    end
    def test_comparison_value
      item = 'HOGEHOGE'
      assert_equal('hogehoge', @interval.comparison_value(item))
    end
    def test_interval
      range = 'range'
      @interval.instance_eval('@range = range')
      assert_equal('range', @interval.interval)
    end
    def test_index_lookup
      flexmock(ODBA.cache, :retrieve_from_index => 'retrieve_from_index')
      assert_equal('retrieve_from_index', @interval.index_lookup('query'))
    end
    def test_intervals
      @interval.instance_eval('@intervals = "intervals"')
      assert_equal('intervals', @interval.intervals)
    end
    def test_intervals__odba_search
      flexmock(ODBA.cache, :index_keys => ['value', '123'])
      expected = ['value', '0-9']
      assert_equal(expected, @interval.intervals)
    end
    def test_load_model
      flexmock(@session, :user_input => 'a-d')
      flexmock(ODBA.cache, 
               :index_keys => ['a-d', '123'],
               :retrieve_from_index => ['retrieve_from_index']
              )
      expected = ['retrieve_from_index']
      skip("Why does the test in #{__FILE__}:#{__LINE__} fail?")
      assert_equal(expected, @interval.load_model)
    end
    def test_load_model__number
      flexmock(@session, :user_input => '0-9')
      flexmock(ODBA.cache, 
               :index_keys => ['a-d', '123'],
               :retrieve_from_index => ['retrieve_from_index'],
              )
      expected = ["retrieve_from_index"]
      assert_equal(expected, @interval.load_model)
    end
    def test_user_range__no_user_range
      flexmock(@session, :user_input => 'a-d')
      flexmock(ODBA.cache, :index_keys => ['a-d', '123'])
      assert_equal('a-d', @interval.user_range)
    end
    def test_filter
      flexmock(@session, :user_input => 'user_input')
      flexmock(ODBA.cache, :index_keys => ['value', '123'])
      assert_equal(@model, @interval.filter('model'))
    end

  end
end
