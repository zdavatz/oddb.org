#!/usr/bin/env ruby
# GenericDefinitionState -- oddb -- 05.01.2004 -- maege@ywesee.com

require 'state/global_predefine'
require 'view/genericdefinition'

module ODDB
	class GenericDefinitionState < GlobalState
		VIEW = GenericDefinitionView
		VOLATILE = true
	end
end
