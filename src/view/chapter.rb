#!/usr/bin/env ruby
# View::Chapter -- oddb -- 17.09.2003 -- rwaltert@ywesee.com

require 'htmlgrid/value'

module ODDB
	module View
		class Chapter < HtmlGrid::Value
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
				if(paragraph.preformatted?)
					context.div({ 'class' => 'preformatted' }) { res }
				else
					## this must be an inline element, to enable starting 
					## paragraphs on the same line as the section-subheading
					context.span({ 'class' => 'paragraph' }) { res }
				end
			end
			def to_html(context)
				html = ''
				unless(@value.heading.empty?)
					html << context.h3 { self.escape(@value.heading) }
				end
				html << sections(context, @value.sections)
			end
			def sections(context, sections)
				attr = { 'class' => 'section' }
				sections.collect { |section|
					context.div(attr) { 
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
				attr = { 'class' => 'paragraph' }
				paragraphs.collect { |paragraph|
					if(paragraph.is_a? Text::ImageLink)
						context.div(attr) { context.img(paragraph.attributes) }
					else
						formats(context, paragraph)
					end
				}.join
			end
		end
	end
end
