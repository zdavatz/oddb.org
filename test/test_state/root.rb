#!/usr/bin/env ruby
# TestRootState -- oddb -- 13.10.2003 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/root'
require 'state/init'
require 'state/global'
require 'util/persistence'
require 'state/login'

class StubResolved; end
class StubResolvedState < ODDB::GlobalState; end
class StubResolvedRootState < ODDB::GlobalState
	include ODDB::RootState
end
module ODDB
	class InitState < GlobalState
		RESOLVE_STATES = {
			[:resolve] =>	StubResolvedState
		}
	end
	module RootState
		remove_const :RESOLVE_STATES
		RESOLVE_STATES = {
			[:resolve] =>	StubResolvedRootState,
		}
	end
end

class TestRootState < Test::Unit::TestCase 
	class StubSession
		attr_accessor :user_input
		def app
			@app ||= StubApp.new
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
		def logout
		end
	end
	class StubApp; end
	class StubPointer
		def resolve(app)
			@model ||= StubResolved.new
		end
		def skeleton
			[:resolve]
		end
	end

	def setup
		@session = StubSession.new
		@state = ODDB::InitState.new(@session, @session)
	end
	def test_resolve_root_state
		pointer = ODDB::Persistence::Pointer.new([:resolve, "foo", "bar"])
		assert_equal(StubResolvedState, @state.resolve_state(pointer))
		@state.extend(ODDB::RootState)
		assert_equal(StubResolvedRootState, @state.resolve_state(pointer))
	end
	def test_root_state
		@state.extend(ODDB::RootState)
		assert(@state.is_a?(ODDB::RootState), 'extend did not work')
		state = @state.trigger(:login_form)
		assert_equal(ODDB::LoginState, state.class)
		assert(state.is_a?(ODDB::RootState), 'trigger did not pass on RootState')
		newstate = state.trigger(:resolve)
		assert_equal(StubResolvedRootState, newstate.class)
		state = state.trigger(:logout)
		assert_equal(ODDB::InitState, state.class)
		assert(!state.is_a?(ODDB::RootState), 'should not include RootState after logout')
	end
	def test_new_registration
		@state.extend(ODDB::RootState)
		regstate = @state.new_registration
		assert_equal(nil, regstate.model.company)
	end
end
