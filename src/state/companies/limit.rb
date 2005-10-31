#!/usr/bin/env ruby
# State::Companies::Limit -- oddb -- 31.10.2005 -- hwyss@ywesee.com

require 'state/limit'

module ODDB
	module State
		module Companies
class Limit < Global
	include State::Limit
end
		end
	end
end
