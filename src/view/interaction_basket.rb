#!/usr/bin/env ruby
# InteractionBasketView -- oddb -- 07.06.2004 -- maege@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/value'
require 'view/form'
require 'view/publictemplate'

module ODDB
	class InteractionBasketHeader < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	'interaction_basket',
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'atc-result',
		}
	end
	class InteractionBasketList < HtmlGrid::List
		COMPONENTS = {
			[0,0]	=>	:name,
		}
		DEFAULT_CLASS = HtmlGrid::Value
		REVERSE_MAP = {
			:name	=>	false,
		}
		CSS_MAP = {
			[0,0]	=>	'result-big-unknown',
		}
		CSS_HEAD_MAP = {
			[0,0]	=>	'th',
		}
		CSS_CLASS = 'composite'
		DEFAULT_CLASS = HtmlGrid::Value
		SORT_DEFAULT = :name
		SUBHEADER = InteractionBasketHeader
		def name(model, session)
			model.name
		end
	end
	class InteractionBasketForm < Form
		COLSPAN_MAP = {
			[0,0]	=>	2,
			[0,2]	=>	2,
			[0,3]	=>	2,
		}
		COMPONENTS = {
			[0,0]		=>	:interaction_basket_content,
			[0,1]		=>	'interaction_basket_explain',
			[1,1]		=>	:search_query,
			[1,1,1]	=>	:submit,
			[0,2]		=>	InteractionBasketList,
			[0,3]		=>	:calculate_interaction,
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
		def interaction_basket_content(model, session)
			count = session.interaction_basket_count
			@lookandfeel.lookup(:interaction_basket_count, count)
		end
		def calculate_interaction(model, session)
			get_event_button(:calculate_interaction)
		end
	end
	class InteractionBasketView < PublicTemplate
		CONTENT = InteractionBasketForm
	end
end
