#!/usr/bin/env ruby
# SubstancesState -- oddb -- 25.05.2004 -- maege@ywesee.com

require 'state/global_predefine'
require 'util/interval'
require 'view/substances'

module ODDB
	class SubstancesState < GlobalState
		include Interval
		VIEW = SubstanceListView
		DIRECT_EVENT = :substances
	end
end
