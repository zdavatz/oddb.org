#!/usr/bin/env ruby
# HelpState -- oddb -- 21.08.2003 -- ywesee@ywesee.com

require	'state/global_predefine'
require	'view/help'

module ODDB
	class HelpState < GlobalState
		VIEW = HelpView
		VOLATILE = true
	end
end
