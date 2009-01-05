#!/usr/bin/env ruby
#  AnalysisParse::AnalysisHpricot -- oddb.org -- 24.08.2006 -- sfrischknecht@ywesee.com

require 'hpricot'
require 'model/analysis/position'
require 'open-uri'

module ODDB
	module AnalysisParse
		class AnalysisHpricot
			URL_BASE = "http://www.dacapo.ch/analysen/"
			def dacapo_infos(&block)
				("A".."Z").each { |letter|
					doc = Hpricot(open(URL_BASE + "view.php?match=" + letter + "&lab_id=0"))
					fetch_position_hrefs(doc, &block)
				}
			end
			def fetch_position_hrefs(doc, &block) 
				(doc/"a").each { |pos| 
					code = pos.inner_html
					url = URL_BASE + pos.attributes['href']
					info = fetch_additional_info(open(url))
					block.call(code, info)
				}
			end
			def fetch_additional_info(html)
				result = {}
				doc = Hpricot(html)
				elements = doc.search("//tr[@align='left']")
				elements = (elements/"//td[@colspan='2']")
        elements.each_with_index { |elem, index|
					case (elem/"strong").inner_html
					when "Beschreibung"
						val = format_string(elements[index+1].inner_html)
						result.store(:info_description, val)
					when "Interpretation"
						val = format_string(elements[index+1].inner_html)
						result.store(:info_interpretation, val)
					when "Indikation"
						val = format_string(elements[index+1].inner_html)
						result.store(:info_indication, val)
					when "Aussagekraft (Bewertung)"
						val = format_string(elements[index+1].inner_html)
						result.store(:info_significance, val)
					when "Entnahmematerial"
						val = format_string(elements[index+1].inner_html)
							result.store(:info_ext_material, val)
					when "Entnahmebedingungen"
						val = format_string(elements[index+1].inner_html)
						result.store(:info_ext_condition, val)
					when "Lagerungsbedingungen"
						val = format_string(elements[index+1].inner_html)
						result.store(:info_storage_condition, val)
					when "Lagerunsgdauer"
						val = format_string(elements[index+1].inner_html)
						result.store(:info_storage_time, val)
					end
				}
				result
			end
			def format_string(text)
				text.gsub(/\s+/, ' ')
			end
		end
	end
end
