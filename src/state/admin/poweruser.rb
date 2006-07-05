#!/usr/bin/env ruby
# State::Admin::PowerUser -- oddb -- 29.07.2005 -- hwyss@ywesee.com

require 'state/admin/user'
require 'state/admin/login'

module ODDB
	module State
		module Admin
module PowerUser
	include State::Admin::User
  include State::Admin::LoginMethods
	def limited?
		super && !@session.user.allowed?('view', 'org.oddb')
	end
	def limit_state
    user = @session.user
    state = State::User::InvalidUser.new(@session, user)
		reconsider_permissions(user, state)
	end
end
		end
	end
end
