#!/usr/bin/env ruby
# InteractionResultView -- oddb -- 26.05.2004 -- maege@ywesee.com

require 'view/form'
require 'view/publictemplate'
require 'view/interaction_resultlist'
require 'view/searchbar'

module ODDB
	class InteractionResultForm < Form 
		COLSPAN_MAP	= {
			[0,0]	=> 2,
			[0,2]	=> 2,
			[0,3]	=> 2,
		}
		COMPONENTS = {
			[0,0]		=>	:title_found,
			[0,1]		=>	'add_to_interaction',
			[1,1]		=>	:search_query,
			[1,1,1]	=>	:submit,
			[0,2]		=>	InteractionResultList,
			[0,3]		=>	:interaction_basket,
		}
		CSS_CLASS = 'composite'
		EVENT = :search_interaction
		FORM_METHOD = 'GET'
		SYMBOL_MAP = {
			:search_query		=>	SearchBar,	
		}
		CSS_MAP = {
			[0,0] =>	'result-found',
			[0,1] =>	'result-price-compare',
			[1,1]	=>	'search',	
			[0,3]	=>	'button-left-with-padding',	
		}
		def interaction_basket(model, session)
			get_event_button(:interaction_basket)
		end
		def interaction_basket_link(model, session)
			link = HtmlGrid::Link.new(:interaction_basket, model, session, self)
			link.href = @lookandfeel.event_url(:interaction_basket)
			link.label = true
			link
		end
		def title_found(model, session)
			query = session.persistent_user_input(:search_query)
			@lookandfeel.lookup(:title_found, query, session.state.object_count)
		end
	end
	class InteractionResultView < PublicTemplate
		CONTENT = InteractionResultForm
	end
end
