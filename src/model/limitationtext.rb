#!/usr/bin/env ruby
# LimitationText -- oddb -- 10.11.2003 -- mhuggler@ywesee.com

require 'util/language'

module ODDB
	class LimitationText
		include SimpleLanguage
		ODBA_SERIALIZABLE = [ '@descriptions' ]
	end
end
