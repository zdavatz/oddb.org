#!/usr/bin/env ruby
# encoding: utf-8
# View::Search -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'view/publictemplate'
require 'view/centeredsearchform'
require 'view/welcomehead'

module ODDB
	module View
		class Search < View::PublicTemplate
			CONTENT = View::CenteredSearchComposite
			CSS_CLASS = 'composite'
			HEAD = View::WelcomeHead
		end
	end
end
