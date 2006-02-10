#!/usr/bin/env ruby
# Stage::PageFacade -- oddb -- 01.06.2004 -- mhuggler@ywesee.com

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
		class OffsetPageFacade < PageFacade
			attr_accessor :size, :offset
			def content
				"#{@offset.next} - #{@offset + @size}"
			end
		end
	end
end
