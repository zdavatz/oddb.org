#!/usr/bin/env ruby
# State::Companies::Init -- oddb -- 06.09.2004 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/companies/search'

module ODDB
	module State
		module Companies
class Init < State::Companies::Global
	VIEW = View::Companies::Search
	DIRECT_EVENT = :home_companies	
end
		end
	end
end
