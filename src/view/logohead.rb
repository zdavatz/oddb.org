#!/usr/bin/env ruby
# View::LogoHead -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

puts "going to get htmlgrid/composite"
require 'htmlgrid/composite'
puts "going to get view/logo"
require 'view/logo'
puts "going to get view/google_ad_sense"
require 'view/google_ad_sense'
puts "going to get view/personal.rb"
require 'view/personal.rb'
puts "going to get view/tab_navigation"
require 'view/tab_navigation'
puts "going to get view/searchbar"
require 'view/searchbar'
puts "going to get htmlgrid/link"
require 'htmlgrid/link'
puts "going to get view/language_chooser"
require 'view/language_chooser'

module ODDB
	module View
		class CommonLogoHead < HtmlGrid::Composite
			include GoogleAdSenseMethods
			include Personal
			CSS_CLASS = 'composite'
			GOOGLE_CHANNEL = '6336403681'
			GOOGLE_FORMAT = '468x60_as'
			GOOGLE_WIDTH = '468'
			GOOGLE_HEIGHT = '60'
		end
		class LogoHead < CommonLogoHead
			include LanguageChooserFactory
			COMPONENTS = {
				[0,0]		=>	View::Logo,
				[0,1]		=>	:language_chooser,
				[1,0]		=>	:ad_sense,
				[1,0,2]	=>	:welcome,
				[1,1]		=>	View::TabNavigation,
			}
			CSS_MAP = {
				[1,0]	=>	'logo-r',
				[0,1] =>	'left',
				[1,1]	=>	'tabnavigation-right',
			}
			COMPONENT_CSS_MAP = {
				[0,1] =>	'component',
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
