#!/usr/bin/env ruby
# Stage::PageFacade -- oddb -- 01.06.2004 -- maege@ywesee.com

module ODDB
	module State
		class PageFacade < Array
			def initialize(int)
				super()
				@int = int
			end
			def next
				PageFacade.new(@int.next)
			end
			def previous
				PageFacade.new(@int-1)
			end
			def to_s
				@int.next.to_s
			end
			def to_i
				@int
			end
		end
	end
end
