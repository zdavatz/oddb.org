#!/usr/bin/env ruby
# State::User::Global -- oddb -- 24.08.2004 -- maege@ywesee.com

require 'state/user/init'

module ODDB
	module State
		module User
class Global < State::Global
	HOME_STATE = State::User::Init
	ZONE = :user
	def zone_navigation
		[
			State::User::MailingList,
			State::User::Plugin,
			State::User::DownloadExport,
		]
	end
end
		end
	end
end
