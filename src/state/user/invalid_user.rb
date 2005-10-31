#!/usr/bin/env ruby
# State::User::InvalidUser -- oddb -- 02.08.2005 -- hwyss@ywesee.com

require 'state/user/limit'
require 'view/user/invalid_user'
require 'state/all_zones'

module ODDB
	module State
		module User
class InvalidUser < Limit
	VIEW = View::User::InvalidUser
	include State::AllZones
end
		end
	end
end
