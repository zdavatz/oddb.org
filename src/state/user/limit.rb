#!/usr/bin/env ruby
# State::User::Limit -- oddb -- 26.07.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/user/register_poweruser'
require 'view/user/limit'

module ODDB
	module State
		module User
class Limit < Global
	VIEW = View::User::Limit
	def Limit.price(days)
		QUERY_LIMIT_PRICES[days.to_i].to_f
	end
	def login
		if(user = @session.login)
			newstate = if(user.valid?)
				des = @session.desired_state
				@session.desired_state = nil
				des || trigger(:home)
			else
				State::User::InvalidUser.new(@session, user)
			end
			if(viral = user.viral_module)
				newstate.extend(viral)
			end
			newstate
		end
	end
end
class ResultLimit < Limit
	VIEW = View::User::ResultLimit
	attr_accessor :package_count
end
		end
	end
end
