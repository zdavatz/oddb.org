#!/usr/bin/env ruby
# Text -- oddb -- 10.09.2003 -- rwaltert@ywesee.com

require 'util/persistence'
require 'util/language'

module ODDB
	module Text
		class ImageLink
			attr_accessor :src
			def attributes
				{ 'src'	=>	@src }
			end
			def empty?
				@src.nil?
			end
			def to_s
				"(image)"
			end
			alias :text :to_s
		end
		class Format
			attr_accessor :start, :end, :values
			def initialize(*args)
				@values = args
				@start = 0
				@end = -1
			end
			def bold?
				@values.include?(:bold)
			end
			def italic?
				@values.include?(:italic)
			end
			def range
				@start..@end
			end
			def symbol?
				@values.include?(:symbol)
			end
=begin
			def +(fmt)
				unless(fmt.is_a?(Array))
					fmt = [fmt]
				end
				Format.new(*(@values + fmt))
			end
			def -(fmt)
				unless(fmt.is_a?(Array))
					fmt = [fmt]
				end
				Format.new(*(@values - fmt))
			end
=end
		end
		class Paragraph
			SYMBOLS = {
				"\243"	=>	'<=',
				"\263"	=>	'>=',
			}
			attr_reader :text, :formats
			def initialize
				clear!
			end
			def augment_format(*args)
				set_format(*(@format.values + args))
			end
			def clear!
				@formats = []
				@raw_txt = ''
				@text = ''
				@preformatted = false
				set_format()
			end
			def empty?
				@text.empty?
			end
			def match(pattern)
				@text.match(pattern)
			end
			def preformatted!
				@preformatted = true
			end
			def preformatted?
				@preformatted
			end
			def prepend(text, *format_args)
				text_length = text.length
				@formats.each { |format|
					format.start += text_length
					unless(format.end < 0)
						format.end += text_length
					end
				}
				format = Text::Format.new(*format_args)
				format.end = (text_length - 1)
				@formats.unshift(format)
				@raw_txt = text + @raw_txt
				@text = @raw_txt.strip
			end
			def reduce_format(*args)
				set_format(*(@format.values - args))
			end
			def set_format(*args)
				unless(@format.nil?)
					if(@format.start == @text.length)
						@formats.pop
					else
						@format.end	= (@text.length - 1)
					end
				end
				@format = Text::Format.new(*args)
				@format.start = (@text.length)
				@formats.push(@format)
				@format
			end
			def to_s
				@formats.collect { |fmt|
					if(fmt.symbol?)
						str = @text[fmt.range]
						SYMBOLS.each { |sym, repl|
							str.gsub!(sym, repl)
						}
						str
					else
						@text[fmt.range]
					end
				}.join
			end
			def <<(text)
				@raw_txt << text
				@text = @raw_txt.strip
			end
		end
		class Section
			attr_accessor :subheading
			attr_reader		:paragraphs
			def initialize
				@subheading = ''
				@paragraphs = []
			end
			def clean!
				@subheading.gsub!(/(^\s*)|([ \t\r]*$)/, '')
				@paragraphs.delete_if { |paragraph| paragraph.empty? }
			end
			def empty?
				clean!
				@subheading.empty? && @paragraphs.empty?
			end
			def to_s
				lines = [ @subheading ] + @paragraphs
				lines.delete_if { |line| line.empty? }
				lines.join("\n")
			end
			def match(pattern)
				pattern.match(@subheading) or
				@paragraphs.collect { |par| 
					par.match(pattern) 
				}.compact.first
			end
			def next_image
				@paragraphs.push(ImageLink.new).last
			end
			def next_paragraph
				if((last = @paragraphs.last) && last.empty?)
					last
				else
					@paragraphs.push(Paragraph.new).last
				end
			end
		end
		class Chapter
			include Persistence
			ODBA_SERIALIZABLE = ["@sections"]
			attr_accessor :heading
			attr_accessor	:sections
			def initialize
				@heading = ''
				@sections = []
			end
			def clean!
				@heading.strip!
				@sections.each { |section| section.clean! }
				@sections.delete_if { |section| section.empty? }
			end
			def empty?
				clean!
				@heading.empty? && @sections.empty?
			end
			def include?(section)
				@sections.include?(section)
			end
			def to_s
				lines = [ @heading ] + @sections
				lines.delete_if { |line| line.empty? }
				lines.join("\n")
			end
			def match(pattern)
				pattern.match(@heading) or
				@sections.collect { |seq| 
					seq.match(pattern) 
				}.compact.first
			end
			def next_section
				if((last = @sections.last) && last.empty?)
					last
				else
					@sections.push(Section.new).last
				end
			end
			def paragraphs
				paragraphs = []
				@sections.each { |section|
					section.paragraphs.each { |par|
						paragraphs << par
					}
				}
				paragraphs
			end
			def ==(other)
				to_s == other.to_s
			end
		end
=begin
		class LanguageChapter < Chapter
			attr_reader :language
			def initialize(language)
				@language = language
				@sections = []
			end
		end
=end
		class Document
			include SimpleLanguage
			ODBA_SERIALIZABLE = [ '@descriptions' ]
		end
	end
end
