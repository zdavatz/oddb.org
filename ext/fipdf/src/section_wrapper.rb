#!/usr/bin/env ruby
# SectionWrapper -- oddb -- 15.03.2004 -- mwalder@ywesee.com

require 'delegate'
require 'paragraph_wrapper'

module ODDB
	module FiPDF
		class SectionWrapper < SimpleDelegator
			def initialize(section)
				@wrapper_class = ParagraphWrapper
				@section = section
				super
			end
			def each_paragraph(&block)
				#special call for first paragraph adding the subheading
				first = first_paragraph
				unless(first.nil?)
					block.call(first)
					paragraphs = @section.paragraphs.dup
					paragraphs.shift
					paragraphs.each { |paragraph|
						block.call(@wrapper_class.new(paragraph))
					}
				end
			end
			def need_new_page?(height, width, formats)
				fmt_subheading = formats[:section]
				#puts "height original #{height}"
				height_subheading = fmt_subheading.get_height(self.subheading, width)
				#puts "height subheading #{height_subheading}"
				height -= height_subheading 
				#puts "height - subheading  #{height}"
				
				(height <= 0) \
          || ((first = first_paragraph) \
					    && first.need_new_page?(height, width, formats))
			end
			def subheading
				(fix_subheading?) ? '' : "<i>" +  @section.subheading.strip + "</i>"
			end
			def first_paragraph
				return if(@section.paragraphs.empty?)
				first_paragraph = @section.paragraphs.first
				if(fix_subheading? && !@section.subheading.empty?)
					first_paragraph = Marshal.load(Marshal.dump(first_paragraph))
					first_paragraph.prepend(@section.subheading + " ", :italic)
				end
				@wrapper_class.new(first_paragraph)
			end
			def fix_subheading?
				@section.paragraphs.first.respond_to?(:prepend) \
					&& @section.subheading[-1] != ?\n
			end
		end
	end
end
