#!/usr/bin/env ruby
# -- oddb -- 07.02.2005 -- jlang@ywesee.com

module ODDB
	module MedData
		class EanFactory
			def initialize(start)
				@current = (start.to_i - 1).to_s
			end
			def next
				if(@current[-1] == ?9)
					@current.chop!
				end
				@current.next!
			end
			def clarify
				@current << '0'
			end
		end
	end
end
