#!/usr/bin/env ruby
# ChapterView -- oddb -- 17.09.2003 -- rwaltert@ywesee.com

require 'htmlgrid/value'

module ODDB
	class ChapterView < HtmlGrid::Value
		def formats(context, paragraph)
			res = ''
			txt = paragraph.text
			paragraph.formats.each { |format|
				style = [] 
				attrs = {}
				if(format.italic?)
					style << 'font-style:italic;'
				end
				if(format.bold?)
					style << 'font-weight:bold;'
				end
				escape_method = (format.symbol?) ? :escape_symbols : :escape
				str = self.send(escape_method, txt[format.range]) 
				if(style.empty?)
					res << str
				else
					attrs.store('style', style.join(' '))
					res << context.span(attrs) { 
						str
					}
				end
			}
			context.span { res }
		end
		def to_html(context)
			html = ''
			unless(@value.heading.empty?)
				html << context.h3 { self.escape(@value.heading) }
			end
			html << sections(context, @value.sections)
		end
		def sections(context, sections)
			sections.collect { |section|
				context.div { 
					head = self.escape(section.subheading)
					if(/\n\s*$/.match(section.subheading))	
						head << context.br
					elsif(!section.subheading.strip.empty?)
						head << "&nbsp;"
					end
					head << paragraphs(context, section.paragraphs)
				} 
			}.join("\n")
		end
		def paragraphs(context, paragraphs)
			paragraphs.collect { |paragraph|
				if(paragraph.is_a? Text::ImageLink)
					context.p { context.img(paragraph.attributes) }
				elsif(paragraph.preformatted?)
					context.pre	{ self.escape(paragraph) }
				else
					formats(context, paragraph)
				end
			}.join(context.br)
		end
	end
end
