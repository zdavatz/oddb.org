#!/usr/bin/env ruby
# State::Interactions::Global -- oddb -- 23.08.2004 -- maege@ywesee.com

require 'state/interactions/init'

module ODDB
	module State
		module Interactions
class Global < State::Global
	HOME_STATE = State::Interactions::Init
	ZONE = :interactions
	def zone_navigation
		[
			:help_link,
			:faq_link,
			State::Interactions::Basket,
		]
	end
end
		end
	end
end
