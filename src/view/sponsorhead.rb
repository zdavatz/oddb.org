#!/usr/bin/env ruby
# View::SponsorHead -- oddb -- 30.07.2003 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'view/sponsorlogo'
require 'view/logo'
require 'view/tab_navigation'
require 'view/logohead'

module ODDB
	module View
		class SponsorHead < CommonLogoHead
			COMPONENTS = {
				[0,0]		=>	View::Logo,
				[1,0]		=>	:sponsor,
				[1,0,0]	=>	:sponsor_until,
				[1,1]		=>	View::TabNavigation,
			}
			CSS_CLASS = 'composite'
			CSS_MAP = {
				[1,0]	=>	'logo-r',
				[1,1]	=>	'tabnavigation-right',
			}
			def sponsor(model, session)
				if((spons = @session.sponsor) \
					&& sponsor_represents?(spons, model))
					View::SponsorLogo.new(spons, session, self)
				elsif(@lookandfeel.enabled?(:google_adsense))
					ad_sense(model, session)
				end
			end
			def sponsor_until(model, session)
				if((spons = @session.sponsor) \
					&& sponsor_represents?(spons, model))
					@lookandfeel.lookup(:sponsor_until, @lookandfeel.format_date(spons.sponsor_until))
				end
			end
			private
			def sponsor_represents?(spons, model)
				model.respond_to?(:any?) \
				&& (date = spons.sponsor_until) \
				&& date >= Date.today \
				&& model.any? { |atc| 
					atc.packages.any? { |pac| spons.represents?(pac)}
				}
			end
		end
	end
end
