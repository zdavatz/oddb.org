#!/usr/bin/env ruby
# Fachinfo -- oddb -- 26.10.2004 -- mwalder@ywesee.com rwaltert@ywesee.com

require	'fachinfo_writer'
require 'fachinfo_html'
require 'rpdf2txt/parser'
module ODDB
	module FiParse
		class FachinfoPDFWriter < Rpdf2txt::DefaultHandler
			def initialize
				super
				@fachinfo_html_writer = FachinfoHtmlWriter.new
				@bold_src = ''
				@italic_src = ''
				@bold_italic_src = ''
				@state = {
					:bold => false,
					:italic => false,
					:bold_italic => false,
				}
			end
			def new_font(font)
				if(@state[:bold_italic])
					@fachinfo_html_writer.new_font([nil, 1, 1, nil])
					@fachinfo_html_writer.send_flowing_data(@src)
					@state[:bold_italic] = false
				elsif(@state[:bold])
					@fachinfo_html_writer.new_font(['h1', 0, 1, 0])
					@fachinfo_html_writer.send_flowing_data(@src)
					@state[:bold] = false
				elsif(@state[:italic])
					@fachinfo_html_writer.new_font([nil, 1, nil, nil])
					@fachinfo_html_writer.send_flowing_data(@src)
					@state[:italic] = false
			  else	
					@fachinfo_html_writer.new_font([nil, nil, nil, nil])
					@fachinfo_html_writer.send_flowing_data(@src)
				end
				
				if(font.bold? && font.italic?)
					@state[:bold_italic] = true
				elsif(font.bold?)
					@state[:bold] = true
				elsif(font.italic?)
					@state[:italic] = true
				end
				@src = ''
			end
			def send_flowing_data(data)
				@src << data
			end
			def send_paragraph
				@fachinfo_html_writer.send_line_break
			end
			def to_fachinfo
				@fachinfo_html_writer.to_fachinfo
			end
		end
	end
end
