#!/usr/bin/env ruby
# TestCompanyUserState -- oddb -- 07.10.2003 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/global'
require 'state/companyuser'

class TestCompanyUserState < Test::Unit::TestCase
	class StubSession
		attr_accessor :user_input, :user
		def user_input(*keys); end
		def app; end
		def logout; end
		def user
			self
		end
		def model
			'user_model'
		end
	end

	def setup
		@session = StubSession.new
		@state = ODDB::InitState.new(@session, [1,11,2,22,3,33])
	end
	def test_extend_state
		@state.extend(ODDB::CompanyUserState)
		assert(@state.is_a?(ODDB::CompanyUserState), 'extend did not work')
	end
	def test_login
		@state.extend(ODDB::CompanyUserState)
		state = @state.trigger(:login_form)
		assert_equal(ODDB::LoginState, state.class)
		assert(state.is_a?(ODDB::CompanyUserState), 'trigger did not pass on CompanyUserState')
	end
	def test_logout
		@state.extend(ODDB::CompanyUserState)
		state = @state.trigger(:logout)
		assert_equal(ODDB::InitState, state.class)
		assert(!state.is_a?(ODDB::CompanyUserState), 'should not include CompanyUserState after logout')
		state = @state.trigger(:login)
	end
	def test_new_registration
		@state.extend(ODDB::CompanyUserState)
		regstate = @state.new_registration
		assert_equal('user_model', regstate.model.company_name)
	end
end
