#!/usr/bin/env ruby
# State::Admin::TestCompanyUser -- oddb -- 07.10.2003 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/global'
require 'state/admin/companyuser'

module ODDB
	module State
		module Admin
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
		@state = State::Drugs::Init.new(@session, [1,11,2,22,3,33])
	end
	def test_extend_state
		@state.extend(State::Admin::CompanyUser)
		assert(@state.is_a?(State::Admin::CompanyUser), 'extend did not work')
	end
	def test_login
		@state.extend(State::Admin::CompanyUser)
		state = @state.trigger(:login_form)
		assert_equal(State::Admin::Login, state.class)
		assert(state.is_a?(State::Admin::CompanyUser), 'trigger did not pass on CompanyUserState')
	end
	def test_logout
		@state.extend(State::Admin::CompanyUser)
		state = @state.trigger(:logout)
		assert_equal(State::Drugs::Init, state.class)
		assert(!state.is_a?(State::Admin::CompanyUser), 'should not include CompanyUserState after logout')
		state = @state.trigger(:login)
	end
	def test_new_registration
		@state.extend(State::Admin::CompanyUser)
		regstate = @state.new_registration
		assert_equal('user_model', regstate.model.company_name)
	end
end
		end
	end
end
