#!/usr/bin/env ruby
# SubstanceResultView -- oddb -- 23.08.2004 -- maege@ywesee.com

require 'view/form'
require 'view/publictemplate'
require 'view/substance_resultlist'
require 'view/searchbar'

module ODDB
	class SubstanceResultForm < Form
		COLSPAN_MAP	= {
			[0,0]	=> 2,
			[0,2]	=> 2,
		}
		COMPONENTS = {
			[0,0]		=>	:title_found,
			[1,1]		=>	:search_query,
			[1,1,1]	=>	:submit,
			[0,2]		=>	SubstanceResultList,
		}
		CSS_CLASS = 'composite'
		EVENT = :search_substance
		FORM_METHOD = 'GET'
		SYMBOL_MAP = {
			:search_query		=>	SearchBar,	
		}
		CSS_MAP = {
			[0,0] =>	'result-found',
			[0,1] =>	'result-price-compare',
			[1,1]	=>	'search',	
			[0,3]	=>	'button left padding',	
		}
		def title_found(model, session)
			query = session.persistent_user_input(:search_query)
			@lookandfeel.lookup(:title_found, query, session.state.object_count)
		end
	end
	class SubstanceResultView < PublicTemplate
		CONTENT = SubstanceResultForm
	end
	class EmptySubstanceResultForm < HtmlGrid::Form
		COMPONENTS = {
			[0,0]		=>	:search_query,
			[0,0,1]	=>	:submit,
			[0,1]		=>	:title_none_found,
			[0,2]		=>	'e_empty_result',
			[0,3]		=>	'explain_search',
		}
		CSS_MAP = {
			[0,0]			=>	'search',	
			[0,1]			=>	'th',
			[0,2,1,2]	=>	'result-atc',
		}
		CSS_CLASS = 'composite'
		EVENT = :search_substance
		FORM_METHOD = 'GET'
		SYMBOL_MAP = {
			:search_query		=>	SearchBar,	
		}
		def title_none_found(model, session)
			query = session.persistent_user_input(:search_query)
			@lookandfeel.lookup(:title_none_found, query)
		end
	end
	class EmptySubstanceResultView < PublicTemplate
		CONTENT = EmptySubstanceResultForm
	end
end
