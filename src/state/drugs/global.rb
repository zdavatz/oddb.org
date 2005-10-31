#!/usr/bin/env ruby
# State::Drugs::Global -- oddb -- 23.08.2004 -- mhuggler@ywesee.com

require 'state/drugs/init'
require 'state/drugs/recentregs'
require 'state/drugs/atcchooser'
require 'state/drugs/sequences'
require 'state/drugs/limit'

module ODDB
	module State
		module Drugs 
class Global < State::Global
	HOME_STATE = State::Drugs::Init
	ZONE = :drugs
	ZONE_NAVIGATION = [
		State::Drugs::RecentRegs,
		State::Drugs::AtcChooser,
		State::Drugs::Sequences,
	]
	def limit_state
		State::Drugs::Limit.new(@session, nil)
	end
end
		end
	end
end
