#!/usr/bin/env ruby
# State::Drugs::Global -- oddb -- 23.08.2004 -- maege@ywesee.com

require 'state/global_predefine'
require 'state/drugs/recentregs'
require 'state/drugs/atcchooser'

module ODDB
	module State
		module Drugs 
class Global < State::Global
	ZONE = :drugs
	def zone_navigation
		[
			State::Drugs::RecentRegs,
			State::Drugs::AtcChooser,
		]
	end
end
		end
	end
end
