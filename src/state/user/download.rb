#!/usr/bin/env ruby
# State::User::Download -- ODDB -- 29.10.2003 -- hwyss@ywesee.com

require 'state/user/global'
require 'view/user/download'

module ODDB
	module State
		module User
class Download < State::User::Global
	VIEW = View::User::Download
	VOLATILE = true
end
		end
	end
end
