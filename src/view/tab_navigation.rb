#!/usr/bin/env ruby
# View::TabNavigation -- oddb -- 01.09.2004 -- maege@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/link'
require 'view/tab_navigationlink'

module ODDB
	module View
		class TabNavigation < HtmlGrid::Composite
			COMPONENTS = {}
			CSS_CLASS = "component tabnavigation"
			HTML_ATTRIBUTES = { "align"=>"center" }
			SYMBOL_MAP = {
				:tabnavigation_divider	=>	HtmlGrid::Text,
			}
			def init
				build_navigation()
				super
			end
			def build_navigation
				@session.state.zones.each_with_index { |zone, idx|
					symbol_map.store(zone, View::TabNavigationLink)
					components.store([idx*2,0], zone)
					if(idx > 0)
						components.store([idx*2-1,0], :tabnavigation_divider) 
					end
				}
			end
		end
	end
end
