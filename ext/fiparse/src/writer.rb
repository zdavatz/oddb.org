#!/usr/bin/env ruby
# Writer -- oddb -- 24.10.2003 -- rwaltert@ywesee.com

require 'util/html_parser'
require 'model/text'

module ODDB
	module FiParse
		class Writer < NullWriter
			attr_reader :iksnrs, :name, :chapters
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
				target = if(@section)
					@section.next_paragraph
				end
				set_target(target)
			end
			def send_flowing_data(data)
				@newline_target = nil
				(@target << data) unless(@target.nil?)
			end
			def send_hor_rule
				@chapter.clean! unless @chapter.nil?
				@chapter = nil
				@section = nil
				set_target(nil)
			end
			def send_line_break
				if(@target == @name)
          @name.strip!
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
				if(@target)
					@target.preformatted!
					@target << data.gsub(/\r\n?/, "\n")
				end
			end
			def set_target(target)
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
				if(chapter = @chapters.last)
					chapter.clean!
				end
				chapter = @templates.shift || Text::Chapter.new
				@chapters.push(chapter).last
			end
		end
	end
end
