#!/usr/bin/env ruby
# State::Drugs::Orphaned_pantinfos -- oddb -- 20.11.2003 -- rwaltert@ywesee.com

require 'view/drugs/orphaned_patinfos'
require 'util/interval'

module ODDB
	module State
		module Drugs
class OrphanedPatinfos < State::Drugs::Global
	include Interval
	DIRECT_EVENT = :orphaned_patinfos
	PERSISTENT_RANGE = true
	VIEW = View::Drugs::OrphanedPatinfos
	def symbol
		:names
	end
end
		end
	end
end
