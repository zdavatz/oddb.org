#!/usr/bin/env ruby
# State::Companies::Global -- oddb -- 23.08.2004 -- maege@ywesee.com

require 'state/companies/init'

module ODDB
	module State
		module Companies
class Global < State::Global
	HOME_STATE = State::Companies::Init
	ZONE = :companies
	def zone_navigation
		[
			:faq_link,
			State::Companies::CompanyList,
		]
	end
end
		end
	end
end
