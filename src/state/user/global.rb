#!/usr/bin/env ruby
# encoding: utf-8
# State::User::Global -- oddb -- 24.08.2004 -- mhuggler@ywesee.com

require 'state/user/init'
require 'state/user/mailinglist'
require 'state/user/plugin'
require 'state/user/download_export'

module ODDB
	module State
		module User
class Global < State::Global
	HOME_STATE = State::User::Init
	ZONE = :user
	ZONE_NAVIGATION = [
		State::User::MailingList,
		State::User::Plugin,
		State::User::DownloadExport,
	]
end
		end
	end
end
