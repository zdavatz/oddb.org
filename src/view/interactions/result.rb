#!/usr/bin/env ruby
# View::Interactions::Result -- oddb -- 26.05.2004 -- maege@ywesee.com

require 'view/form'
require 'view/publictemplate'
require 'view/interactions/resultlist'
require 'view/searchbar'
require 'view/sponsorhead'

module ODDB
	module View
		module Interactions
			#class User < SBSM::KnownUser; end
			#class UnknownUser < SBSM::UnknownUser; end
			#class RootUser < View::Drugs::User; end
			#class CompanyUser < View::Drugs::User; end
class ResultForm < View::Form 
	COLSPAN_MAP	= {
		[0,2]	=> 2,
		[0,3]	=> 2,
	}
	COMPONENTS = {
		[0,0]		=>	:title_found,
		[0,1]		=>	'add_to_interaction',
		[1,1]		=>	:search_query,
		[1,1,1]	=>	:submit,
		[0,2]		=>	View::Interactions::ResultList,
		[0,3]		=>	:interaction_basket,
	}
	CSS_CLASS = 'composite'
	EVENT = :search
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,	
	}
	CSS_MAP = {
		[0,0] =>	'result-found',
		[0,1] =>	'result-price-compare',
		[1,1]	=>	'search',	
		[0,3]	=>	'button left padding',	
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
class Result < View::PublicTemplate
	CONTENT = View::Interactions::ResultForm
end
class EmptyResultForm < HtmlGrid::Form
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
	EVENT = :search
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,	
	}
	def title_none_found(model, session)
		query = session.persistent_user_input(:search_query)
		@lookandfeel.lookup(:title_none_found, query)
	end
end
class EmptyResult < View::PublicTemplate
	CONTENT = View::Interactions::EmptyResultForm
end
		end
	end
end
