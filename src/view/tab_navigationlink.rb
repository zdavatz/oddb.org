#!/usr/bin/env ruby
# View::TabNavigationLink -- oddb -- 20.11.2002 -- hwyss@ywesee.com 

require 'htmlgrid/link'

module ODDB
	module View
		class TabNavigationLink < HtmlGrid::Link
			CSS_CLASS = "tabnavigation"
			def init
				super
				unless (@session.state.zone == @name)
					args = {
						"zone"	=> @name.to_s
					}
					if(query = @session.persistent_user_input(:search_query))
						args.store("search_query", query)
					end
					direct_event = @session.state.direct_event
					event = if(direct_event.nil?)	
						'home'
					else
						direct_event
					end
					@attributes.store("href", @lookandfeel.event_url(:switch, args))
				end
			end
		end
	end
end
