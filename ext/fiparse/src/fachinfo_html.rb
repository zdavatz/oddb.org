#!/usr/bin/env ruby
# Fachinfo -- oddb -- 08.09.2003 -- hwyss@ywesee.com

require 'util/oddbconfig'
require 'util/http'
require	'fachinfo_writer'

module ODDB
	module FiParse
		class FachinfoHtmlWriter < FachinfoWriter
			include HttpFile
			FACHINFO_SERVER = 'www.kompendium.ch'
			DOCUMENT_ROOT = 'doc'
			IMAGE_PATH = '/resources/images/fachinfo'
			def new_font(font_tuple)
				#puts "in new font"
				#puts font_tuple.inspect
				if(@chapter_flag)
					@chapter_flag = nil
					# switch between old and new (2001) FI-Schema
					if(@chapter == @switch)
						set_templates(@chapter)
					end
					# sometimes there will be empty <B><I> tags.
					# these do not count as real chapter headings
					# exception to the rule: the galenic_form chapter
					# may appear without heading, albeit only in the
					# older Fachinfo-Structure
					if(@chapter.heading.empty? \
						&& ((@chapter != @galenic_form) || @amzv))
						@templates.unshift(@chapters.pop)
						@chapter = @chapters.last
						@section = @chapter.next_section
					end
				end
				#puts font_tuple.join('-') if font_tuple
				case font_tuple
				when ['h1',0,1,0]
					#puts " in first 1"
					set_target(@name)
				when [nil,1,1,nil]
					#	puts "in second 1"
					@chapter_flag = true
					@chapter = next_chapter
					#puts @chapter
					@section = @chapter.next_section
					set_target(@chapter.heading)
				when [nil,1,nil,nil]
					#puts "in third 1"
					if(@target.is_a?(Text::Paragraph) \
						&& !@target.empty?)
						@format = @target.set_format(:italic)
					elsif(@chapter)
						@section = @chapter.next_section
						set_target(@section.subheading)
					elsif(@mozilla)
						@chapter_flag = true
						@chapter = next_chapter
						@section = @chapter.next_section
						set_target(@section.subheading)
					end
				else
					#puts "in else"
					# Reset format
					unless(@format.nil?)
						@target.set_format if(@target.respond_to?(:set_format))
						@format = nil
					else
						# When the content of a section is on the same
						# line as its subheading
						target = if(@section)
							@section.next_paragraph
						end
						set_target(target)
					end
				end
			end
			def new_fonthandler(fonthandler)
				if(@target.respond_to?(:set_format))
					if(fonthandler \
						&& fonthandler.attribute("face").to_s.match(/symbol/i))
						@sym_format = @target.augment_format(:symbol)
					elsif(@sym_format)
						@target.reduce_format(:symbol)
						@sym_format = nil
					end
				end
			end
			def pseudo?
				!!@header.match(/pseudo/i)
			end
			def send_image(src)
				remote = File.expand_path(src, '//data/pictures')
				if(@section && (local = fetch_image(remote)))
					img = @section.next_image
					img.src = local
				end
				set_target(nil)
			end
			def send_meta(attributes)
				attrs = attributes.inject({}) { |inj, pair| 
					inj.store(*pair)
					inj
				}
				if((name = attrs['name']) && /generator/i.match(name) \
					&& (content = attrs['content']) && /mozilla/i.match(content))
					@mozilla = true
				end
			end
			private
			def fetch_image(remote)
				docdir = File.expand_path(DOCUMENT_ROOT, PROJECT_ROOT)
				base = File.basename(remote)
				ftype = remote[/\.[^\.]+$/]
				lang = ['de', 'fr'].select { |ln| ln[0] == base[0] }.first
				langpath = File.expand_path(lang, IMAGE_PATH)
				langdir = docdir + langpath
				id = begin 
					Dir.entries(langdir).collect { |item| item.to_i }.max.next
				rescue Errno::ENOENT
					1
				end
				fname = sprintf("%05i#{ftype}", id)
				fpath = File.expand_path(fname, langdir)
				puts remote
				puts fpath
				return
				if(http_file(FACHINFO_SERVER, remote, fpath))
					File.expand_path(fname, langpath)
				end
			end
		end
	end
end
