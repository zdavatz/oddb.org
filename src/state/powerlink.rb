#!/usr/bin/env ruby
# PowerLinkState -- ODDB -- 21.10.2003 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/powerlink'

module ODDB
	class PowerLinkState < GlobalState
		VIEW = PowerLinkView
		VOLATILE = true
	end
end
