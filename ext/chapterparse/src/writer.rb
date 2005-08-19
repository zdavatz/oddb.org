#!/usr/bin/env ruby
# ChapterParse::Writer -- oddb -- 11.08.2005 -- ffricker@ywesee.com


require 'model/text'

module ODDB
	module ChapterParse
		class DumbWriter
			def method_missing(symbol, *args)	
				puts "method '#{symbol}' called with arguments:"
				args.each { |arg|
					puts "- #{arg.inspect}"
				}
			end
		end
		class Writer 
			def initialize
				@chapter = Text::Chapter.new
				@section = @chapter.next_section
				@target = @section.next_paragraph
			end
			def chapter
				@chapter.clean!
				@chapter
			end
			def method_missing(symbol, *args)	
				puts "method '#{symbol}' called with arguments:"
				args.each { |arg|
					puts "- #{arg.inspect}"
				}
			end
			def new_font(font)
				case font
				when [nil, 1, nil, nil]
					if(@target.is_a?(Text::Paragraph) \
						&& !@target.empty?)
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
				end
			end
			def preformatted?(target)
				target.is_a?(Text::Paragraph) \
					&& target.preformatted?
			end
			def send_line_break
				puts "send_line_break"
				if((@target.empty? && @subheading) \
					|| @target == @section.subheading)
					puts "subheading!"
					@subheading << "\n"
					@subheading = nil
				end
				if(preformatted?(@target))
					@target << "\n"
				else
					@target = @section.next_paragraph
				end
			end
			def send_flowing_data(data)
				if(preformatted?(@target))
					@target = @section.next_paragraph
				end
				@target << data.tr("\240", " ")
			end
			def send_literal_data(data)
				@target << data.tr("\240", " ").tr("\n\r", '')
			end
		end
	end
end
