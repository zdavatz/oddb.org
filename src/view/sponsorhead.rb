#!/usr/bin/env ruby
# View::SponsorHead -- oddb -- 30.07.2003 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/span'
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
