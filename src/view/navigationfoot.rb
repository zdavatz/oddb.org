#!/usr/bin/env ruby
# NavigationFoot -- oddb -- 19.11.2002 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/text'
require 'view/navigation'
require 'view/copyright'

module ODDB
	class NavigationFoot < HtmlGrid::Composite
		CSS_CLASS = "navigation-foot"
		COMPONENTS = {
			[0,0]		=>	Copyright,
			[1,0]		=>	Navigation,	
		}
		HTML_ATTRIBUTES = {
			'valign'	=>	'bottom',
		}
	end
end
