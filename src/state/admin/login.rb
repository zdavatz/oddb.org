#!/usr/bin/env ruby
# State::Admin::Login -- oddb -- 25.11.2002 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'state/admin/root'
require 'view/admin/login'

module ODDB
	module State
		module Admin
class Login < State::Global
	DIRECT_EVENT = :login_form
	VIEW = View::Admin::Login
	def login
		if(user = @session.login)
			newstate = @previous || trigger(:home)
			if(viral = user.viral_module)
				newstate.extend(viral)
			end
			newstate
		end
	end
end
class TransparentLogin < State::Admin::Login
	attr_accessor :desired_event
	def login
		if(user = @session.login)
			if(viral = user.viral_module)
				self.extend(viral)
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
end
