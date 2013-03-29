#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Text -- oddb.org -- 29.03.2013 -- yasaka@ywesee.com
# ODDB::Text -- oddb.org -- 21.12.2011 -- mhatakeyama@ywesee.com
# ODDB::Text -- oddb.org -- 10.09.2003 -- rwaltert@ywesee.com

require 'util/persistence'
require 'util/language'
require 'util/searchterms'

module ODDB
	module Text
    class ImageLink
      attr_accessor :src, :style
      def attributes
        { 'src' => @src, 'style' => @style }
      end
      def clean!
      end
      def empty?
        @src.nil?
      end
      def gsub! *args, &block
        @src.gsub! *args, &block
      end
      def preformatted?
        true
      end
      def to_s opts={}
        "(image)"
      end
      def strip
        self
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
		end
		class Paragraph
			attr_reader :text, :formats
			def initialize
				clear!
			end
			def augment_format(*args)
				set_format(*(@format.values + args))
			end
      def clean!
        @text.gsub! /\t/u, ' '
        @raw_txt = nil
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
      def gsub! *args, &block
        @raw_txt.gsub! *args, &block if @raw_txt
        @text.gsub! *args, &block
      end
      def length
        @text.length
      end
			def match(pattern)
        pattern_s = pattern.to_s
        pattern_s.force_encoding('utf-8')
        pattern = Regexp.new(pattern_s)
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
				@raw_txt = text + (@raw_txt || @text)
				@text = @raw_txt.strip
			end
			def reduce_format(*args)
				set_format(*(@format.values - args))
			end
			def set_format(*args)
        len = @text.length
				unless(@format.nil?)
					if(@format.start == len)
						@formats.pop
					else
						@format.end	= (len - 1)
					end
				end
				@format = Text::Format.new(*args)
				@format.start = (len)
				@formats.push(@format)
				@format
			end
      def strip
        @text.strip
      end
			def to_s opts={}
				@formats.collect { |fmt|
          @text[fmt.range]
				}.join
			end
			def <<(text)
        @raw_txt ||= @text.dup
        if(!@preformatted \
           && /[‐­-]\s*$/u.match(@raw_txt) && /^[[:lower:]]/u.match(text))
          # if we're appending to a hyphen, and text starts with a lowercase
          # letter, we need to remove the hyphen
          @raw_txt.gsub! /[‐­-]\s*$/u, ''
        end
				@raw_txt << text.to_s
        @raw_txt.gsub!(/[\n\r]+/u, "\n")
        @raw_txt.gsub!(/^\n+/u, "")
				if(@preformatted)
          @raw_txt.gsub!(/(.*?)\t/u) { |match|
            str = match[0..-2]
            str << (" " * (8 - (str.length % 8)))
          }
        else
          @raw_txt.gsub! /\t+/u, ' '
				end
        if(@preformatted)
          @text = @raw_txt.dup
        else
          @text = @raw_txt.strip
        end
        self
			end
			def [](*args)
				(@raw_txt || @text)[*args]
			end
		end
    class Cell < Paragraph
      attr_accessor :col_span, :row_span
      def initialize(*args)
        @col_span = 1
        @row_span = 1
        super(*args)
      end
    end
    class MultiCell
      attr_accessor :col_span, :row_span
      attr_reader :contents
      def initialize(*args)
        @col_span = 1
        @row_span = 1
        clear!
      end
      def clean!
      end
      def clear!
        @contents = []
      end
      def empty?
        @contents.empty?
      end
      def length
        @contents.length
      end
      def << args
        @contents << args
        self
      end
      def [] *args
        @contents[*args]
      end
      def strip
        self
      end
      def text
        text = ''
        @contents.map do |content|
          text << content.text if content.is_a? Paragraph
        end
        text
      end
      def preformatted?
        false
      end
      def next_image
        image = ImageLink.new
        @contents.push(image).last
      end
      def next_paragraph
        last = @contents.last
        if last.is_a? Paragraph and last.empty?
          last
        else
          @contents.push(Paragraph.new).last
        end
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
        @rows.each do |row|
          row.each do |cell|
            cell.clean!
          end
        end
      end
      def column_widths # as pre-formatted paragraph
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
      def gsub! *args, &gsub
        @rows.each do |row|
          row.each do |cell|
            cell.gsub! *args, &gsub
          end
        end
      end
      def match(pattern)
        pattern_s = pattern.to_s
        pattern_s.force_encoding('utf-8')
        pattern = Regexp.new(pattern_s)
        @rows.collect { |row|
          row.join.match(pattern)
        }.compact.first
      end
      def next_cell!
        next_row! if @rows.empty?
        cell = Cell.new
        @rows.last.push cell
        cell
      end
      def next_image!
        image_cell = ImageLink.new
        @rows.last.push image_cell
        image_cell
      end
      def next_multi_cell!
        next_row! if @rows.empty?
        cell = MultiCell.new
        @rows.last.push cell
        cell
      end
      def next_paragraph
        current_cell << "\n" if current_cell
      end
      def next_row!
        row = []
        @rows.push row
        row
      end
      def each_normalized(&block)
        wd = width
        @rows.each { |row|
          block.call(row + Array.new(wd - row.length))
        }
      end
      def preformatted?
        true
      end
      def to_s opts={}
        widths = column_widths
        total_width = widths.inject do |a,b| a+b+2 end
        if (width = opts[:width]) && width < total_width
          factor = width.to_f / total_width
          widths.collect! do |w| (w * factor).floor end
          total_width = width
        end
        hr = '-' * total_width
        @rows.collect { |row|
          lines = []
          parts = []
          heights = []
          idx = 0
          chunks = row.collect { |cell| 
            chunk = wrap(cell.to_s, widths[idx], opts).split("\n")
            heights.push chunk.size
            idx += 1
            chunk 
          }
          height = heights.max
          chunks.each_with_index { |chunk, x_idx|
            height.times { |y_idx|
              (lines[y_idx] ||= '') << chunk[y_idx].to_s.ljust(widths.at(x_idx) + 2)
            }
          }
          lines.unshift hr
        }.flatten.push(hr).join("\n")
      end
      def width
        @rows.collect { |row| row.length }.max  
      end
      def <<(str)
        next_cell! unless current_cell
        current_cell << str
      end
      def wrap str, width, opts={}
        result = ''
        left, right = nil
        hyph = opts[:hyphenator]
        str.split("\n").each do |line|
          res = ''
          words = line.split(' ')
          while word = words.shift
            rlen = res.length
            if rlen + word.length > width
              if hyph
                left, right = hyph.hyphenate_to(word, width - rlen - 1)
              end
              if left
                result << res << left << "\n"
                words.unshift right
                res = ''
              elsif word.length > width && (cutoff = width - rlen - 2) > 0
                result << res << word[0, cutoff] << "-\n"
                words.unshift word[cutoff..-1]
                res = ''
              else
                result << res << "\n"
                words.unshift word
                res = ''
              end
            else
              res << word << ' '
            end
          end
          result << res << "\n"
        end
        result.strip
      end
    end
    class Section
      attr_accessor :subheading
      attr_reader    :paragraphs
      def initialize
        @subheading = ''
        @paragraphs = []
      end
      def clean!
        @paragraphs.compact!
        @subheading.gsub!(/(^\s*)|([ \t\r]*$)/u, '')
        @subheading.gsub!(/\t+/u, ' ')
        @paragraphs.delete_if { |paragraph| paragraph.empty? }
        @paragraphs.each do |paragraph| paragraph.clean! end
      end
      def empty?
        #clean! ## empty? should have no side-effects!
        @subheading.empty? && @paragraphs.empty?
      end
      def gsub! *args, &block
        @paragraphs.each do |paragraph| paragraph.gsub! *args, &block end
        @subheading.gsub! *args, &block
      end
      def to_s opts={}
        lines = [ @subheading ] + @paragraphs.collect do |par| par.to_s opts end
        lines.delete_if { |line| line.empty? }
        lines.join("\n")
      end
      def match(pattern)
        pattern_s = pattern.to_s
        pattern_s.force_encoding('utf-8')
        pattern = Regexp.new(pattern_s)
        pattern.match(@subheading) or
        @paragraphs.collect { |par|
          # @paragraphs contains also Class without Paragraph
          if par.respond_to?(:match)
            par.match(pattern)
          end
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
      def next_table
        @paragraphs.push(Table.new).last
      end
    end
    class Chapter
      include Persistence
      ODBA_SERIALIZABLE = ["@sections"]
      attr_accessor :heading
      attr_accessor  :sections
      def initialize
        @heading = ''
        @sections = []
      end
      def clean!
        @heading.strip!
        @heading.gsub!(/\t+/u, ' ')
        @sections.delete_if { |section|
          section.clean!
          section.empty?
        }
      end
      def empty?
        #clean! ## empty? should have no side-effects!
        @heading.empty? && @sections.empty?
      end
      def gsub! *args, &block
        @sections.each do |section| section.gsub! *args, &block end
        @heading.gsub! *args, &block
      end
      def include?(section)
        @sections.include?(section)
      end
      def to_s opts={}
        lines = [ @heading ] + @sections.collect { |sec| sec.to_s opts }
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
  end
end
