#!/usr/bin/env ruby
# encoding: utf-8

require 'htmlgrid/composite'
require 'htmlgrid/text'
require 'htmlgrid/link'
require 'view/logo'

module ODDB
	module View
		module Pharmacies
class WelcomeHeadPharmacies < View::WelcomeHead
	COMPONENTS = {
		[0,0]		=>	View::Logo,
		[1,0,0]	=>	:sponsor,
		[1,0,1]	=>	"break",
		[1,0,2]	=>	"home_welcome_pharmacies",
    [1,0,3] =>  :welcome,
	}
	end
		end
	end
end
