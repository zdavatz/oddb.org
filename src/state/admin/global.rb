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
    links =	[ 
      ['create', 'org.oddb.registration', :new_registration],
      ['view', 'org.oddb.patinfo_stats', State::Admin::PatinfoStats],
      ['edit', 'org.oddb.model.!sponsor.*', State::Admin::Sponsor],
      ['edit', 'org.oddb.model.!indication.*', State::Admin::Indications],
      ['edit', 'org.oddb.model.!galenic_group.*', State::Admin::GalenicGroups],
      ['edit', 'org.oddb.model.!address.*', State::Admin::Addresses],
      ['view', 'org.oddb.patinfo_stats.associated', 
        State::Admin::PatinfoStatsCompanyUser],
      ['edit', 'yus.entities', State::Admin::Entities],
      ['edit', 'org.oddb.model.!galenic_group.*', State::Admin::CommercialForms],
    ]
    links.inject([]) { |memo, (action, item, link)|
      memo.push(link) if(@session.allowed?(action, item))
      memo
    }
	end
end
		end
	end
end
