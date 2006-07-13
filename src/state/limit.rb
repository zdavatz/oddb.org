#!/usr/bin/env ruby
# State::Limit -- oddb -- 28.10.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/admin/login'
require 'state/user/register_poweruser'
require 'view/limit'

module ODDB
	module State
		module Limit
VIEW = View::Limit
include State::Admin::LoginMethods
def Limit.price(days)
	QUERY_LIMIT_PRICES[days.to_i].to_f
end
def init
	@desired_input = @session.valid_input
end
def price(days)
	Limit.price(days)
end
		end
	end
end
