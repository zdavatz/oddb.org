#!/usr/bin/env ruby
# View::Interactions::Search -- oddb -- 26.05.2004 -- maege@ywesee.com

require 'view/interactions/centeredsearchform'

module ODDB
	module View
		module Interactions
class Search < View::Search
	CONTENT = View::Interactions::GoogleAdSenseComposite
end
		end
	end
end
