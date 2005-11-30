#!/usr/bin/env ruby
# View::AdditionalInformation -- oddb -- 09.12.2003 -- rwaltert@ywesee.com

module ODDB
	module View
		module AdditionalInformation
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
				glink = Iconv.iconv('UTF-8', 'ISO_8859-1', text).first
				link = HtmlGrid::Link.new(:google_search, @model, @session, self)
				link.href =  "http://www.google.com/search?q=#{glink}"
				link.css_class= 'google_search square'
				link.set_attribute('title', "#{@lookandfeel.lookup(:google_alt)}#{text}")
				link
			end
			def ikscat(model, session=@session)
				txt = HtmlGrid::Span.new(model, session, self)
				text_elements = []
				title_elements = []
				if(cat = model.ikscat)
					text_elements.push(cat)
					catstr = @lookandfeel.lookup("ikscat_" << cat.to_s.downcase)
					title_elements.push(catstr)
				end
				if(sl = model.sl_entry)
					text_elements.push(@lookandfeel.lookup(:sl))
					sl_str = @lookandfeel.lookup(:sl_list).dup
					if(date = sl.introduction_date)
						sl_str << @lookandfeel.lookup(:sl_since, 
							date.strftime(@lookandfeel.lookup(:date_format)))
					end
					title_elements.push(sl_str)
				end
				txt.value = text_elements.join('&nbsp;/&nbsp;')
				title = title_elements.join('&nbsp;/&nbsp;')
				txt.set_attribute('title', title)
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
				if(narc = model.narcotics.first)
					link = HtmlGrid::Link.new(:narc_short, 
							narc, @session, self)
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
		end
	end
end
