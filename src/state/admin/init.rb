#!/usr/bin/env ruby
# State::Admin::Init -- oddb -- 22.10.2002 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'view/admin/search'

module ODDB
	module State
		module Admin
class Init < State::Admin::Global
	VIEW = View::Admin::Search
	DIRECT_EVENT = :home_admin
end
		end
	end
end
