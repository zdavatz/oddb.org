#!/usr/bin/env ruby
# State::Drugs::Limit -- oddb -- 28.10.2005 -- hwyss@ywesee.com

require 'state/limit'
require 'view/drugs/resultlimit'

module ODDB
	module State
		module Drugs
class Limit < Global
	include State::Limit
end
class ResultLimit < Limit
	VIEW = View::Drugs::ResultLimit
	attr_accessor :package_count
end
		end
	end
end
