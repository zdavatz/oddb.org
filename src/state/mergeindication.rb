#!/usr/bin/env ruby
# MergeIndicationState -- oddb -- 07.07.2003 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'view/mergeindication'

module ODDB
	class MergeIndicationState < GlobalState
		VIEW = MergeIndicationView
	end
end
