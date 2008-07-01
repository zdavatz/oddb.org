#!/usr/bin/env ruby
# Format -- oddb -- 15.03.2004 -- rwaltert@ywesee.com

require 'pdf/writer'

module ODDB
	module FiPDF
		class Format
			attr_accessor :font, :fontsize, :spacing_before, 
				:differences, :size, :justification, :margin, :ypos
			attr_writer :spacing_before, :spacing_after
			attr_reader :writer
			WRITER_CLASS = PDF::Writer
			def initialize
				@writer = WRITER_CLASS.new
				@spacing_before = 0
				@spacing_after = 0
			end
			def line_count(text, width)
				return 0 if text.to_s.empty?
				@writer.select_font(@font, {
					:differences => @differences
				})
				text = text.dup
				line_count = 0
				text.each_line { |line|
					begin
						line_count += 1
						line = @writer.add_text_wrap(0, 0, width,\
							line, @size, @justification, 0, true)
					end while(!line.empty?)
				}
				line_count
			end
			def get_height(text, width)
				line_count(text, width) \
					* @writer.font_height(@size) \
          - spacing_before(text) - spacing_after(text)
			end
			def font_height(font)
				@writer.font_height(font)
			end
			def spacing_after(text)
				(text.to_s.strip.empty?) ? 0 : @spacing_after
			end
			def spacing_before(text)
				(text.to_s.strip.empty?) ? 0 : @spacing_before
			end
		end
	end
end
