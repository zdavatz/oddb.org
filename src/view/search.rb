#!/usr/bin/env ruby
# SearchView -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'view/publictemplate'
require 'view/centeredsearchform'
require 'view/welcomehead'

module ODDB
	class SearchView < PublicTemplate
		CONTENT = CenteredSearchComposite
		CSS_CLASS = 'composite'
		HEAD = WelcomeHead
	end
end
