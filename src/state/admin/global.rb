#!/usr/bin/env ruby
# State::Admin::Global -- oddb -- 24.08.2004 -- maege@ywesee.com

require 'state/admin/init'
require 'state/admin/patinfo_stats'

module ODDB
	module State
		module Admin
class Global < State::Global
	HOME_STATE = State::Admin::Init
	ZONE = :admin
	def zone_navigation
		[
			State::Admin::PatinfoStats,
			State::Admin::Sponsor,
			State::Drugs::Indications,
			State::Drugs::GalenicGroups,
			State::Drugs::IncompleteRegs,
		]
	end
end
		end
	end
end
