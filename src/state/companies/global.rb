#!/usr/bin/env ruby
# State::Companies::Global -- oddb -- 23.08.2004 -- mhuggler@ywesee.com

require 'state/companies/init'

module ODDB
	module State
		module Companies
class Global < State::Global
	HOME_STATE = State::Companies::Init
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
