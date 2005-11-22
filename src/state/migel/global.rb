#!/usr/bin/env ruby
# State::Migel::Global  -- oddb -- 04.10.2005 -- ffricker@ywesee.com

require 'state/migel/init'
require 'state/migel/limit'

module ODDB
	module State
		module Migel
class Global < State::Global
	HOME_STATE = State::Migel::Init
	ZONE = :migel
	def limit_state
		State::Migel::Limit.new(@session, nil)
	end
end
		end
	end
end
