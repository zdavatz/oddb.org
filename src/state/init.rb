#!/usr/bin/env ruby
# InitState -- oddb -- 22.10.2002 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'state/root'
require 'state/companyuser'
require 'view/search'
require 'view/login'

module ODDB
	class InitState < GlobalState
		DIRECT_EVENT = :home 
		VIEW = SearchView
	end
end
