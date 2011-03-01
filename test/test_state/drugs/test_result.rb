#!/usr/bin/env ruby
# State::Drugs::TestResult -- oddb -- 01.03.2011 -- mhatakeyama@ywesee.com
# State::Drugs::TestResult -- oddb -- 11.03.2003 -- aschrafl@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'define_empty_class'
require 'state/drugs/result'
require 'flexmock'

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
  include FlexMock::TestCase
	def test_empty_list
    model = flexmock('model') do |mod|
      mod.should_receive(:session=)
      mod.should_receive(:atc_classes).and_return([])
    end
		state = State::Drugs::Result.new(StubResultSession.new, model)
		state.sortby = [:size, :price, :mice]
    state.init
		assert_equal(View::Drugs::EmptyResult, state.default_view)
	end
	def test_filter
    atc = flexmock('atc') do |atc|
      atc.should_receive(:package_count).and_return(1)
    end
    model = flexmock('model') do |mod|
      mod.should_receive(:session=)
      mod.should_receive(:atc_classes).and_return([atc])
      mod.should_receive(:overflow?).and_return(true)
      mod.should_receive(:each).and_yield(atc)
    end
    session = StubResultSession.new
    flexstub(session) do |ses|
      ses.should_receive(:persistent_user_input)
      ses.should_receive(:cookie_set_or_get)
    end
		state = State::Drugs::Result.new(session, model)
    state.init
		filter = state.filter
		assert_instance_of(Proc, filter)
		result = filter.call(nil)
		assert_equal(model, result)
	end
	def test_page
    model = flexmock('model') 
    session = StubResultSession.new
    flexstub(session) do |ses|
      ses.should_receive(:event)
      ses.should_receive(:persistent_user_input)
    end
		state = State::Drugs::Result.new(session, model)
    page = flexmock('page') do |page|
      page.should_receive(:model=)
    end
    state.instance_eval('@pages = [page]')
		assert_equal(page, state.page)
	end
end
		end
	end
end
