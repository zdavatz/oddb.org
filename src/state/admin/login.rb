#!/usr/bin/env ruby
# State::Admin::Login -- oddb -- 25.11.2002 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'state/admin/root'
require 'view/admin/login'

module ODDB
	module State
		module Admin
class Login < State::Admin::Global
	DIRECT_EVENT = :login_form
	VIEW = View::Admin::Login
	def login
		if(user = @session.login)
			newstate = home
			if(viral = user.viral_module)
				newstate.extend(viral)
			end
			newstate
		end
	end
end
class TransparentLogin < State::Admin::Login
	def login
		if(user = @session.login)
			if(viral = user.viral_module)
				self.extend(viral)
				klass = resolve_state(@model.pointer)
				newstate = klass.new(@session, @model)
				newstate.extend(@viral_module)
				newstate
			end
		end
	end
end
		end
	end
end
