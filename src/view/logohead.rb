#!/usr/bin/env ruby
# View::LogoHead -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'view/logo'
require 'view/google_ad_sense'
require 'view/tab_navigation'
require 'view/searchbar'
require 'htmlgrid/link'

module ODDB
	module View
		class CommonLogoHead < HtmlGrid::Composite
			include GoogleAdSenseMethods
			CSS_CLASS = 'composite'
			GOOGLE_CHANNEL = '6336403681'
			GOOGLE_FORMAT = '468x60_as'
			GOOGLE_WIDTH = '468'
			GOOGLE_HEIGHT = '60'
		end
		class LogoHead < CommonLogoHead
			COMPONENTS = {
				[0,0]		=>	View::Logo,
				[1,0]		=>	:ad_sense,
				[1,1]		=>	View::TabNavigation,
			}
			CSS_MAP = {
				[1,0]	=>	'logo-r',
				[1,1]	=>	'tabnavigation-right',
			}
		end
		class PopupLogoHead < CommonLogoHead
			COMPONENTS = {
				[0,0]		=>	View::PopupLogo,
				[1,0]		=>	:ad_sense,
			}
			CSS_MAP = {
				[1,0]	=>	'logo-r',
			}
			GOOGLE_FORMAT = '234x60_as'
			GOOGLE_WIDTH = '234'
			GOOGLE_HEIGHT = '60'
		end
	end
end
