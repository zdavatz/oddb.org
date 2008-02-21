#!/usr/bin/env ruby
# FachinfoDoc -- oddb -- 24.09.2003 -- rwaltert@ywesee.com

require 'rwv2/rwv2'
require 'fachinfo_writer'
require 'iconv'

module ODDB
	module FiParse
		class FachinfoDocWriter < FachinfoWriter
      attr_accessor :cutoff_fontsize
      def complete?
        @date && !@date.sections.empty?
      end
			def new_font(char_props, text=nil)
				if(@chapter_flag)
					@chapter_flag = nil
					if(@chapter == @switch)
					# switch between old and new (2001) FI-Schema
						set_templates(@chapter)
					elsif([@company, @galenic_form].include?(@chapter) \
						&& /Zusammensetzung|Composition/i.match(@chapter.heading))
						if(@chapter == @company)
							@company = nil
						end
						@composition = @chapter 
						@amzv = Text::Chapter.new
						@amzv.heading << '9.11.2001'
						@templates = named_chapters [
							:galenic_form, :indications, :usage, 
							:contra_indications, :restrictions,
							:interactions, :pregnancy, :driving_ability,
							:unwanted_effects, :overdose, :effects,
							:kinetic, :preclinic, :other_advice, :switch,
						]
					end
				end
				if(char_props.fontsize >= @cutoff_fontsize && @name.empty?)
					set_target(@name)
				#elsif(char_props.italic? && char_props.bold?)
				elsif(char_props.bold?)
          if(valid_chapter?(text))
            @chapter_flag = true
            @chapter = next_chapter
            @section = @chapter.next_section
            set_target(@chapter.heading)
          elsif(@chapter)
						@section = @chapter.next_section
						set_target(@section.subheading)
          end
				elsif(char_props.italic?)
					if(@chapter == @company)
						@chapter = next_chapter
					end
					if(@target.is_a?(Text::Paragraph) \
						&& !@target.empty? && !@target.preformatted?)
						@format = @target.set_format(:italic)
					elsif(@chapter)
						@section = @chapter.next_section
						set_target(@section.subheading)
					end
				elsif(@format && @target.is_a?(Text::Paragraph))
					@format = nil
					@target.set_format
        else
          text.lstrip!
          ## sometimes, ill-formated colons are not appended to a subheading. 
          #  This is fixed manually here:
          if(text[0] == ?:)
            send_flowing_data(":")
            text[0,1] = ''
          end
					if(@chapter && !@chapter.include?(@section))
						@section = @chapter.next_section
					end
					target = if(@section)
						@section.next_paragraph
					end
					set_target(target)
				end
			end
      def valid_chapter?(text)
        case text.strip
        when "", /Wirkstoffe/, /Hilfsstoffe/, /Klinische Wirksamkeit/, 
          /Atc.?code/i, /Wirkungsmechanismus/, /Absorption/, /Metabolismus/,
          /Haltbarkeit/, /Lagerung/, /Handhabung/, /^-/
          false
        else
          true
				end
      end
		end
		class FachinfoSubDocumentHandler < Rwv2::SubDocumentHandler
			def initialize(text_handler)
				@text_handler = text_handler
			end
		end
    class FachinfoTableHandler < Rwv2::TableHandler
      attr_reader :rows
      def initialize
        @tables = []
        @rows = []
        @row_descriptors = []
      end
      def cell
        row.last
      end
      def cell_start
        row.push []
      end
      def cell_end
        #puts "cell_end"
      end
      def in_table?
        @in_table
      end
      def row
        @rows.last
      end
      def row_start(props)
        @in_table = true
        @row_descriptors.push props
        @rows.push []
      end
      def row_end
        @in_table = false
      end
      def send_flowing_data(text)
        cell << text
      end
    end
		class FachinfoTextHandler < Rwv2::TextHandler
			CHARS_PER_INCH = 14
			TWIPS_PER_CHAR =  (72*20 / CHARS_PER_INCH ).to_i
			DEFAULT_TAB_WIDTH = 720
			attr_reader :writers, :table_handler, :max_fontsize
      attr_accessor :cutoff_fontsize
			def initialize
				@writers = []
        @table_handler = FachinfoTableHandler.new
        @cutoff_fontsize = 40
        @max_fontsize = 0
        @iconv = Iconv.new('latin1//TRANSLIT//IGNORE', 'utf16')
			end
			def paragraph_end
				unless(@writer.nil?)
					if(@preformatted)
						@writer.send_literal_data("\n")
					else
						@current_char_props = nil
						@writer.send_flowing_data("\n")
						@writer.send_line_break
					end
				end
			end
			def paragraph_start(paragraph_props)
				tabs = paragraph_props.tab_descriptors
				unless(tabs.any? { |tab| tab.position > 9000})
					@tabs = tabs
				else
					@tabs = []
				end
			end
      def run_of_text(text, char_props)
        text = @iconv.iconv(text)
				# remove M$-Word special-chars
				text.tr!("\031\036\034\023", "'\"\"-")
        text.gsub!(/,,/, '"')
        text.split(/\v/).each_with_index { |run, idx|
          if(idx > 0 && @writer)
            @writer.send_line_break
          end
          _run_of_text(run, char_props)
        }
      end
			def _run_of_text(text, char_props)
        #puts sprintf("%2i %s -> %s",char_props.fontsize, same_font?(@current_char_props, char_props), text[0,10])
				if(!same_font?(@current_char_props, char_props))
					if(char_props.fontsize >= @cutoff_fontsize \
             && (@writer.nil? || @writer.complete?))
            @writer = FachinfoDocWriter.new
            @writer.cutoff_fontsize = @cutoff_fontsize
            @writers.push(@writer)
          end
          @max_fontsize = [@max_fontsize, char_props.fontsize].max
				end
				if(/^-{5,}$/.match(text))
					@preformatted = text.length
				elsif(@preformatted && (text.length > @preformatted))
					@preformatted = nil
					@current_char_props = nil
				elsif(@preformatted \
					&& !same_font?(@current_char_props, char_props))
					@preformatted = nil
				end
				unless(@writer.nil?)
					unless(same_font?(@current_char_props, char_props))
						@writer.new_font(char_props, text)
					end
					if(@preformatted)
						@writer.send_literal_data(expand_tabs(text))
          #elsif(@table_handler.in_table?)
          #  @table_handler.send_flowing_data(text)
					else
						@writer.send_flowing_data(text)
					end
				end
				@current_char_props = char_props
			end
			private
			def expand_tabs(text)
				while(pos = text.index("\t")) do
					twips = pos * TWIPS_PER_CHAR
					next_tab = @tabs.select { |tab|
						tab.position > twips
					}.sort_by { |tab|
						tab.position
					}.first
					next_pos, align = if(next_tab.nil?)
						((twips / DEFAULT_TAB_WIDTH) + 1) * DEFAULT_TAB_WIDTH
					else
						[next_tab.position, next_tab.align]
					end
					distance = ((next_pos - twips) / TWIPS_PER_CHAR) + 1
					if(align == Rwv2::TabDescriptor::ALIGN_CENTER)
						end_pos = text.index("\t", pos.next) || (text.length - 1)
						text_length = end_pos - pos
						distance = [distance - (text_length / 2), 1].max
					end
					text[pos,1] = " " * distance
				end
				text
			end
			def same_font?(font1, font2)
				font1.class == font2.class \
				&& font1.fontsize == font2.fontsize \
					&& font1.bold? == font2.bold? \
					&& font1.italic? == font2.italic?
			end
		end
	end
end
