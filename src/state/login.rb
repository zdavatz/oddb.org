#!/usr/bin/env ruby
# LoginState -- oddb -- 25.11.2002 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'state/root'
require 'view/login'

module ODDB
	class LoginState < GlobalState
		DIRECT_EVENT = :login_form
		VIEW = LoginView
		def login
			if(user = @session.login)
				newstate = user.home.new(@session, user)
				if(viral = user.viral_module)
					newstate.extend(viral)
				end
				newstate
			end
		end
	end
	class TransparentLoginState < LoginState
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
