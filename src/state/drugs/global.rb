#!/usr/bin/env ruby
# State::Drugs::Global -- oddb -- 23.08.2004 -- mhuggler@ywesee.com

require 'state/drugs/init'
require 'state/drugs/recentregs'
require 'state/drugs/atcchooser'

module ODDB
	module State
		module Drugs 
class Global < State::Global
	HOME_STATE = State::Drugs::Init
	ZONE = :drugs
	def zone_navigation
		[
			State::Drugs::RecentRegs,
			State::Drugs::AtcChooser,
			State::Drugs::Sequences,
		]
	end
end
		end
	end
end
