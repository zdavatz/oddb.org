#!/usr/bin/env ruby
# View::SponsorHead -- oddb -- 30.07.2003 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'view/sponsorlogo'
require 'view/logo'
require 'view/tab_navigation'
require 'view/logohead'

module ODDB
	module View
module SponsorDisplay
	def sponsor(model, session=@session)
		if((spons = @session.sponsor) && spons.valid?)
			View::SponsorLogo.new(spons, session, self)
		elsif(@lookandfeel.enabled?(:google_adsense))
			ad_sense(model, session)
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
class SponsorHead < CommonLogoHead
	include UserSettings
	include SponsorDisplay
	COMPONENTS = {
		[0,0]		=>	View::Logo,
		[0,1]		=>	:language_chooser,
		[1,0]		=>	:sponsor,
		[1,0,2]	=>	:welcome,
		[1,1]		=>	View::TabNavigation,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'logo',
		[0,1] =>	'list',
		[1,0]	=>	'logo-r',
		[1,1]	=>	'tabnavigation-right',
	}
	COMPONENT_CSS_MAP = {	
		[0,1] =>	'component',
	}
end
module SponsorMethods
	def head(model, session)
		if(@lookandfeel.enabled?(:sponsorlogo))
			View::SponsorHead.new(model, session, self)
		else
			View::LogoHead.new(model, session, self)
		end
	end
end
	end
end
