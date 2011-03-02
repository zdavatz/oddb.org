#!/usr/bin/env ruby
# State::Admin::TestLogin -- oddb -- 13.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/admin/login'
require 'state/global'
require 'util/language'
require 'flexmock'

class StubResolvedRootState < ODDB::State::Global
	include ODDB::State::Admin::Root
end

module ODDB
	module State
		module Admin
module Root
	remove_const :RESOLVE_STATES
	RESOLVE_STATES = {
		[:resolve] =>	StubResolvedRootState,
	}
end

class TestTransparentLoginState < Test::Unit::TestCase
  include FlexMock::TestCase
	class StubSession
		def app
			@app ||= StubApp.new
		end
		def login
			StubUser.new
		end
	end
	class StubApp
		attr_accessor :state_transp_called
		def initialize
			@state_transp_called = false
		end
		def company(oid)
			@companies[oid.to_i]
		end
		def galenic_group(oid)
			@galenic_groups[oid.to_i]
		end
	end
	class StubUser
		def viral_module
			State::Admin::Root
		end
	end
	class StubGalenicGroup
		include Language
	end

	def setup
		@session = StubSession.new
	end

	def test_transparent_login
    flexstub(ODBA.cache) do |cache|
      cache.should_receive(:next_id).and_return(123)
    end
    user = flexmock('user') do |usr|
      usr.should_receive(:valid?)
      usr.should_receive(:allowed?)
    end
    flexstub(@session) do |ses|
      ses.should_receive(:login).and_return(user)
    end
		model = StubGalenicGroup.new
		pointer = Persistence::Pointer.new([:resolve, 3])
		model.pointer = pointer
		state = State::Admin::TransparentLogin.new(@session, model)
    newstate = flexmock('newstate') do |sta|
      sta.should_receive(:extend)
    end
    klass = flexmock('klass') do |klass|
      klass.should_receive(:new).and_return(newstate)
    end
    flexstub(state) do |sta|
      sta.should_receive(:resolve_state).and_return(klass)
    end
		expected = state.login
		assert_equal(expected, state.login)
	end
end
		end
	end
end
