#!/usr/bin/env ruby
# encoding: utf-8
# View::Doctors::Init -- oddb -- 17.09.2004 -- usenguel@ywesee.com, jlang@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/text'
require 'htmlgrid/link'
#require 'htmlgrid/flash'
require 'view/logo'

module ODDB
	module View
		module Doctors
class WelcomeHeadDoctors < View::WelcomeHead
	COMPONENTS = {
		[0,0]		=>	View::Logo,
		[1,0,0]	=>	:sponsor,
		[1,0,1]	=>	"break",
		[1,0,2]	=>	"home_welcome_doctors",
	}
	end
		end
	end
end
