#!/usr/bin/env ruby
# AmbiguousPatinfo -- oddb -- 06.11.2003 -- rwaltert@ywesee.com

require 'util/persistence'
require 'util/language'

module ODDB
	class AmbiguousPatinfo
		attr_accessor :meanings, :key
		include Persistence
	end
end
