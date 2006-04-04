#!/usr/bin/env ruby
# View::AdditionalInformation -- oddb -- 09.12.2003 -- rwaltert@ywesee.com

require 'iconv'

module ODDB
	module View
		module AdditionalInformation
			@@utf8 = {}
			def atc_ddd_link(atc, session=@session)
				if(atc && atc.has_ddd?)
					link = HtmlGrid::Link.new(:ddd, atc, session, self)
					link.href = @lookandfeel._event_url(:ddd, {'pointer'=>atc.pointer})
					link.set_attribute('class', 'result-infos-bg')
					link.set_attribute('title', @lookandfeel.lookup(:ddd_title))
					link
				end
			end
			def atc_description(atc, session=@session)
				if(descr = atc.description(@lookandfeel.language))
					descr.dup.to_s << ' (' << atc.code << ')' 
				else
					atc.code
				end
			end
			def deductible(model, session=@session)
				span = HtmlGrid::Span.new(model, @session, self)
				if(deductible = model.deductible)
					span.set_attribute('title', @lookandfeel.lookup('deductible_unknown_title'))
				end
				span.value = @lookandfeel.lookup(deductible || 'deductible_unknown')
			end
			def fachinfo(model, session=@session, css='result-infos')
				_fachinfo(model.fachinfo, css)
			end
			def _fachinfo(fachinfo, css='result-infos')
				visitor_language = @lookandfeel.language.intern
				if(fachinfo)
					link = HtmlGrid::Link.new(:fachinfo_short, 
							fachinfo, @session, self)
					link.href = @lookandfeel._event_url(:resolve,
						{'pointer' => fachinfo.pointer})
					link.css_class = css
					link.set_attribute('title', @lookandfeel.lookup(:fachinfo))
					link
				end
			end
			def feedback(model, session=@session)
				link = HtmlGrid::Link.new(:feedback_text_short, model, session, self)
				link.href = @lookandfeel._event_url(:feedbacks, {'pointer'=>model.pointer})
				pos = components.index(:feedback)
				component_css_map.store(pos, "feedback square")
				css_map.store(pos, "square")

				link.set_attribute('title', @lookandfeel.lookup(:feedback_alt, 
					model.localized_name(@session.language)))
				link
			end
			def google_search(model, session=@session)
				text = model.localized_name(@session.language)
				glink = utf8(text)
				link = HtmlGrid::Link.new(:google_search, @model, @session, self)
				link.href =  "http://www.google.com/search?q=#{glink}"
				link.css_class= 'google_search square'
				link.set_attribute('title', "#{@lookandfeel.lookup(:google_alt)}#{text}")
				link
			end
			def ikscat(model, session=@session)
				@ikscat_count ||= 0
				@ikscat_count += 1
				txt = HtmlGrid::Span.new(model, session, self)
				text_elements = []
				if(cat = model.ikscat)
					text_elements.push(cat)
				end
				if(sl = model.sl_entry)
					text_elements.push(@lookandfeel.lookup(:sl))
				end
				if(model.lppv)
					catstr = @lookandfeel.lookup(:lppv)
					text_elements.push(catstr)
				end
				if(gt = model.sl_generic_type)
					text_elements.push(@lookandfeel.lookup("sl_#{gt}_short"))
				end
				txt.value = text_elements.join('&nbsp;/&nbsp;')
				url = @lookandfeel._event_url(:ajax_swissmedic_cat,
					{:pointer => model.pointer})
				txt.css_id = "ikscat_#{@ikscat_count}"
				txt.dojo_tooltip = url
				txt
			end
			def limitation_text(model, session=@session)
				if(sltxt = model.limitation_text)
					#if((sl = model.sl_entry) && (sltxt = sl.limitation_text))
					limitation_link(sltxt)
				end
			end
			def limitation_link(sltxt)
				link = HtmlGrid::Link.new(:limitation_text_short, 
					nil, @session, self)
				link.href = @lookandfeel._event_url(:resolve, 
					{'pointer'=>CGI.escape(sltxt.pointer.to_s)})
				link.set_attribute('title', 
					@lookandfeel.lookup(:limitation_text))
				pos = components.index(:limitation_text)
				link.css_class = "result-infos"
				#css_map.store(pos, "result-infos")
				link
			end
			def narcotic(model, session=@session)
				if(model.narcotic?)
					link = HtmlGrid::Link.new(:narc_short, 
							model, @session, self)
					link.href = @lookandfeel._event_url(:resolve,
						{'pointer' => model.pointer + :narcotics})
					link.css_class = 'result-infos'
					link.set_attribute('title', @lookandfeel.lookup(:narcotic))
					link
				end
			end
			def notify(model, session=@session)
				link = HtmlGrid::Link.new(:notify, model, @session, self)
				args = {
					:pointer => model.pointer.to_s,
				}
				link.href = @lookandfeel._event_url(:notify, args)
				img = HtmlGrid::Image.new(:notify, model, @session, self)
				img.set_attribute('src', @lookandfeel.resource_global(:notify))
				link.value = img
				link.set_attribute('title', @lookandfeel.lookup(:notify_alt))
				link
			end
			def patinfo(model, session=@session)
				if(model.has_patinfo?)
					href = nil
					klass = nil
					if(pdf_patinfo = model.pdf_patinfo)
						klass = HtmlGrid::PopupLink
						href = @lookandfeel.resource_global(:pdf_patinfo, pdf_patinfo)
					elsif(patinfo = model.patinfo)
						klass = HtmlGrid::Link
						href = @lookandfeel._event_url(:resolve, {'pointer' => patinfo.pointer})
					end
					link = klass.new(:patinfo_short, model, @session, self)
					link.href = href
					link.set_attribute('title', @lookandfeel.lookup(:patinfo))
					link.css_class = 'result-infos'
					link
				end
			end
			def qty_unit(model, session=@session)
				if(model.qty || model.unit)
					unit = nil
					if(u = model.unit)
						unit = u.send(@session.language)
					end
					[ '&nbsp;(', model.qty, unit, ')' ].compact.join(' ')
				end
			end
			def utf8(text)
				@@utf8[text] ||= Iconv.iconv('UTF-8', 'ISO_8859-1', text).first
			end
		end
	end
end
