#!/usr/bin/env ruby
# OrphanedFachinfos -- oddb -- 11.12.2003 -- rwaltert@ywesee.com

require 'view/orphaned_fachinfos'
require 'util/interval'

module ODDB
	class OrphanedFachinfosState < GlobalState
		include Interval
		DIRECT_EVENT = :orphaned_fachinfos
		PERSISTENT_RANGE = true
		VIEW = OrphanedFachinfosView
		def symbol
			:name 
		end
	end
end
