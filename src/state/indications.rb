#!/usr/bin/env ruby
# IndicationsState -- oddb -- 03.07.2003 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'util/interval'
require 'view/indications'

module ODDB
	class IndicationsState < GlobalState
		include Interval
		VIEW = IndicationsView
		DIRECT_EVENT = :indications
		def symbol
			@session.language
		end
	end
end
