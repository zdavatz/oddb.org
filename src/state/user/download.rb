#!/usr/bin/env ruby
# State::User::Download -- ODDB -- 29.10.2003 -- hwyss@ywesee.com

require 'state/user/global'
require 'view/user/download'
require 'view/user/auth_info'

module ODDB
	module State
		module User
class Download < State::User::Global
	VOLATILE = true
	VIEW = View::User::Download
end
		end
	end
end
