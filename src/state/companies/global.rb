#!/usr/bin/env ruby
# State::Companies::Global -- oddb -- 23.08.2004 -- maege@ywesee.com

require 'state/global_predefine'

module ODDB
	module State
		module Companies
class Global < State::Global
	ZONE = :companies
	def zone_navigation
		[
			State::Companies::CompanyList,
		]
	end
end
		end
	end
end
