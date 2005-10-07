#!/usr/bin/env ruby
#  -- oddb -- 04.10.2005 -- ffricker@ywesee.com

require 'view/publictemplate'
require 'view/migel/welcomehead'
require 'view/migel/centeredsearchform'

module ODDB
	module View
		module Migel
class Search < View::PublicTemplate
	CONTENT = View::Migel::GoogleAdSenseComposite
	CSS_CLASS = 'composite'
	HEAD = View::Migel::WelcomeHeadMigel
end
		end
	end
end
