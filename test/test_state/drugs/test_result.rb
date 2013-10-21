#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::TestResult -- oddb.org -- 06.07.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Drugs::TestResult -- oddb.org -- 11.03.2003 -- aschrafl@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
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

class TestResult <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :disabled? => nil)
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @state   = ODDB::State::Drugs::Result.new(@session, @model)
  end
	def test_empty_list
    model = flexmock('model') do |mod|
      mod.should_receive(:session=)
      mod.should_receive(:atc_classes).and_return([])
    end
		state = State::Drugs::Result.new(StubResultSession.new, model)
		state.sortby = [:size, :price, :mice]
    state.init
		assert_equal(ODDB::View::Drugs::EmptyResult, state.default_view)
	end
	def test_filter
    atc = flexmock('atc') do |atc|
      atc.should_receive(:package_count).and_return(1)
      atc.should_receive(:code)# .and_return(:atc)
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
      ses.should_receive(:set_cookie_input)
      ses.should_receive(:event)
    end
		state = State::Drugs::Result.new(session, model)
    state.init
		filter = state.filter
		assert_instance_of(Proc, filter)
		result = filter.call(nil)
		assert_equal([atc], result)
	end
	def test_filter__page
    atc = flexmock('atc') do |atc|
      atc.should_receive(:package_count).and_return(1)
      atc.should_receive(:code)
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
      ses.should_receive(:cookie_set_or_get).and_return('pages')
      ses.should_receive(:event).and_return(:search)
      ses.should_receive(:set_persistent_user_input)
      ses.should_receive(:set_cookie_input)
    end
		state = State::Drugs::Result.new(session, model)
    state.init
		filter = state.filter
		assert_instance_of(Proc, filter)
		result = filter.call(nil)
		assert_equal([atc], result)
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
  def test_page__search
    flexmock(@session, 
             :event      => :search,
             :user_input => nil,
             :set_persistent_user_input => nil
            )
    page = flexmock('page', :model= => nil)
    @state.instance_eval('@pages = [page]')
    assert_equal(page, @state.page)
  end
  def test_export_csv
    flexmock(@state, :creditable? => nil)
    assert_kind_of(ODDB::State::Drugs::RegisterDownload, @state.export_csv)
  end
  def test_export_csv__creditable
    flexmock(@state, :creditable? => true)
    assert_kind_of(ODDB::State::Drugs::PaymentMethod, @state.export_csv)
  end
  def test_limit_state
    atc_class = flexmock('atc_class', :active_packages => ['active_package'])
    model     = flexmock('drug', :atc_classes => [atc_class])
    flexmock(@model, :package_count => 'package_count')
    flexmock(@state, :_search_drugs => model)
    assert_kind_of(ODDB::State::Drugs::ResultLimit, @state.limit_state)
  end
  def test_limit_state__search_type
    atc_class = flexmock('atc_class', :active_packages => ['active_package'])
    flexmock(@model, 
             :package_count => 'package_count',
             :atc_classes => [atc_class]
            )
    flexmock(@state, :_search_drugs => @model)
    search_type = 'st_sequence'
    @state.instance_eval('@search_type = search_type')
    assert_kind_of(ODDB::State::Drugs::ResultLimit, @state.limit_state)
  end
  def test_package_count
    flexmock(@model, :package_count => 'package_count')
    assert_equal('package_count', @state.package_count)
  end
  def test_request_path
    request_path = 'request_path'
    @state.instance_eval('@request_path = request_path')
    assert_equal('request_path#best_result', @state.request_path)
  end
  module StubModSuper
    def search
      'search_super'
    end
  end
  def test_search
    @state.extend(StubModSuper)
    flexmock(@session, 
             :user_input => 'search_type', 
             :persistent_user_input => 'search_query',
             :request_path => 'request_path'
            )
    assert_equal('search_super', @state.search)
  end
  def test_search__else
    flexmock(@session, 
             :user_input => 'search_type', 
             :persistent_user_input => 'search_query',
             :request_path => 'request_path'
            )
    @state.instance_eval do 
      @search_type  = 'search_type'
      @search_query = 'search_query'
    end
    assert_kind_of(ODDB::State::Drugs::Result, @state.search)
  end

  def test_get_sortby
    flexmock(@session, :user_input => :dsp)
    assert_equal(nil, @state.get_sortby!)
  end
  def test_get_sortby__sortvalue
    flexmock(@session, :user_input => :dsp)
    sortby = [:most_precise_dose, :comparable_size, :price_public]
    @state.instance_eval('@sortby = sortby')
    assert_equal(nil, @state.get_sortby!)
  end
  def test_init
    atc_class = flexmock('atc_class', :package_count => 101, :code => nil)
    flexmock(@model, 
             :session=    => nil,
             :atc_classes => [atc_class],
             :overflow?   => true
            )
    @model.should_receive(:each).and_yield(atc_class)
    flexmock(@session, 
             :persistent_user_input => 'persistent_user_input',
             :cookie_set_or_get => 'pages',
             :set_cookie_input => nil,
            )
    assert_kind_of(Proc, @state.init)
  end
end

		end
	end
end
