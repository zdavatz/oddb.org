#!/usr/bin/env ruby
# State::User::PassThru -- ODDB -- 21.10.2003 -- hwyss@ywesee.com

require 'state/user/global'
require 'view/user/passthru'

module ODDB
	module State
		module User
class PassThru < State::User::Global
	VIEW = View::User::PassThru
	VOLATILE = true
end
		end
	end
end
