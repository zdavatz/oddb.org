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
				if(fachinfo || pdf_fachinfos )#&& company.fi_status)
					pdf_link = false
					fi_link = false
					if(!fachinfo.nil? && !fachinfo.descriptions.nil? && fachinfo.descriptions.include?(visitor_language.to_s))
						fi_link = true
					elsif(pdf_fachinfos && pdf_fachinfos[visitor_language])
						pdf_link = true
					elsif(!fachinfo.nil? && !fachinfo.descriptions.nil? && fachinfo.descriptions[visitor_language.to_s]) 
							fi_link = true
					else
						pdf_link = true
					end
					link = HtmlGrid::PopupLink.new(:fachinfo_short, model, session, self)
					if(fi_link)
						link.href = @lookandfeel.event_url(:resolve, {'pointer' => fachinfo.pointer})
						link.set_attribute('title', @lookandfeel.lookup(:fachinfo))
					elsif(pdf_link)
						unless(pdf_fi = pdf_fachinfos[visitor_language])
							pdf_fi = pdf_fachinfos.values.first
						end
						link.href = @lookandfeel.resource_global(:pdf_fachinfo, pdf_fi)
					end
					pos = components.index(:fachinfo)
					component_css_map.store(pos, css)
					css_map.store(pos, css)
					link
				end
			end
			def feedback(model, session)
				link = HtmlGrid::Link.new(:feedback_text_short, model, session, self)
				link.href = @lookandfeel.event_url(:feedbacks, {'pointer'=>model.pointer})
				#link.set_attribute('title', @lookandfeel.lookup(:limitation_text))
				pos = components.index(:feedback)
				component_css_map.store(pos, "feedback square")
				css_map.store(pos, "square")
				link
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
				pdf_patinfo = model.pdf_patinfo
				#company = model.company
				if(patinfo || pdf_patinfo)# && @lookandfeel.enabled?(:patinfo))#&& company.pi_status)
					link = HtmlGrid::PopupLink.new(:patinfo_short, model, session, self)
					if(!pdf_patinfo.nil?)
						link.href = @lookandfeel.resource_global(:pdf_patinfo, pdf_patinfo)
					elsif(!patinfo.nil?)
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
			rescue NoMethodError => e
				puts e
				puts e.message
				puts "atc:   #{atc.class}"
				puts "query: #{session.persistent_user_input(:search_query)}"
				if(atc.respond_to?(:pointer))
					puts "pointer:#{atc.pointer}"
				end
				if(atc.respond_to?(:ddds))
					ddds = atc.ddds
					puts "ddds.class: #{ddds.class}"
					puts "Stub?:      #{ddds.is_a?(ODBA::Stub)}"
					if(ddds.respond_to?(:odba_id))
						puts "odba_id: #{ddds.odba_id}"
					end
				end
				puts "state: #{session.state.class}"
				puts "model: #{@model.class}"
				if(@model.respond_to?(:pointer))
					puts "pointer: #{@model.pointer}"
				end
			end
		end
	end
end
