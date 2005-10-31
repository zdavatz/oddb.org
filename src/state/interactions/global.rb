#!/usr/bin/env ruby
# State::Interactions::Global -- oddb -- 23.08.2004 -- mhuggler@ywesee.com

require 'state/interactions/init'
require 'state/interactions/limit'
require 'state/interactions/basket'

module ODDB
	module State
		module Interactions
class Global < State::Global
	HOME_STATE = State::Interactions::Init
	ZONE = :interactions
	ZONE_NAVIGATION = [
		State::Interactions::Basket,
	]
	def limit_state
		State::Interactions::Limit.new(@session, nil)
	end
end
		end
	end
end
