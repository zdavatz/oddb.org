#!/usr/bin/env ruby
# Fachinfo -- oddb -- 26.10.2004 -- mwalder@ywesee.com rwaltert@ywesee.com

require	'fachinfo_writer'
require 'fachinfo_html'
require 'rpdf2txt/parser'

module ODDB
	module FiParse
		class FachinfoPDFWriter < Writer
			include FachinfoWriterMethods
			include Rpdf2txt::DefaultHandler
			def new_font(font)
				if(@font)
					self.add_text
				end
				@font = font
			end
			def add_text
				if(@font.bold? && @font.italic?)
					heading = self.src.strip
					unless(heading.empty?)
						@chapter = next_chapter
						@chapter.heading = heading
						set_templates(@chapter)
						@section = @chapter.next_section
					end
				elsif(@font.bold?)
					@name = self.src.strip
				elsif(@font.italic?)
					if(@fresh_paragraph)
						@section = @chapter.next_section
						@section.subheading << self.src
						@wrote_section_heading = true
					else
						@paragraph.set_format(:italic)
						@paragraph << self.src
						@paragraph.reduce_format(:italic)
					end
				else
					str_check = self.src.strip
					font_name = @font.basefont_name
					courier = !/courier/i.match(font_name).nil?
					symbol = !/symbol/i.match(font_name).nil?
					skip_paragraph = /documed|copyright/i.match(self.src)
					if(!@chapter.nil? && !str_check.empty? && !skip_paragraph)
						str = self.src
						@wrote_section_heading = false
						#for the first paragraph after a preformated paragraph
						if(!courier && @preformatted)
							@fresh_paragraph = true
						end
						if(@fresh_paragraph)
							@paragraph = @section.next_paragraph
						end
						if(symbol)
							@paragraph.set_format(:symbol)
							@symbol_format = true
						elsif(@symbol_format)
							@symbol_format = false
							@paragraph.reduce_format(:symbol)
						end
						if(courier)
							if(@paragraph.empty?)
								str.strip!
								@paragraph.preformatted!
							end
							@preformatted = true
							@paragraph << "\n"
						else
							str.gsub!("\n","")
							@preformatted = false
						end
						@paragraph << str
						@fresh_paragraph = false
					end
				end
				@src = ''
			end
			def send_flowing_data(data)
				self.src << data
			end
			def send_page
				self.add_text
			end
			def send_line_break
				self.src << "\n"
			end
			def send_paragraph
				if(@wrote_section_heading && self.src.strip.empty?)
					@section.subheading << "\n"
				end
				self.add_text
				unless(@preformatted)
					@fresh_paragraph = true
				end
			end
		end
	end
end
