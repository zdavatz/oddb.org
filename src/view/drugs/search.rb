#!/usr/bin/env ruby
# View::Drugs::Search -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'view/publictemplate'
require 'view/drugs/centeredsearchform'
require 'view/welcomehead'

module ODDB
	module View
		module Drugs
class Search < View::PublicTemplate
	CONTENT = View::Drugs::CenteredSearchComposite
	CSS_CLASS = 'composite'
	HEAD = View::WelcomeHead
end
		end
	end
end

