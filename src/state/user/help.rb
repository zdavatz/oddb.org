#!/usr/bin/env ruby
# encoding: utf-8
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
