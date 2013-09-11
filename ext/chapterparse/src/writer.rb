#!/usr/bin/env ruby
# encoding: utf-8
# ChapterParse::Writer -- oddb -- 11.08.2005 -- ffricker@ywesee.com

require 'util/html_parser'
require 'model/text'

module ODDB
	module ChapterParse
		class Writer < NullWriter
			def initialize
				@chapter = Text::Chapter.new
				@section = @chapter.next_section
				@target = @section.next_paragraph
			end
			def chapter
				@chapter.clean!
				@chapter
			end
			def new_font(font)
				return if @table
				case font
				when [nil, 1, nil, nil]
					if(@target.is_a?(Text::Paragraph) \
						&& !(@target.empty? || @target.preformatted?))
						@target.set_format(:italic)
					else
						@section = @chapter.next_section
						@subheading = @target = @section.subheading
					end
				when [nil, nil, nil, 1]
					unless(preformatted?(@target))
						@target = @section.next_paragraph
						@target.preformatted!
					end
				else
					if(@target.is_a?(Text::Paragraph))
						unless(@target.preformatted?)
							@target.set_format()
						end
					else
						@target = @section.next_paragraph
					end
				end
			end
			def new_fonthandler(fh)
				if(@target.is_a?(Text::Paragraph))
					if(fh && fh.attribute('face') == 'Symbol')
						@target.augment_format(:symbol)
					else
						@target.reduce_format(:symbol)
					end
					if(fh && (align = fh.attribute('vertical-align')))
						@target.augment_format(align.to_sym)
					else
						@target.reduce_format(:superscript)
						@target.reduce_format(:subscript)
					end
				end
			end
			def new_tablehandler(th)
				if(@table)
					paragraph = @section.next_paragraph
					paragraph.preformatted!
					paragraph << @table.to_s
				end
				@table = @target = th
				if(th.nil?)
					@target = @section.next_paragraph
				end
			end
			def preformatted?(target)
				target.is_a?(Text::Paragraph) \
					&& target.preformatted?
			end
			def send_line_break
				if(!@table && (@target.empty? && @subheading) \
					|| @target == @section.subheading)
					@subheading << "\n"
					@subheading = nil
				end
				if(@table)
					@table.next_line
				elsif(preformatted?(@target))
					@target << "\n"
				else
					@target = @section.next_paragraph
				end
			end
			def send_flowing_data(data)
				if(preformatted?(@target))
					@target = @section.next_paragraph
				end
				@target << data.gsub(/\302\240/u, " ")
			end
			def send_literal_data(data)
				@target << data.gsub(/\302\240/u, " ").gsub(/\r\n?/u, "\n")
			end
		end
	end
end
