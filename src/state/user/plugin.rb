#!/usr/bin/env ruby
# encoding: utf-8
# State::User::Plugin -- oddb -- 11.08.2003 -- mhuggler@ywesee.com

require 'state/global_predefine'
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
