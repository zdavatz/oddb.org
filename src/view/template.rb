#!/usr/bin/env ruby
# View::Template -- oddb -- 23.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/template'

module ODDB
	module View
		class Template < HtmlGrid::Template
			COMPONENTS = {
				[0,0]		=>	:content,
			}
		end
	end
end
