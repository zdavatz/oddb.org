#!/usr/bin/env ruby
# State::Admin::OrphanedFachinfos -- oddb -- 11.12.2003 -- rwaltert@ywesee.com

require 'view/admin/orphaned_fachinfos'
require 'util/interval'

module ODDB
	module State
		module Admin
class OrphanedFachinfos < State::Admin::Global
	include Interval
	DIRECT_EVENT = :orphaned_fachinfos
	PERSISTENT_RANGE = true
	VIEW = View::Admin::OrphanedFachinfos
	def symbol
		:name 
	end
end
		end
	end
end
