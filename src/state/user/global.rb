#!/usr/bin/env ruby
# State::User::Global -- oddb -- 24.08.2004 -- maege@ywesee.com

require 'state/global_predefine'

module ODDB
	module State
		module User
class Global < State::Global
	ZONE = :user
	def zone_navigation
		[
			State::User::MailingList,
			State::User::Plugin,
			State::User::YamlExport,
		]
	end
end
		end
	end
end
