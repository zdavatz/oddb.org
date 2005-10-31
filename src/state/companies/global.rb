#!/usr/bin/env ruby
# State::Companies::Global -- oddb -- 23.08.2004 -- mhuggler@ywesee.com

require 'state/companies/init'
require 'state/companies/limit'
require 'state/companies/companylist'

module ODDB
	module State
		module Companies
class Global < State::Global
	HOME_STATE = State::Companies::Init
	ZONE = :companies
	ZONE_NAVIGATION = [
		State::Companies::CompanyList,
	]
	def limit_state
		State::Companies::Limit.new(@session, nil)
	end
end
		end
	end
end
