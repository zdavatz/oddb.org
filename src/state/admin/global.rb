#!/usr/bin/env ruby
# State::Admin::Global -- oddb -- 24.08.2004 -- maege@ywesee.com

require 'state/global_predefine'

module ODDB
	module State
		module Admin
class Global < State::Global
	ZONE = :admin
end
		end
	end
end
