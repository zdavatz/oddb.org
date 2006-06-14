#!/usr/bin/env ruby
# View::PrivateTemplate -- oddb -- 23.10.2002 -- hwyss@ywesee.com 

require	'view/form'
require 'view/publictemplate'
require 'view/pointersteps'
require 'view/searchbar'

module ODDB
	module View
		class PrivateTemplate < PublicTemplate
			include View::Snapback
			SEARCH_HEAD = View::SearchForm
			def init
				if(@lookandfeel.enabled?(:topfoot))
					@components = {
						[0,0]		=>	:topfoot,
						[0,1]		=>	:head,
						[0,2]		=>	View::PointerSteps,
						[1,2]		=>	self.class::SEARCH_HEAD,
						[0,3]		=>	:content,
						[0,4]		=>	:foot,
					}
					@colspan_map = {
						[0,0]	=>	2,
						[0,1]	=>	2,
						[0,3]	=>	2,
						[0,4]	=>	2,
					}
				else
					@components = {
						[0,0]		=>	:head,
						[0,1]		=>	View::PointerSteps,
						[1,1]		=>	self.class::SEARCH_HEAD,
						[0,2]		=>	:content,
						[0,3]		=>	:foot,
					}
					@colspan_map = {
						[0,0]	=>	2,
						[0,2]	=>	2,
						[0,3]	=>	2,
					}
				end
				super
			end
		end
	end
end
