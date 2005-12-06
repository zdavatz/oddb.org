#!/usr/bin/env ruby
# View::ResultTemplate -- oddb -- 20.10.2004 -- jlang@ywesee.com

require 'view/publictemplate'
require 'view/navigation'
require 'view/sponsorhead'

module ODDB
	module View
		class ResultTemplate < PublicTemplate
			HEAD = View::LogoHead
			COMPONENTS = {}
			def init
				if(@lookandfeel.enabled?(:topfoot))
					@components = {
						[0,0]		=>	:topfoot,
						[0,1]		=>	:head,
						[0,2]		=>	:content,
						[0,3]		=>	:foot,
					}
				else
					@components = {
						[0,0]		=>	:head,
						[0,1]		=>	:content,
						[0,2]		=>	:foot,
					}
				end
				super
			end
		end
	end
end
