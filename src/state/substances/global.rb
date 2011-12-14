#!/usr/bin/env ruby
# encoding: utf-8
# State::Subtances::Global -- oddb -- 23.08.2004 -- mhuggler@ywesee.com

require 'state/substances/init'

module ODDB
	module State
		module Substances
class Global < State::Global
	HOME_STATE = State::Substances::Init
	ZONE = :substances
	ZONE_NAVIGATION = [
		:substances, :effective_substances
	]
end
		end
	end
end
