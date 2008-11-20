#!/usr/bin/env ruby
# LimitationText -- oddb -- 10.11.2003 -- mhuggler@ywesee.com

require 'util/language'

module ODDB
	class LimitationText
		include SimpleLanguage
		ODBA_SERIALIZABLE = [ '@descriptions' ]
    attr_accessor :code, :type, :niveau, :value, :valid_from
	end
end
