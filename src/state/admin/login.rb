#!/usr/bin/env ruby
# State::Admin::Login -- oddb -- 25.11.2002 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'state/admin/root'
require 'state/user/invalid_user'
require 'view/admin/login'

module ODDB
	module State
		module Admin
module LoginMethods
	def login
		if(user = @session.login)
			autologin(user)
		end
	end
	private
	def autologin(user, default=@previous)
		newstate = if(user.valid?)
			des = @session.desired_state
			@session.desired_state = nil
			des || default || trigger(:home)
		else
			State::User::InvalidUser.new(@session, user)
		end
		if(viral = user.viral_module)
			newstate.extend(viral)
		end
		newstate
	end
end
class Login < State::Global
	DIRECT_EVENT = :login_form
	VIEW = View::Admin::Login
	SNAPBACK_EVENT = nil
end
class TransparentLogin < State::Admin::Login
	attr_accessor :desired_event
	def login
		if(user = @session.login)
			if(viral = user.viral_module)
				self.extend(viral)
			end
			if(@model.respond_to?(:pointer))
				klass = resolve_state(@model.pointer)
				newstate = klass.new(@session, @model)
				newstate.extend(@viral_module)
				newstate
			else
				trigger(@desired_event)
			end
		end
	end
end
		end
	end
end
