#!/usr/bin/env ruby
# State::Admin::TestRoot -- oddb -- 13.10.2003 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/admin/root'
require 'state/drugs/init'
require 'state/global'
require 'util/persistence'
require 'state/admin/login'

module ODDB
	module State
		module Admin
class StubResolved; end
class StubResolvedState < State::Admin::Global; end
class StubResolvedRootState < State::Admin::Global
	include State::Admin::Root
end
module Root
	remove_const :RESOLVE_STATES
	RESOLVE_STATES = {
		[:resolve] =>	State::Admin::StubResolvedRootState,
	}
end
		end
		module Drugs
class Init < State::Drugs::Global
	RESOLVE_STATES = {
		[:resolve] =>	State::Admin::StubResolvedState
	}
end
		end

		module Admin
class TestRootState < Test::Unit::TestCase 
	class StubSession
		attr_accessor :user_input
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
		def logout
		end
	end
	class StubApp
		def invoice(key)
			@invoice_result
		end
	end
	class StubPointer
		def resolve(app)
			@model ||= State::Admin::StubResolved.new
		end
		def skeleton
			[:resolve]
		end
	end
	class TestState
		attr_accessor :session
		include State::Admin::Root
	end
	def setup
		@session = StubSession.new
		@state = State::Drugs::Init.new(@session, @session)
	end
	def test_resolve_root_state
		pointer = Persistence::Pointer.new([:resolve, "foo", "bar"])
		assert_equal(State::Admin::StubResolvedState, @state.resolve_state(pointer))
		@state.extend(State::Admin::Root)
		assert_equal(State::Admin::StubResolvedRootState, @state.resolve_state(pointer))
	end
	def test_root_state
		@state.extend(State::Admin::Root)
		assert(@state.is_a?(State::Admin::Root), 'extend did not work')
		state = @state.trigger(:login_form)
		assert_equal(State::Admin::Login, state.class)
		assert(state.is_a?(State::Admin::Root), 'trigger did not pass on RootState')
		newstate = state.trigger(:resolve)
		assert_equal(State::Admin::StubResolvedRootState, newstate.class)
		state = state.trigger(:logout)
		assert_equal(State::Drugs::Init, state.class)
		assert(!state.is_a?(State::Admin::Root), 'should not include RootState after logout')
	end
	def test_new_registration
		@state.extend(State::Admin::Root)
		regstate = @state.new_registration
		assert_equal(nil, regstate.model.company)
	end
end
		end
	end
end
