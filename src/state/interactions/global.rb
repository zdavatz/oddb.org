#!/usr/bin/env ruby
# State::Interactions::Global -- oddb -- 23.08.2004 -- maege@ywesee.com

require 'state/global_predefine'

module ODDB
	module State
		module Interactions
class Global < State::Global
	ZONE = :interactions
	def zone_navigation
		[
			State::Interactions::Basket,
		]
	end
end
		end
	end
end
