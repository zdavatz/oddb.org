#!/usr/bin/env ruby
# View::Navigation -- oddb -- 21.11.2002 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/link'
require 'view/navigationlink'

module ODDB
	module View
		class Navigation < HtmlGrid::Composite
			COMPONENTS = {}
			CSS_CLASS = "navigation"
			HTML_ATTRIBUTES = {"align"=>"right"}
			SYMBOL_MAP = {
				:navigation_divider	=>	HtmlGrid::Text,
			}
			def init
				build_navigation()
				super
			end
			def build_navigation
				@lookandfeel.navigation.each_with_index { |state, idx| 
					evt = if(state.is_a?(Symbol))
						state
					else
						evt = state.direct_event
						symbol_map.store(evt, View::NavigationLink)
						evt
					end
					components.store([idx*2,0], evt)
					components.store([idx*2-1,0], :navigation_divider) if idx > 0
				}
			end
=begin
			def contact_oddb(model, session)
				link = HtmlGrid::Link.new(:contact_oddb, model, session, self)
				link.href = @lookandfeel.lookup(:contact_oddb_href)
				link.attributes['class'] = 'navigation'
				link
			end
=end
		end
	end
end
