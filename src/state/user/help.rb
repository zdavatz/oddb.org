#!/usr/bin/env ruby
# State::User::Help -- oddb -- 21.08.2003 -- ywesee@ywesee.com

require	'state/user/global'
require	'view/user/help'

module ODDB
	module State
		module User
class Help < State::User::Global
	VIEW = View::User::Help
	VOLATILE = true
end
		end
	end
end
