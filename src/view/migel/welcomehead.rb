#!/usr/bin/env ruby
# encoding: utf-8
#  -- oddb -- 04.10.2005 -- ffricker@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/text'
require 'htmlgrid/link'
require 'view/logo'

module ODDB
	module View
		module Migel
class WelcomeHeadMigel < View::WelcomeHead
	COMPONENTS = {
		[0,0]		=>	View::Logo,
		[1,0,0]	=>	:sponsor,
		[1,0,1]	=>	"break",
		[1,0,2]	=>	"home_welcome",
	}
	end
		end
	end
end
