#!/usr/bin/env ruby
# State::Admin::IncompleteRegs -- oddb -- 19.06.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'view/admin/incompleteregistrations'

module ODDB
	module State
		module Admin
class IncompleteRegs < State::Admin::Global
	ARCHIVE_PATH = File.expand_path('../../data', File.dirname(__FILE__))
	DIRECT_EVENT = :incomplete_registrations
	VIEW = View::Admin::IncompleteRegistrations
end
		end
	end
end
