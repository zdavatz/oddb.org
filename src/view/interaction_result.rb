#!/usr/bin/env ruby
# InteractionResultView -- oddb -- 26.05.2004 -- maege@ywesee.com

require 'htmlgrid/form'
require 'view/form'
require 'view/publictemplate'
require 'view/interaction_resultlist'
require 'view/searchbar'

module ODDB
	class InteractionResultForm < Form 
		COLSPAN_MAP	= {
			[0,2]	=> 2,
			[0,3]	=> 2,
		}
		COMPONENTS = {
			[0,0]		=>	:title_found,
			[0,1]		=>	'add_to_interaction',
			[1,1]		=>	:search_query,
			[1,1,1]	=>	:submit,
			[0,2]		=>	InteractionResultList,
		}
		CSS_CLASS = 'composite'
		EVENT = :search_interaction
		FORM_METHOD = 'GET'
		SYMBOL_MAP = {
			:search_query		=>	SearchBar,	
		}
		CSS_MAP = {
			[0,0] =>	'result-found',
			[1,0]	=>	'button-right',	
			[0,1] =>	'result-price-compare',
			[1,1]	=>	'search',	
		}
		def title_found(model, session)
			query = session.persistent_user_input(:search_query)
			@lookandfeel.lookup(:title_found, query, session.state.object_count)
		end
	end
	class InteractionResultView < PublicTemplate
		CONTENT = InteractionResultForm
	end
end
