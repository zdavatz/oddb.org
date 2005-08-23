#!/usr/bin/env ruby
# View::Chapter -- oddb -- 17.09.2003 -- rwaltert@ywesee.com

require 'htmlgrid/value'
require 'view/form'

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
					context.span({ 'class' => 'paragraph' }) { 
						res } << context.br
				end
			end
			def to_html(context)
				html = ''
				unless(@value.heading.empty?)
					html << heading(context)
				end
				html << sections(context, @value.sections)
			end
			def heading(context)
				context.h3 { self.escape(@value.heading) }
			end
			def sections(context, sections)
				section_attr = { 'class' => 'section' }
				subhead_attr = { 'style' => 'font-style: italic' }
				#attr = {}
				sections.collect { |section|
					context.div(section_attr) { 
						head = context.span(subhead_attr) {
							self.escape(section.subheading) }
						if(/\n\s*$/.match(section.subheading))	
							head << context.br
						elsif(!section.subheading.strip.empty?)
							head << "&nbsp;"
						end
						head << paragraphs(context, section.paragraphs)
					} 
				}.join
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
		class EditChapter < Chapter
			def to_html(context)
				args = {
					'language'	=>	'JavaScript',
					'type'			=>	'text/javascript',
				}
				content = sections(context, @value.sections)
				content.gsub!(/[\\']/, '\\\1')
				content.gsub!(/\n/, "\\n")
				## the two following javascript-invocations need to be
				## in two separate javascript-tags, so a dynamically
				## generated hidden field can be used by writeRichText
				heading(context) << context.script(args) {
					<<-EOS
<!--
initRTE("/resources/javascript/richtext/images/", "/resources/javascript/richtext/", "#{@lookandfeel.resource(:css)}", false);
//-->
					EOS
				} << context.script(args) {
					<<-EOS
<!--
writeRichText('html_chapter', '#{content}', 650, 500, true, false);
//-->
					EOS
				}
			end
		end
		class EditChapterForm < Form
			COMPONENTS = {
				[0,0]	=>	:edit_chapter,
				[0,1]	=>	:submit,
			}
			LEGACY_INTERFACE = false
			def initialize(name, *args)
				@name = name
				super(*args)
			end
			def init
				super
				self.onsubmit = 'return updateRTE(\'html_chapter\');'
			end
			def edit_chapter(model)
				EditChapter.new(@name, model, @session, self)
			end
			def hidden_fields(context)
				args = {'name' => 'chapter', 'value' => @name}
				super << context.hidden(args)
			end
		end
	end
end
