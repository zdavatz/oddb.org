#!/usr/bin/env ruby
# State::Admin::OrphanedFachinfos -- oddb -- 11.12.2003 -- rwaltert@ywesee.com

require 'view/admin/orphaned_fachinfos'
require 'util/interval'

module ODDB
	module State
		module Admin
class OrphanedFachinfos < State::Admin::Global
	DIRECT_EVENT = :orphaned_fachinfos
	PERSISTENT_RANGE = true
	VIEW = View::Admin::OrphanedFachinfos
	FILTER_THRESHOLD = 0
	include Interval
	def init
		filter_interval
	end
	def symbol
		:name 
	end
end
		end
	end
end
