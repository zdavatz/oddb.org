#!/usr/bin/env ruby
# LogoHead -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'view/logo'

module ODDB
	class LogoHead < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]		=>	Logo,
		}
	end
	class PopupLogoHead < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]		=>	PopupLogo,
		}
	end
end
