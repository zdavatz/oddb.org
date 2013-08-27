#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Fachinfo -- oddb.org -- 15.12.2011 -- mhatakeyama@ywesee.com
# ODDB::Fachinfo -- oddb.org -- 26.10.2004 -- mwalder@ywesee.com rwaltert@ywesee.com

require	'fachinfo_writer'
require 'rpdf2txt/parser' unless defined?(Test::Unit)
require 'fileutils'

module ODDB
	module FiParse
		class FachinfoPDFWriter < Writer
			include FachinfoWriterMethods
			include Rpdf2txt::DefaultHandler
      @@skip_pattern = /documed|copyright|seite|page|[kc]ompendium/iu
      @@hr_pattern = /-{5}\s*$/u
      IMAGE_DIR = File.join(IMAGE_DIR, 'fachinfo')
			def initialize(*args)
				super
				@chars_since_last_linebreak = 0
				@tableheader_lineno = nil
			end
			def detect_tableheader?
				## ignore empty lines at the start of the page
				if(@tableheader_lineno == 0 && @out.strip.empty?)
					return true
				end
				lines = @paragraph.to_s.split("\n")
				if(@tableheader_lineno \
					&& (line = lines.at(@tableheader_lineno)) \
					&& line.strip == @out.strip)
					@tableheader_lineno += 1
					true
				else
					@tableheader_lineno = nil
					false
				end
			end
			def new_font(font)
				if(@font)
					self.add_text
					## if the following is preformatted text, we would like to 
					## know before the next call to add_text, e.g. for line_break
					## and similar
					if(/courier/iu.match(font.basefont_name))
						@preformatted = true
					end
				end
				@font = font
			end
			def add_text
        return unless(@font)
				if(@font.bold? && @font.italic?)
					heading = self.out.strip
					unless(heading.empty?)
						@chapter = next_chapter
						@chapter.heading = heading
						set_templates(@chapter)
						@section = @chapter.next_section
					end
				elsif(@font.bold?)
          if @chapter.nil?
            @name << self.out.strip
          elsif(@paragraph)
            @paragraph.set_format(:bold)
            @paragraph << self.out
            @paragraph.reduce_format(:bold)
          end
				elsif(@font.italic?)
					## special case: italic after company-name is the 
					## galenic_form-chapter of the pre AMZV-form of fi
					if(@chapter == @company)
						@chapter = next_chapter
						@section = @chapter.next_section
					end
					if(@fresh_paragraph || @preformatted)
            unless(self.out.empty?)
              @chapter ||= next_chapter
              @section = @chapter.next_section
              @section.subheading << self.out
              @paragraph = @section.next_paragraph
            end
						@wrote_section_heading = true
          elsif @paragraph
						@paragraph.set_format(:italic)
						@paragraph << self.out
						@paragraph.reduce_format(:italic)
          else
            warn "ignoring \"#{self.out}\""
					end
          if @paragraph && @paragraph.empty?
            @fresh_paragraph = false
          end
				else
					str_check = self.out.strip
					font_name = @font.basefont_name
					courier = !/courier/iu.match(font_name).nil?
					symbol = !/symbol/iu.match(font_name).nil?
					if(!@chapter.nil? && !str_check.empty? \
             && !@@skip_pattern.match(self.out))
						str = self.out
						@wrote_section_heading = false
						#for the first paragraph after a preformated paragraph
						if(!(courier || symbol) && @preformatted)
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
								#str.strip!
                str.gsub(/^[\n\r]+/u, '')
								@paragraph.preformatted!
							elsif(!@paragraph.preformatted?)
								@paragraph = @section.next_paragraph
								@paragraph.preformatted!
							end
              if(@preceding_hr)
                str = "-"*80 << "\n" << str
                @preceding_hr = false
              end
						else
							str.gsub!(/-\n/u, "-")
							str.gsub!(/ ?\n ?/u, " ")
							@preformatted = false
						end
						@paragraph << str
						@fresh_paragraph = false
					end
				end
				@out = ''
			end
			def send_flowing_data(data)
				@chars_since_last_linebreak += data.size
				self.out << data.gsub(/■/u, '')
			end
      def send_hr
        send_line_break
        if(@paragraph && @paragraph.preformatted?)
          unless(@@hr_pattern.match(self.out) \
                 || @@hr_pattern.match(@paragraph[-6..-1]))
            self.out << "-"*80 << "\n"
            @preceding_hr = false
          end
        else
          @preceding_hr = true
        end
      end
      def send_image(handle)
        send_line_break
        if img = handle.image
          prefix = @name.downcase.gsub(/[^a-z]/u, '')
          directory = File.join(IMAGE_DIR, prefix[0,2])
          FileUtils.mkdir_p directory
          files = Dir.glob("#{directory}/#{prefix}*")
          save = files.find { |path|
            begin
              other, = Magick::Image.read(path)
              other == img
            rescue
              false
            end
          }
          if save.nil?
            id = files.collect { |path|
              match = /(\d+)\.png/u.match File.basename(path)
              match[1].to_i
            }.max.to_i.next
            save = File.join directory, "#{prefix}_#{id}.png"
          end
          img.write save
          @section.next_image.src = save[%r!/resources/.*!u]
        end
        send_line_break
      rescue ArgumentError
      end
			def send_page
				## in newer fi-pdfs there is no change of font for 
				## pagenumbers. Here in send_page we can recognize 
				## and delete the page-numbering
				if(pos = @out.index(/\w+\s+\d+$/u))
					@out[pos..-1] = ''
				end
				self.add_text
				if(@preformatted)
					@tableheader_lineno = 0
				end
			end
			def send_line_break
				## After the first period in 'Valid until' 
				## we can go on to the next chapter
				if(@chapter == @date && /\.\s*$/u.match(self.out))
					self.add_text
					@chapter = next_chapter
					@section = @chapter.next_section
					@paragraph = @section.next_paragraph
					@out = ''
					return
				end
				if(@preformatted)
					if(detect_tableheader?)
						@out = ''
					else
						self.add_text
						@paragraph << "\n" if(@paragraph)
					end
				elsif(@chars_since_last_linebreak < 80)
					self.send_paragraph
				elsif(!/[\s‐­-]$/u.match(self.out))
					self.out << " "
				end
				@chars_since_last_linebreak = 0
			end
			def send_paragraph
				self.add_text
        par = @section.paragraphs.first
				if(@section.subheading[-1] != ?\n && (par.nil? || par.empty?))
					@section.subheading << "\n"
				end
				unless(@preformatted)
					@fresh_paragraph = true
				end
			end
		end
	end
end unless defined?(Test::Unit)
