#!/usr/bin/env ruby
# LimitationTextState -- oddb -- 14.11.2003 -- maege@ywesee.com

require 'state/global_predefine'
require 'view/limitationtext'

module ODDB
	class LimitationTextState < GlobalState
		VIEW = LimitationTextView
	end
end
