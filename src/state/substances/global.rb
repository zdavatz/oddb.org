#!/usr/bin/env ruby
# State::Subtances::Global -- oddb -- 23.08.2004 -- maege@ywesee.com

require 'state/substances/init'

module ODDB
	module State
		module Substances
class Global < State::Global
	HOME_STATE = State::Substances::Init
	ZONE = :substances
	def zone_navigation
		[
			:substances, :effective_substances
		]
	end
end
		end
	end
end
