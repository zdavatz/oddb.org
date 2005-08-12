#!/usr/bin/env ruby
# State::Admin::PowerUser -- oddb -- 29.07.2005 -- hwyss@ywesee.com

require 'state/admin/user'

module ODDB
	module State
		module Admin
module PowerUser
	include State::Admin::User
	def limited?
		super && !@session.user.valid?
	end
	def limit_state
		State::User::InvalidUser.new(@session, @session.user)
	end
	def user_navigation
		[
			State::Admin::Logout,
		]
	end
end
		end
	end
end
