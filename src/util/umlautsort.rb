#!/usr/bin/env ruby
# UmlautSort -- oddb -- 07.07.2003 -- mhuggler@ywesee.com

module ODDB
	module UmlautSort
		def sort_model
			if(self::class::SORT_DEFAULT && (@session.event != :sort))
				@model = @model.sort_by { |item| 
					umlaut_filter(item.send(self::class::SORT_DEFAULT))
				} 
			end
		end
		def umlaut_filter(itm)
			if itm.kind_of? String
				itm.tr(
					'äÄáÁàÀâÂçÇëËéÉèÈêÊüÜúÚùÙûÛ', 
					'aaaaaaaacceeeeeeeeuuuuuuuu'
					).downcase
			else
				itm
			end
		end
	end
end
