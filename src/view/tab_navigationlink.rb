#!/usr/bin/env ruby
# encoding: utf-8
# View::TabNavigationLink -- oddb -- 20.11.2002 -- hwyss@ywesee.com 

require 'htmlgrid/link'

module ODDB
	module View
		class TabNavigationLink < HtmlGrid::Link
			CSS_CLASS = "tabnavigation"
			def init
				super
				unless (@session.zone == @name)
					home_event = [:home, @name].join('_')
					@attributes.store("href", @lookandfeel._event_url(home_event))
				end
			end
		end
	end
end
