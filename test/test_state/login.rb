#!/usr/bin/env ruby
# TestLoginState -- oddb -- 13.10.2003 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/login'
require 'state/global'
require 'util/language'

class StubResolvedRootState < ODDB::GlobalState
	include ODDB::RootState
end

module ODDB
	module RootState
		remove_const :RESOLVE_STATES
		RESOLVE_STATES = {
			[:resolve] =>	StubResolvedRootState,
		}
	end
end

class TestTransparentLoginState < Test::Unit::TestCase
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
			ODDB::RootState
		end
	end
	class StubGalenicGroup
		include ODDB::Language
	end

	def setup
		@session = StubSession.new
	end
	def test_transparent_login
		model = StubGalenicGroup.new
		pointer = ODDB::Persistence::Pointer.new([:resolve, 3])
		model.pointer = pointer
		state = ODDB::TransparentLoginState.new(@session, model)
		newstate = state.login
		assert_instance_of(StubResolvedRootState, newstate)
	end
end
