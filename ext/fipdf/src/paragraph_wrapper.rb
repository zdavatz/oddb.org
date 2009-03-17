#!/usr/bin/env ruby
# ParagraphWrapper -- oddb -- 15.03.2004 -- rwaltert@ywesee.com

require 'delegate'
require 'pdf/writer/graphics/imageinfo'

module ODDB
	module FiPDF
		class ParagraphWrapper < SimpleDelegator
      attr_accessor :hyphenator
			def initialize(paragraph)
				@paragraph = paragraph
				super
			end
			def need_new_page?(height, width, formats)
        if image?
          path = File.join(PROJECT_ROOT, 'doc', @paragraph.src)
          if File.exist?(path)
            info = PDF::Writer::Graphics::ImageInfo.new(File.read(path))
            width * info.height / info.width > height
          end
        else
          format = if(preformatted?)
            formats[:preformatted]
          else
            formats[:paragraph]
          end
          paragraph_height = format.get_height(text(), width)
          num_lines = format.line_count(text(), width)
          available_height = height + format.spacing_before(text())
          lines_on_page = lines_per_height(available_height, format)
          if(num_lines <= 3 && paragraph_height > height)
            true
          elsif(num_lines > 3 && lines_on_page < 2)
            true
          else
            false
          end
        end
			end
      def image?
        @paragraph.is_a?(Text::ImageLink)
      end
			def enforce_page_break?(first_height, column_height, width, format)
				total_lines = format.line_count(text(), width)
				first_lines = lines_per_height(first_height, format)
				column_lines = lines_per_height(column_height, format)
				if((total_lines - first_lines) % column_lines == 1)
					total_lines - 2
				else
					false
				end
			end
			def format_text
				return '' unless(@paragraph.respond_to?(:text) \
					&& @paragraph.respond_to?(:formats))
				txt = @paragraph.text
				text = ""
				@paragraph.formats.each { |format|
					str = txt[format.range].to_s
					if(format.italic?)
						str = "<i>" + str + "</i>"
					end
					if(format.bold?)
						str = "<b>" + str + "</b>"
					end
					if(format.symbol?)
            body = str.dup
            head = body.slice!(/^\s*/u)
            tail = body.slice!(/\s*$/u)
            str = head << '<f:Symbol>' << body << '</f>' << tail
					end
					text << str
				}
				unless(@paragraph.preformatted?)
					text  = text.sub(/^-/u, "")
				end
				text
			end
			def lines_per_height(height, format)
				font_size = format.size
				(height / format.font_height(font_size)).floor
			end
			def preformatted?
				if(@paragraph.respond_to? :preformatted?)
					@paragraph.preformatted?
				else
					false
				end
			end
			def text
        @text ||= begin
          case @paragraph
          when Text::ImageLink
            @paragraph.to_s
          when Text::Table
            @paragraph.to_s :width => 50, :hyphenator => @hyphenator
          else
            format_text
          end
        end
      end
		end
	end
end
