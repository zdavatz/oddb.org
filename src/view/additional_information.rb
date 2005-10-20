#!/usr/bin/env ruby
# View::AdditionalInformation -- oddb -- 09.12.2003 -- rwaltert@ywesee.com

module ODDB
	module View
		module AdditionalInformation
			DISABLE_ADDITIONAL_CSS = false
			def fachinfo(model, session, css='result-infos')
				fachinfo = model.fachinfo
				pdf_fachinfos = model.pdf_fachinfos
				#company = model.company
				visitor_language = @lookandfeel.language.intern
				if(fachinfo)# || pdf_fachinfos )#&& company.fi_status)
#					pdf_link = false
					fi_link = false
					if(!fachinfo.nil? && !fachinfo.descriptions.nil? \
						&& fachinfo.descriptions.include?(visitor_language.to_s))
						fi_link = true
					elsif(!fachinfo.nil? && !fachinfo.descriptions.nil? \
						&& fachinfo.descriptions[visitor_language.to_s]) 
						fi_link = true
					end
					link = HtmlGrid::Link.new(:fachinfo_short, 
							model, session, self)
					if(fi_link)
						link.href = @lookandfeel._event_url(:resolve,
							{'pointer' => fachinfo.pointer})
						link.set_attribute('title', @lookandfeel.lookup(:fachinfo))
					end
					pos = components.index(:fachinfo)
					component_css_map.store(pos, css)
					css_map.store(pos, css)
					link.set_attribute('title', @lookandfeel.lookup(:fi_alt))
					link
				end
			end
			def feedback(model, session)
				link = HtmlGrid::Link.new(:feedback_text_short, model, session, self)
				link.href = @lookandfeel._event_url(:feedbacks, {'pointer'=>model.pointer})
				pos = components.index(:feedback)
				component_css_map.store(pos, "feedback square")
				css_map.store(pos, "square")
				link.set_attribute('title', "#{@lookandfeel.lookup(:feedback_alt)}#{model.name_base}")
				link
			end
			def limitation_text(model, session)
				if((sl = model.sl_entry) && (sltxt = sl.limitation_text))
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
			def patinfo(model, session)
				if(model.has_patinfo?)
					link = HtmlGrid::PopupLink.new(:patinfo_short, model, session, self)
					if(pdf_patinfo = model.pdf_patinfo)
						link.href = @lookandfeel.resource_global(:pdf_patinfo, pdf_patinfo)
					elsif(patinfo = model.patinfo)
						link.href = @lookandfeel._event_url(:resolve, {'pointer' => patinfo.pointer})
						link.set_attribute('title', @lookandfeel.lookup(:patinfo))
					end
					pos = components.index(:patinfo)
					unless(self::class::DISABLE_ADDITIONAL_CSS)
						component_css_map.store(pos, "result-infos")
						css_map.store(pos, "result-infos")
					end
					link
				end
			end
			def atc_ddd_link(atc, session)
				if(atc && atc.has_ddd?)
					link = HtmlGrid::Link.new(:ddd, atc, session, self)
					link.href = @lookandfeel._event_url(:ddd, {'pointer'=>atc.pointer})
					link.set_attribute('class', 'result-infos-bg')
					link.set_attribute('title', @lookandfeel.lookup(:ddd_title))
					link
				end
			end
			def atc_description(atc, session=nil)
				atc_descr = if(descr = atc.description(@lookandfeel.language))
					descr.dup.to_s << ' (' << atc.code << ')' 
				else
					atc.code
				end
			end
		end
	end
end
