#!/usr/bin/env ruby
# State::Limit -- oddb -- 28.10.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/user/register_poweruser'
require 'view/limit'

module ODDB
	module State
		module Limit
VIEW = View::Limit
def Limit.price(days)
	QUERY_LIMIT_PRICES[days.to_i].to_f
end
def init
	@desired_input = @session.valid_input
end
def price(days)
	Limit.price(days)
end
def login
	if(user = @session.login)
		newstate = if(user.valid?)
			des = @session.desired_state
			@session.desired_state = nil
			@session.valid_input.update(@desired_input)
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
	end
end
