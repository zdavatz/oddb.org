#!/usr/bin/env ruby
# State::Subtances::Global -- oddb -- 23.08.2004 -- maege@ywesee.com

require 'state/global_predefine'

module ODDB
	module State
		module Substances
class Global < State::Global
	ZONE = :substances
	def zone_navigation
		[]
	end
end
		end
	end
end
