#!/usr/bin/env ruby
# State::Drugs::TestInit -- oddb -- 02.03.2011 -- mhatakeyama@ywesee.com
# State::Drugs::TestInit -- oddb -- 13.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/drugs/init'
require 'flexmock'
require 'htmlgrid/template'

module ODDB
	module State
    module Admin
      class Login < State::Global; end
    end
    module View
       class PublicTemplate < HtmlGrid::Template; end
       class Search < View::PublicTemplate; end
    end
		module Drugs
class StubResolved; end
class StubResolvedState < State::Drugs::Global; end
class Init < State::Drugs::Global
	public :get_sortby!, :compare_entries
	attr_accessor :sortby, :sort_reverse
	RESOLVE_STATES = {
		[:resolve] =>	StubResolvedState
	}
	REVERSE_MAP = {
		:to_f	=>	true,
	}
end

class TestInitState < Test::Unit::TestCase
  include FlexMock::TestCase
	class StubSession
		attr_accessor :user_input
		def app
			@app ||= StubApp.new
		end
		def login
			StubUser.new
		end
		def lookandfeel
			StubLookandfeel.new
		end
		def user_input(*keys)
			if(keys.size > 1)
				res = {}
				keys.each { |key|
					res.store(key, user_input(key))
				}
				res
			else
				key = keys.first
				(@user_input ||= {
					:pointer	=>	StubPointer.new
				})[key]
			end
		end
	end
	class StubApp
		def package_count
			18
		end
	end
	class StubPointer
		def resolve(app)
			@model ||= StubResolved.new
		end
		def skeleton
			[:resolve]
		end
	end
	class StubLookandfeel
		def attributes(key)
			{}
		end
		def base_url
			'http://test.oddb.org/de/gcc'
		end
		def enabled?(smb, default=nil)
			true
		end
		def event_url(foo, *bar)
		end
		def language_url(arg)
		end
		def lookup(key)
		end
		def navigation
			[]
		end
		def resource_global(key)
		end
		def resource_localized(key)
		end
	end
	class StubHome < State::Drugs::Global; end
	class StubUser
		def home
			StubHome
		end
		def viral_module
			State::Adming::Root
		end
	end

	def setup
		@session = StubSession.new
		@state = State::Drugs::Init.new(@session, @session)
	end
	def test_init_state
    view = flexmock('view') do |v|
      v.should_receive(:http_headers)
    end
    flexstub(ODDB::View::Drugs::Search) do |klass|
      klass.should_receive(:new).and_return(view)
    end
    assert_equal(view, @state.view)
	end
=begin
	def test_trigger_global
		newstate = @state.trigger(:login_form)
		assert_equal(State::Admin::Login, newstate.class)
		assert_equal(StubHome, newstate.trigger(:login).class)
	end
	def test_trigger_resolve
		session = StubSession.new
		state = State::Drugs::Init.new(session, session)
		newstate = state.trigger(:resolve)
		assert_equal(StubResolvedState, newstate.class)
	end
=end
	def test_get_sortby
		state = State::Drugs::Init.new(@session, [1,11,2,22,3,33])
		@session.user_input = { :sortvalue => :to_s }
		state.get_sortby!
		assert_equal([:to_s], state.sortby)
		assert_equal(nil, state.sort_reverse)
		@session.user_input = { :sortvalue => :to_i }
		state.get_sortby!
		assert_equal([:to_i, :to_s], state.sortby)
		assert_equal(nil, state.sort_reverse)
		@session.user_input = { :sortvalue => :to_i }
		state.get_sortby!
		assert_equal([:to_i, :to_s], state.sortby)
		assert_equal(true, state.sort_reverse)
		@session.user_input = { :sortvalue => :to_s }
		state.get_sortby!
		assert_equal([:to_s, :to_i], state.sortby)
		assert_equal(nil, state.sort_reverse)
		@session.user_input = { :sortvalue => :to_f }
		state.get_sortby!
		assert_equal([:to_f, :to_s, :to_i], state.sortby)
		assert_equal(true, state.sort_reverse)
		@session.user_input = { :sortvalue => :to_f }
		state.get_sortby!
		assert_equal([:to_f, :to_s, :to_i], state.sortby)
		assert_equal(false, state.sort_reverse)
	end
=begin
	def test_compare_entries
		state = State::Drugs::Init.new(@session, [1,11,2,22,3,33])
		state.sortby = [:to_s]
		assert_equal(-1, state.compare_entries(11,2))
		state.sortby = [:to_f]
		assert_equal(1, state.compare_entries(11,2))
		state.sortby = [:to_s]
		assert_equal(0, state.compare_entries('a', 'ä'))
	end
=end
	def test_sort
		state = State::Drugs::Init.new(@session, [1,11,2,22,3,33])
		@session.user_input = { :sortvalue => :to_i }
		state.sort
		assert_equal([:to_i], state.sortby)
		expected = [1,2,3,11,22,33]
		assert_equal(expected, state.model)
		state.sort
		assert_equal(expected.reverse, state.model)
		@session.user_input = { :sortvalue => :to_f }
		state.sort
		assert_equal(expected.reverse, state.model)
		state.sort
		@session.user_input = { :sortvalue => :to_s }
		state.sort
		expected = [1,11,2,22,3,33]
		assert_equal(expected, state.model)
	end
end
		end
	end
end
