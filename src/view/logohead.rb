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
				#[0,0]		=>	:logo,
				[1,1]		=>	View::TabNavigation,
			}
			CSS_MAP = {
				[1,1]	=>	'tabnavigation-right',
			}
			CSS_CLASS = 'composite'
=begin
			def logo(model, session)
				link = HtmlGrid::Link.new(:logo, model, session, self)
				link.href = @lookandfeel.event_url(:home)
				link
			end
=end
		end
		class PopupLogoHead < HtmlGrid::Composite
			COMPONENTS = {
				[0,0]		=>	View::PopupLogo,
			}
		end
	end
end
