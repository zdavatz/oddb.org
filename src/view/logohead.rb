#!/usr/bin/env ruby
# View::LogoHead -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'view/logo'
require 'view/tab_navigation'
require 'view/searchbar'
require 'htmlgrid/link'

module ODDB
	module View
		class LogoHead < HtmlGrid::Composite
			COMPONENTS = {
				[0,0]		=>	View::Logo,
				[1,1]		=>	View::TabNavigation,
			}
			CSS_MAP = {
				[1,1]	=>	'tabnavigation-right',
			}
			CSS_CLASS = 'composite'
		end
		class PopupLogoHead < HtmlGrid::Composite
			COMPONENTS = {
				[0,0]		=>	View::PopupLogo,
			}
		end
	end
end
