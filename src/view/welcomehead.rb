#!/usr/bin/env ruby
# encoding: utf-8
# View::WelcomeHead -- oddb -- 13.07.2012 -- yasaka@ywesee.com
# View::WelcomeHead -- oddb -- 22.11.2002 -- hwyss@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/text'
require 'htmlgrid/link'
require 'view/logohead'
require 'view/sponsorhead'

module ODDB
	module View
		class WelcomeHead < HtmlGrid::Composite
			include Personal
			include SponsorDisplay
      LOGO_PATH = File.expand_path('../../../doc/resources/logos', File.dirname(__FILE__))
			CSS_CLASS = 'composite'
			CSS_MAP = {
				[0,0]	=>	'logo',
				[0,1]	=>	'personal_logo', # x, y, col
			}
      COMPONENTS = {
				[0,0] => View::Logo,
				[0,1] => :personal_logo,  # Willkommen logged-in user aus personal
			}
    end
	end
end
