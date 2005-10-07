#!/usr/bin/env ruby
# State::Companies::SetPass -- oddb -- 22.07.2003 -- hwyss@ywesee.com 

require 'state/setpass'
require 'state/companies/global'
#require 'view/companies/setpass'

module ODDB
	module State
		module Companies
class SetPass < State::Companies::Global
	include State::SetPass
end
		end
	end
end
