#!/usr/bin/env ruby
# State::Analysis::Limit -- oddb.org -- 05.07.2006 -- sfrischknecht@ywesee.com

require 'state/limit'

module ODDB
	module State
		module Analysis
class Limit < Global
	include State::Limit
end
		end
	end
end
