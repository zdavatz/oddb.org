#!/usr/bin/env ruby
# State::Admin::Global -- oddb -- 24.08.2004 -- maege@ywesee.com

require 'state/admin/init'

module ODDB
	module State
		module Admin
class Global < State::Global
	HOME_STATE = State::Admin::Init
	ZONE = :admin
end
		end
	end
end
