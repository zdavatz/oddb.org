#!/usr/bin/env ruby
# View::TabNavigation -- oddb -- 01.09.2004 -- mhuggler@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/link'
require 'view/tab_navigationlink'

module ODDB
	module View
		class TabNavigation < HtmlGrid::Composite
			COMPONENTS = {}
			CSS_CLASS = "component tabnavigation right"
			#HTML_ATTRIBUTES = { "align"=>"center" }
			SYMBOL_MAP = {
				:tabnavigation_divider	=>	HtmlGrid::Text,
			}
			def init
				if(@lookandfeel.enabled?(:just_medical_structure, false))
					build_jm_navigation()
				else
					build_navigation()
				end
				super
			end
			def build_navigation
				@lookandfeel.zones.sort_by { |zone| 
					@lookandfeel.lookup(zone)
				}.each_with_index { |zone, idx|
					symbol_map.store(zone, View::TabNavigationLink)
					pos = [idx*2,0]
					components.store(pos, zone)
					component_css_map.store(pos, 'tabnavigation')
					if(idx > 0)
						components.store([idx*2-1,0], :tabnavigation_divider) 
					end
				}
			end
			def build_jm_navigation
				@lookandfeel.zones.each_with_index { |zone, idx|
					if(zone.is_a?(Class))
						zone = zone.direct_event
						symbol_map.store(zone, View::NavigationLink)
					else
						symbol_map.store(zone, View::TabNavigationLink)
					end
					pos = [idx*2,0]
					components.store(pos, zone)
					component_css_map.store(pos, 'tabnavigation')
					if(idx > 0)
						components.store([idx*2-1,0], :tabnavigation_divider) 
					end
				}
			end
			def to_html(context)
				if(components.empty?)
					"&nbsp;"
				else
					super
				end
			end
		end
	end
end
