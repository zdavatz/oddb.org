#!/usr/bin/env ruby
# State::Drugs::OrphanedFachinfos -- oddb -- 11.12.2003 -- rwaltert@ywesee.com

require 'view/drugs/orphaned_fachinfos'
require 'util/interval'

module ODDB
	module State
		module Drugs
class OrphanedFachinfos < State::Drugs::Global
	include Interval
	DIRECT_EVENT = :orphaned_fachinfos
	PERSISTENT_RANGE = true
	VIEW = View::Drugs::OrphanedFachinfos
	def symbol
		:name 
	end
end
		end
	end
end
