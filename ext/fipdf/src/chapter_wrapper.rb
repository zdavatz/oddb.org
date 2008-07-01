#!/usr/bin/env ruby
# ChapterWrapper -- oddb -- 15.03.2004 -- mwalder@ywesee.com

require 'delegate'
require 'section_wrapper'

module ODDB
	module FiPDF
		class ChapterWrapper < SimpleDelegator
			def initialize(chapter)
				@wrapper_class = SectionWrapper
				@chapter = chapter
				super
			end
			def each_section(&block)
				@chapter.sections.each { |section|
					block.call(@wrapper_class.new(section))
				}
			end
			def need_new_page?(height, width, formats)
				fmt_heading = formats[:chapter]
				#puts "height original #{height}"
				#puts @chapter.heading
				height_heading = fmt_heading.get_height(@chapter.heading, width)
				#puts height_heading
				height = height - height_heading
				#puts "height minus heading height #{height}"
				first = first_section
				(height <= 0) \
					|| (!first.nil? \
					&& first.need_new_page?(height, width, formats))
			end
			def first_section
				unless(@chapter.sections.empty?)
					@wrapper_class.new(@chapter.sections.first)
				end
			end
		end
	end
end
