#!/usr/bin/env ruby
# State::User::Init -- oddb -- 06.09.2004 -- mhuggler@ywesee.com

require 'state/user/global'
require 'view/user/search'

module ODDB
	module State
		module User
class Init < State::User::Global
	VIEW = View::User::Search
	DIRECT_EVENT = :home_user
end
		end
	end
end
