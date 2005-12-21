#!/usr/bin/env ruby
# View::Drugs::Search -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'view/publictemplate'
require 'view/drugs/centeredsearchform'
require 'view/welcomehead'
require 'view/custom/head'

module ODDB
	module View
		module Drugs
class Search < View::PublicTemplate
	include View::Custom::Head
	CONTENT = View::Drugs::GoogleAdSenseComposite
	CSS_CLASS = 'composite'
	HEAD = View::WelcomeHead
end
		end
	end
end
