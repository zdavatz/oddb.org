#!/usr/bin/env ruby
# State::Admin::Logout -- oddb -- 25.11.2002 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'view/search'

module ODDB
	module State
		module Admin
class Logout < State::Admin::Global
	DIRECT_EVENT = :logout
	VIEW = View::Search
end
		end
	end
end
