#!/usr/bin/env ruby
# FachinfoDoc -- oddb -- 24.09.2003 -- rwaltert@ywesee.com

require 'rwv2/rwv2'
require 'fachinfo_writer'

module ODDB
	module FiParse
		class FachinfoDocWriter < FachinfoWriter
			def new_font(char_props)
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
				if(char_props.fontsize > 40)
					set_target(@name)
				#elsif(char_props.italic? && char_props.bold?)
				elsif(char_props.bold?)
					@chapter_flag = true
					@chapter = next_chapter
					@section = @chapter.next_section
					set_target(@chapter.heading)
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
					if(@chapter && !@chapter.include?(@section))
						@section = @chapter.next_section
					end
					target = if(@section)
						@section.next_paragraph
					end
					set_target(target)
				end
			end
		end
		class FachinfoSubDocumentHandler < Rwv2::SubDocumentHandler
			def initialize(text_handler)
				@text_handler = text_handler
			end
		end
		class FachinfoTextHandler < Rwv2::TextHandler
			CHARS_PER_INCH = 14
			TWIPS_PER_CHAR =  (72*20 / CHARS_PER_INCH ).to_i
			DEFAULT_TAB_WIDTH = 720
			attr_reader :writers
			def initialize
				@writers = []
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
				# remove M$-Word special-chars
				text.tr!("\031\036\034\023", "'\"\"-")
				if(!same_font?(@current_char_props, char_props) \
					&& char_props.fontsize > 40)
					@writer = FachinfoDocWriter.new
					@writers.push(@writer)
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
						@writer.new_font(char_props)
					end
					if(@preformatted)
						@writer.send_literal_data(expand_tabs(text))
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

