#!/usr/bin/env ruby
# NavigationLink -- oddb -- 20.11.2002 -- hwyss@ywesee.com 

require 'htmlgrid/link'

module ODDB
	class NavigationLink < HtmlGrid::Link
		CSS_CLASS = "navigation"
		def init
			super
			unless (@lookandfeel.direct_event == @name)
				@attributes.store("href", @lookandfeel.event_url(@name))
			end
		end
	end
end
