#!/usr/bin/env ruby
# LogoutState -- oddb -- 25.11.2002 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'view/search'

module ODDB
	class LogoutState < GlobalState
		DIRECT_EVENT = :logout
		VIEW = SearchView
	end
end
