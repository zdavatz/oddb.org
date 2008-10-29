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
      def gsub! *args
        @src.gsub! *args
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
      def subscript?
        @values.include?(:subscript)
      end
      def superscript?
        @values.include?(:superscript)
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
      def gsub! *args
        @raw_txt.gsub! *args
        @text.gsub! *args
      end
      def length
        @text.length
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
      def strip
        @text.strip
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
        if(@raw_txt[-1] == ?- && /^[a-z\336-\377]/.match(text))
          # if we're appending to a hyphen, and text starts with a lowercase
          # letter from iso-latin-1, we need to remove the hyphen
          @raw_txt.chop!
        end
				@raw_txt << text
				if(@preformatted)
					@raw_txt.gsub!(/[\n\r]+/, "\n")
          @raw_txt.gsub!(/(.*?)\t/) { |match|
            str = match[0..-2]
            str << (" " * (8 - (str.length % 8)))
          }
        else
          @raw_txt.gsub! /\t+/, ' '
				end
        if(@preformatted)
          @text = @raw_txt.rstrip
        else
          @text = @raw_txt.strip
        end
        self
			end
			def [](*args)
				@raw_txt[*args]
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
				gsub!(/\t+/, ' ')
				@paragraphs.delete_if { |paragraph| paragraph.empty? }
			end
			def empty?
				#clean! ## empty? should have no side-effects!
				@subheading.empty? && @paragraphs.empty?
			end
      def gsub! pattern, replacement
        @paragraphs.each do |paragraph| paragraph.gsub! pattern, replacement end
        @subheading.gsub! pattern, replacement
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
				@heading.gsub!(/\t+/, ' ')
				@sections.delete_if { |section| 
					section.clean!
					section.empty? 
				}
			end
			def empty?
				#clean! ## empty? should have no side-effects!
				@heading.empty? && @sections.empty?
			end
      def gsub! *args
        @sections.each do |section| section.gsub! *args end
        @heading.gsub! *args
      end
			def include?(section)
				@sections.include?(section)
			end
			def to_s
				lines = [ @heading ] + @sections.collect { |sec| sec.to_s }
				lines.delete_if { |line| line.empty? }
				lines.join("\n")
			end
			def to_search
        ODDB.search_term(to_s)
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
		class Document
			include SimpleLanguage
			ODBA_SERIALIZABLE = [ '@descriptions' ]
		end
    class Cell < Paragraph
      attr_accessor :col_span, :row_span
      def initialize(*args)
        @col_span = 1
        @row_span = 1
        super(*args)
      end
    end
    class Table
      attr_reader :rows
      def initialize(*args)
        super
        @rows = []
      end
      def cell(row, cell)
        @rows[row][cell]
      end
      def clean!
        @rows.each { |row|
          while((cell = row.last) && cell.empty?)
            row.pop
          end
        }
        while((row = @rows.last) && row.empty?)
          @rows.pop
        end
      end
      def column_widths
        @rows.inject([]) { |memo, row|
          row.each_with_index { |cell, idx|
            lens = cell.to_s.split("\n").collect { |part| part.length }
            candidate = lens.max.to_i / cell.col_span
            memo[idx] = [memo[idx].to_i, candidate].max
          }
          memo
        }
      end
      def current_cell
        current_row.last rescue nil
      end
      def current_row
        @rows.last rescue nil
      end
      def empty?
        @rows.flatten.all? { |cell| cell.strip.empty? }
      end
      def gsub! *args
        @rows.each do |row|
          row.each do |cell|
            cell.gsub! *args
          end
        end
      end
      def next_cell!
        cell = Cell.new
        @rows.last.push cell
        cell
      end
      def next_paragraph
        current_cell << "\n" if current_cell
      end
      def next_row!
        @rows.push []
      end
      def each_normalized(&block)
        wd = width
        @rows.each { |row|
          block.call(row + Array.new(wd - row.length))
        }
      end
      def to_s
        widths = column_widths
        @rows.collect { |row|
          lines = []
          parts = []
          heights = []
          chunks = row.collect { |cell| 
            chunk = cell.to_s.split("\n")
            heights.push chunk.size
            chunk 
          }
          height = heights.max
          chunks.each_with_index { |chunk, x_idx|
            height.times { |y_idx|
              (lines[y_idx] ||= '') << chunk[y_idx].to_s.ljust(widths.at(x_idx) + 2)
            }
          }
          lines
        }.flatten.join("\n")
      end
      def width
        @rows.collect { |row| row.length }.max  
      end
      def <<(str)
        current_cell << str
      end
    end
	end
end
