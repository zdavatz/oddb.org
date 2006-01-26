#!/usr/bin/env ruby
# View::Migel::Search -- oddb -- 04.10.2005 -- ffricker@ywesee.com

require 'view/publictemplate'
require 'view/migel/welcomehead'
require 'view/migel/centeredsearchform'
require 'view/custom/head'

module ODDB
	module View
		module Migel
class Search < View::PublicTemplate
	include View::Custom::Head
	CONTENT = View::Migel::GoogleAdSenseComposite
	CSS_CLASS = 'composite'
	HEAD = View::Migel::WelcomeHeadMigel
end
		end
	end
end
