#!/usr/bin/env ruby
# State::User::YweseeContact -- oddb -- 04.08.2003 -- mhuggler@ywesee.com

require 'state/user/global'
require 'view/user/yweseecontact'

module ODDB
	module State
		module User
class YweseeContact < State::User::Global
	DIRECT_EVENT = :ywesee_contact
	VIEW = View::User::YweseeContact
end
		end
	end
end
