#!/usr/bin/env ruby
# FachinfoWrapper -- oddb -- 15.03.2004 -- mwalder@ywesee.com

require 'chapter_wrapper'
require 'delegate'

module ODDB
	module FiPDF
		class FachinfoWrapper < SimpleDelegator
			def initialize(fachinfo)
				@wrapper_class = ChapterWrapper
				@fachinfo = fachinfo
				super
			end
			def each_chapter(&block)
				@fachinfo.each_chapter { |chapter|
					block.call(@wrapper_class.new(chapter))
				}
			end
			def need_new_page?(height, width, formats)
				fmt_dname = formats[:drug_name]
				fmt_cname = formats[:company_name]
				height_dname = fmt_dname.get_height(name, width) + fmt_dname.margin
				height_cname = fmt_cname.get_height(@fachinfo.company_name, width)
				height = height - (height_dname + height_cname)
				(height <= 0) \
					|| first_chapter.need_new_page?(height, width, formats)
			end
			def name
				"<b>" + @fachinfo.name + "</b>"
			end
			def first_chapter
				@wrapper_class.new(@fachinfo.first_chapter)
			end
		end
	end
end
