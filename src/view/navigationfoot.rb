#!/usr/bin/env ruby
# View::NavigationFoot -- oddb -- 19.11.2002 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/text'
require 'view/navigation'
require 'view/copyright'

module ODDB
	module View
		class NavigationFoot < HtmlGrid::Composite
			CSS_CLASS = "navigation-foot"
			COMPONENTS = {
				[0,0]		=>	View::Copyright,
				[1,0]		=>	View::Navigation,
			}
			HTML_ATTRIBUTES = {
				'valign'	=>	'bottom',
			}
			CSS_MAP = {
				[0,0]	=>	'navigation',
				[1,0]	=>	'navigation-right',
			}
		end
	end
end
