#!/usr/bin/env ruby
# View::Hospitals::Init -- oddb -- 15.02.2005 -- usenguel@ywesee.com, jlang@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/text'
require 'htmlgrid/link'
#require 'htmlgrid/flash'
require 'view/logo'

module ODDB
	module View
		module Hospitals
class WelcomeHeadHospitals < View::WelcomeHead
	COMPONENTS = {
		[0,0]		=>	View::Logo,
		[1,0]		=>	:sponsor,
		[1,0,1]	=>	"break",
		[1,0,2]	=>	"home_welcome_hospitals",
	}
	end
		end
	end
end
