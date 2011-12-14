#!/usr/bin/env ruby
# encoding: utf-8
# State::User::AuthInfo -- oddb -- 22.12.2004 -- hwyss@ywesee.com

require 'state/user/global'
require 'view/user/auth_info'

module ODDB
	module State
		module User
class AuthInfo < State::User::Global
	VOLATILE = true
	VIEW = View::User::AuthInfo
end
		end
	end
end
