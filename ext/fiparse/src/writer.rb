#!/usr/bin/env ruby
# Writer -- oddb -- 24.10.2003 -- rwaltert@ywesee.com

require 'util/html_parser'
require 'model/text'

module ODDB
	module FiParse
		class Writer < NullWriter
			attr_reader :iksnrs, :name
			def initialize
				super
				@target = nil
				@name = ''
				@section = @header = Text::Section.new 
				@chapters = []
				@templates = named_chapters [
					:company, :galenic_form, :switch
				]
			end
			def new_alignment(alignment)
				#puts "new_alignment: #{alignment}"
				target = if(@section)
					@section.next_paragraph
				end
				set_target(target)
			end
			def send_flowing_data(data)
				#	puts "send_flowing_data"
				@newline_target = nil
				(@target << data) unless(@target.nil?)
				#puts "****************************"
				#puts @target
			end
			def send_hor_rule
				#	puts "send_hor_rule"
				@chapter.clean! unless @chapter.nil?
				@chapter = nil
				@section = nil
				set_target(nil)
			end
			def send_line_break
				if(@target == @name)
					@name << "\n"
				elsif(@chapter == @galenic_form && @section)
					@section.subheading << "\n"
				elsif(@chapter && (@target == @chapter.heading \
					|| @chapter == @galenic_form))
					@chapter.heading << "\n"
				else
					@chapter.clean! unless(@chapter.nil? || @mozilla)
					@newline_target << "\n" unless(@newline_target.nil?)
					target = if(@section)
						@section.next_paragraph
					end
					set_target(target)
				end
			end
			def send_literal_data(data)
				#puts "send_literal_data: #{data}"
				if(@target)
					@target.preformatted!
					@target << data.gsub(/\r\n?/, "\n")
				end
			end
			def set_target(target)
				#puts "################### set_target ####################"
				#puts "chapter #{@chapter.class}:#{@chapter}"
				#puts "section: #{@section.class}:#{@section}"
				#if(@chapter)
					#puts "chapter.includes section? #{@chapter.sections.include? @section}"
				#end
				#if(@section)
					#puts "section.includes old target? #{@section.paragraphs.include? @target}"
					#puts "section.includes new target? #{@section.paragraphs.include? target}"
				#end
				#puts "old target: #{@target.class}:#{@target}"
				#puts "new target: #{target.class}:#{target}"
				#puts "old target == new target? #{@target == target}"
				@newline_target = @target unless(target == @target)
				@target = target
			end
			def named_chapter(name)
				self.instance_eval <<-EOS
					@#{name} = Text::Chapter.new
				EOS
			end
			def named_chapters(names)
				names.collect { |name|
					named_chapter(name)
				}
			end
			def next_chapter
				#puts "next_chapter!"
				#puts caller[0,3]
				if(chapter = @chapters.last)
					chapter.clean!
				end
				chapter = @templates.shift || Text::Chapter.new
				@chapters.push(chapter).last
			end
		end
	end
end
