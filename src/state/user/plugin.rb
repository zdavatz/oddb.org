#!/usr/bin/env ruby
# State::User::Plugin -- oddb -- 11.08.2003 -- maege@ywesee.com

require 'state/user/global'
require 'view/user/plugin'

module ODDB
	module State
		module User
class Plugin < State::User::Global
	VIEW = View::User::Plugin
	DIRECT_EVENT = :plugin
end
		end
	end
end
