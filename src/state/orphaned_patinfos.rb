#!/usr/bin/env ruby
# Orphaned_pantinfos -- oddb -- 20.11.2003 -- rwaltert@ywesee.com

require 'view/orphaned_patinfos'
require 'util/interval'

module ODDB
	class OrphanedPatinfosState < GlobalState
		include Interval
		DIRECT_EVENT = :orphaned_patinfos
		PERSISTENT_RANGE = true
		VIEW = OrphanedPatinfosView
		def symbol
			:names
		end
	end
end
