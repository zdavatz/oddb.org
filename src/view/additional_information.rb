#!/usr/bin/env ruby
# View::AdditionalInformation -- oddb -- 09.12.2003 -- rwaltert@ywesee.com

module ODDB
	module View
		module AdditionalInformation
			DISABLE_ADDITIONAL_CSS = false
			def fachinfo(model, session, css='result-infos')
				fachinfo = model.fachinfo
				#company = model.company
				if(fachinfo )#&& company.fi_status)
					link = HtmlGrid::PopupLink.new(:fachinfo_short, model, session, self)
					link.href = @lookandfeel.event_url(:resolve, {'pointer' => fachinfo.pointer})
					link.set_attribute('title', @lookandfeel.lookup(:fachinfo))
					pos = components.index(:fachinfo)
					component_css_map.store(pos, css)
					css_map.store(pos, css)
					link
				end
			end
			def limitation_text(model, session)
				if((sl = model.sl_entry) && (sltxt = sl.limitation_text))
					link = HtmlGrid::PopupLink.new(:limitation_text_short, model, session, self)
					link.height = 300
					link.width = 500
					link.href = @lookandfeel.event_url(:resolve, {'pointer'=>sltxt.pointer})
					link.set_attribute('title', @lookandfeel.lookup(:limitation_text))
					pos = components.index(:limitation_text)
					component_css_map.store(pos, "result-infos")
					css_map.store(pos, "result-infos")
					link
				end
			end
			def patinfo(model, session)
				patinfo = model.patinfo
				#company = model.company
				if(patinfo)# && @lookandfeel.enabled?(:patinfo))#&& company.pi_status)
					link = HtmlGrid::PopupLink.new(:patinfo_short, model, session, self)
					if(patinfo.class == String)
						link.href = @lookandfeel.resource_global(:pdf_patinfo, patinfo)
					else
						link.href = @lookandfeel.event_url(:resolve, {'pointer' => patinfo.pointer})
						link.set_attribute('title', @lookandfeel.lookup(:patinfo))
						#link.set_attribute('class', 'result-b-r' << resolve_suffix(model))
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
				if(atc.has_ddd?)
					link = HtmlGrid::PopupLink.new(:ddd, atc, session, self)
					link.href = @lookandfeel.event_url(:ddd, {'pointer'=>atc.pointer})
					link.set_attribute('class', 'result-infos-bg')
					link.set_attribute('title', @lookandfeel.lookup(:ddd_title))
					link
				end
			end
		end
	end
end
