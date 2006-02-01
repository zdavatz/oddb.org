#!/usr/bin/env ruby
# View::LogoHead -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'view/logo'
require 'view/sponsorlogo'
require 'view/google_ad_sense'
require 'view/personal.rb'
require 'view/tab_navigation'
require 'view/searchbar'
require 'htmlgrid/link'
require 'view/language_chooser'

module ODDB
	module View
		module SponsorDisplay
			def sponsor(model, session=@session)
				unless(@session.user.valid?)
					if((spons = @session.sponsor) && spons.valid?)
						View::SponsorLogo.new(spons, session, self)
					elsif(@lookandfeel.enabled?(:google_adsense))
						ad_sense(model, session)
					end
				end
			end
=begin ## unused code: does the sponsor represent at least one product?
			private
			def sponsor_represents?(spons, model)
				model.respond_to?(:any?) \
				&& (date = spons.sponsor_until) \
				&& date >= Date.today \
				&& model.any? { |item| 
					spons.represents?(item) || (item.respond_to?(:packages) \
						&& item.packages.any? { |pac| spons.represents?(pac)})
				}
			end
=end
		end
		class CommonLogoHead < HtmlGrid::Composite
			include GoogleAdSenseMethods
			include Personal
			include SponsorDisplay
			CSS_CLASS = 'composite'
			GOOGLE_CHANNEL = '6336403681'
			GOOGLE_FORMAT = '468x60_as'
			GOOGLE_WIDTH = '468'
			GOOGLE_HEIGHT = '60'
		end
		class LogoHead < CommonLogoHead
			include UserSettings
			COMPONENTS = {
				[0,0]		=>	View::Logo,
				[0,1]		=>	:language_chooser,
				#[1,0]		=>	:ad_sense,
				[1,0]		=>	:sponsor,
				[1,0,2]	=>	:welcome,
				[1,1]		=>	View::TabNavigation,
			}
			CSS_MAP = {
				[0,0]	=>	'logo',
				[1,0]	=>	'logo-r',
				[0,1] =>	'list',
				[1,1]	=>	'tabnavigation-right',
			}
			COMPONENT_CSS_MAP = {	
				[0,1] =>	'component',
			}
		end
		class PopupLogoHead < CommonLogoHead
			COMPONENTS = {
				[0,0]		=>	View::PopupLogo,
				#[1,0]		=>	:ad_sense,
				[1,0]		=>	:sponsor,
				[0,1]		=>	:language_chooser,
			}
			CSS_MAP = {
				[0,0]	=>	'logo',
				[1,0]	=>	'logo-r',
			}
			GOOGLE_FORMAT = '234x60_as'
			GOOGLE_WIDTH = '234'
			GOOGLE_HEIGHT = '60'
		end
	end
end
