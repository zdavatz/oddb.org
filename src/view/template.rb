#!/usr/bin/env ruby
# Template -- oddb -- 23.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/template'

module ODDB
	class Template < HtmlGrid::Template
		COMPONENTS = {
			[0,0]		=>	:content,
		}
	end
end
