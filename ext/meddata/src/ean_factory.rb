#!/usr/bin/env ruby
# -- oddb -- 07.02.2005 -- jlang@ywesee.com

require 'model/ean13'

module ODDB
	module MedData
		class EanFactory
			def initialize(start, max=13)
				@current = (start.to_i - 1).to_s
				@max = max - 1
			end
			def next
				if(@current[-1] == ?9)
					@current.chop!
				end
				@current.next!
			end
			def clarify
				if(@current.size < @max)
					@current << '0'
				elsif(@current.size == @max)
					@current << Ean13.checksum(@current)
				else
					@current = @current[0,@max]
					self.next
				end
			end
		end
	end
end
