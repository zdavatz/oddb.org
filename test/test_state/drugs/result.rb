#!/usr/bin/env ruby
# State::Drugs::TestResult -- oddb -- 11.03.2003 -- aschrafl@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/drugs/result'
require 'mock'

module ODDB
	module State
		module Drugs
class Result < State::Drugs::Global
	attr_accessor :sortby, :session
	attr_reader :model, :default_view, :filter
	public :page
	remove_const :REVERSE_MAP
	REVERSE_MAP = {
		:size		=> true,
		:price	=> false,
		:mice		=> false,
	}
	def model=(model)
		session = StubResultSession.new
		#@model = model.collect { |atc| AtcFacade.new(atc, session) }
	end
end
class StubResultPackage
	attr_reader :size, :price, :mice
	def initialize(size, price, mice, *args)
		@size, @price, @mice = size, price, mice
	end
	def name_base
		'abc'
	end
	def galenic_form
		'abc'
	end
	def dose
		10
	end
	def comparable_size
		10
	end
	def generic_type
		'generika'
	end
	def active?
		true
	end
end
class StubResultAtcFacade
	def initialize(atc)
		@atc = atc
	end
	def packages
		@atc.packages
	end
end
class StubResultAtc
	attr_writer :packages
	def active_packages
		@packages.dup
	end
	def package_count
		@packages.size
	end
end
class StubResultSession
	attr_accessor :user_input
	def initialize
		@user_input = {}
	end
	def user_input(key)
		@user_input[key]
	end
	def valid_values(key)
		[nil, 'generika', 'original']
	end
	def language 
		:to_s
	end
end
class TestResult < Test::Unit::TestCase
	def expect_init(mock, atc_classes)
		mock.__next(:session=) { "foo" }
		mock.__next(:atc_classes) { atc_classes}
		if(atc_classes.is_a?(Array) && !atc_classes.empty?)
			mock.__next(:atc_classes) { atc_classes }
			mock.__next(:atc_sorted) { atc_classes }
		end
	end
	def test_empty_list
		model = Mock.new("model")
		expect_init(model, nil)
		state = State::Drugs::Result.new(StubResultSession.new, model)
		state.sortby = [:size, :price, :mice]
		assert_equal(View::Drugs::EmptyResult, state.default_view)
		model.__verify
	end
	def test_filter
		p1 = StubResultPackage.new(1,2,3)
		p2 = StubResultPackage.new(3,2,1)
		atc = StubResultAtc.new
		atc.packages = [p1, p2]
		model = Mock.new("model")
		expect_init(model, Array.new(250, atc))
		state = State::Drugs::Result.new(StubResultSession.new, model)
		filter = state.filter
		assert_instance_of(Proc, filter)
		state.session.user_input = { :page=>0 }
		result = filter.call(nil)
		assert_instance_of(State::PageFacade, result)
		assert_equal(75, result.size)
		state.session.user_input = { :page=>3 }
		result = filter.call(nil)
		assert_instance_of(State::PageFacade, result)
		assert_equal(25, result.size)
	end
	def test_page
		p1 = StubResultPackage.new(1,2,3)
		p2 = StubResultPackage.new(3,2,1)
		atc = StubResultAtc.new
		atc.packages = [p1, p2]
		model = Mock.new("model")
		expect_init(model, Array.new(150, atc))
		state = State::Drugs::Result.new(StubResultSession.new, model)
		assert_instance_of(State::PageFacade, state.page)
		assert_equal(0, state.page.to_i)
		state.session.user_input = { :page => 1 }
		assert_equal(1, state.page.to_i)
		state.session.user_input = {}
		assert_equal(1, state.page.to_i)
	end
end
		end
	end
end
