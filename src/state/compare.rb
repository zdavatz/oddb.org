#!/usr/bin/env ruby
# CompareState -- oddb -- 20.03.2003 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'view/compare'

module ODDB
	class CompareState < GlobalState
		VIEW = CompareView
		VOLATILE = true
		def init
			if(@model.atc_class.nil?)
				@default_view = EmptyCompareView
			else
				@default_view = CompareView
			end
		end
	end
end
