#!/usr/bin/env ruby
# State::Companies::Init -- oddb -- 06.09.2004 -- maege@ywesee.com

require 'state/companies/global'
require 'view/companies/search'

module ODDB
	module State
		module Companies
class Init < State::Companies::Global
	VIEW = View::Companies::Search
	DIRECT_EVENT = :home	
end
		end
	end
end
