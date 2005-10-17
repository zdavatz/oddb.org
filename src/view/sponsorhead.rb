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
	include UserSettings
	COMPONENTS = {
		[0,0]		=>	View::Logo,
		[0,1]		=>	:language_chooser,
		[1,0]		=>	:sponsor,
		[1,0,0]	=>	:sponsor_until,
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
module SponsorMethods
	def head(model, session)
		if(@lookandfeel.enabled?(:sponsorlogo, false))
			View::SponsorHead.new(model, session, self)
		else
			View::LogoHead.new(model, session, self)
		end
	end
end
	end
end
