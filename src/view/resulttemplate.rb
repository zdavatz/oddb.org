#!/usr/bin/env ruby
# View::ResultTemplate -- oddb -- 20.10.2004 -- jlang@ywesee.com

require 'view/publictemplate'
require 'view/navigation'

module ODDB
	module View
		class ResultTemplate < PublicTemplate
			COMPONENTS = {
				[0,0]		=>	View::Navigation,
				[0,1]		=>	:head,
				[0,2]		=>	:content,
				[0,3]		=>	:foot,
			}
		end
	end
end
