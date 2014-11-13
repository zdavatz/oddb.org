#!/usr/bin/env ruby
# encoding: utf-8

require 'htmlgrid/composite'
require 'htmlgrid/text'
require 'htmlgrid/link'
require 'view/logo'

module ODDB
	module View
		module HC_providers
class WelcomeHeadHC_providers < View::WelcomeHead
	COMPONENTS = {
		[0,0]		=>	View::Logo,
		[1,0,0]	=>	:sponsor,
		[1,0,1]	=>	"break",
		[1,0,2]	=>	"home_welcome_hc_providers",
	}
	end
		end
	end
end
