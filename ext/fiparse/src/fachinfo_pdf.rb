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
				@fresh_paragraph = false
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
					# product-name
				elsif(@font.italic?)
					if(@fresh_paragraph)
						@section = @chapter.next_section
						@section.subheading << self.src
						#else
						# formatierung an paragraph
						#end
				else
					#self.src.gsub!(/Der Text wurde behördlich genehmigt und vom verantwortlichen Unternehmen zur Publikation durch die Documed AG freigegeben. Das Dokument in der hier vorliegenden Fassung wurde im [0-9]+. [0-9]+ erstellt und ist in gedruckter Form noch nicht veröffentlicht. (C) Copyright [0-9]+ by Documed AG, Basel. Die unberechtigte Nutzung und Weitergabe ist untersagt./, "")
					#self.src.gsub!(/Arzneimittel-Kompendium der Schweiz \(C\) Copyright [0-9]+ by Documed AG, Basel.[\s]+Seite [0-9]+ von [0-9]+/,"")
					str = self.src.strip
					if(!@chapter.nil? && !str.empty? && !/Copyright/i.match(str))
						#puts "str: #{str}"
						@paragraph = @section.next_paragraph
						@paragraph << str.gsub("\n", "")
					else
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
			def send_paragraph
				self.add_text
				@fresh_paragraph = true
			end
		end
	end
end
