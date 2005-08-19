#!/usr/bin/env ruby
# State::Admin::Global -- oddb -- 24.08.2004 -- mhuggler@ywesee.com

require 'state/admin/init'
require 'state/admin/patinfo_stats'

module ODDB
	module State
		module Admin
class Global < State::Global
	HOME_STATE = State::Admin::Init
	ZONE = :admin
	def zone_navigation
		case @session.user
		when ODDB::RootUser
			[
				:new_registration,
				State::Admin::PatinfoStats,
				State::Admin::Sponsor,
				State::Admin::Indications,
				State::Admin::GalenicGroups,
				State::Admin::IncompleteRegs,
				State::Admin::Addresses,
			]
		when ODDB::AdminUser
			[
				:new_registration,
				State::Admin::PatinfoStats,
				State::Admin::Indications,
				State::Admin::GalenicGroups,
				State::Admin::IncompleteRegs,
			]
		else
			[
				:new_registration,
				State::Admin::GalenicGroups,
				State::Admin::PatinfoStatsCompanyUser,
			]
		end
	end
end
		end
	end
end
