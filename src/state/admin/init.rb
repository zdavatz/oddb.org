#!/usr/bin/env ruby
# State::Admin::Init -- oddb -- 22.10.2002 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'view/admin/search'

module ODDB
	module State
		module Admin
class Init < State::Admin::Global
	VIEW = View::Admin::Search
	DIRECT_EVENT = :home
end
		end
	end
end
