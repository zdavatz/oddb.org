#!/usr/bin/env ruby
# View::Template -- oddb -- 23.10.2002 -- hwyss@ywesee.com 

require	'view/form'
require 'view/publictemplate'
require 'view/pointersteps'
require 'view/searchbar'

module ODDB
	module View
		class SearchHead < View::Form
			COMPONENTS = {
				[0,0]		=>	:search_query,
				[0,0,1]	=>	:submit,
			}
			CSS_CLASS = 'composite'
			CSS_MAP = {
				[0,0]	=>	'search',
			}
			EVENT = :search
			FORM_METHOD = 'GET'
			SYMBOL_MAP = {
				:search_query	=>	View::SearchBar,
			}
		end
		class PrivateTemplate < PublicTemplate
			COLSPAN_MAP = {
				[0,0]	=>	2,
				[0,1]	=>	2,
				[0,3]	=>	2,
				[0,4]	=>	2,
			}
			COMPONENTS = {
				[0,0]		=>	:foot,
				[0,1]		=>	:head,
				[0,2]		=>	View::PointerSteps,
				[1,2]		=>	View::SearchHead,
				[0,3]		=>	:content,
				[0,4]		=>	:foot,
			}
			SNAPBACK_EVENT = nil
			def snapback
				self.class::SNAPBACK_EVENT	
			end
		end
	end
end
