#!/usr/bin/env ruby
# View::Substances::Result -- oddb -- 23.08.2004 -- maege@ywesee.com

require 'view/form'
require 'view/publictemplate'
require 'view/substances/resultlist'
require 'view/searchbar'
require 'view/sponsorhead'

module ODDB
	module View
		module Substances
class SearchForm < View::Form
	COMPONENTS = {
		[0,0]	=>	:search_query,
		[1,0]	=>	:submit,
	}
	CSS_CLASS = 'component'
	EVENT = :search
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,	
	}
	CSS_MAP = {
		[0,0] =>	'search',
		[1,0] =>	'button left padding',
	}
end
class ResultComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COLSPAN_MAP = {
		[0,1]	=>	2,
	}
	COMPONENTS = {
		[0,0]		=>	:title_found,
		[1,0]		=>	View::Substances::SearchForm,
		[0,1]		=>	View::Substances::ResultList,
	}
	LEGACY_INTERFACE = false
	def title_found(model)
		query = @session.persistent_user_input(:search_query)
		@lookandfeel.lookup(:title_found, query, @session.state.object_count)
	end
end
class Result < View::PublicTemplate
	CONTENT = View::Substances::ResultComposite
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
	LEGACY_INTERFACE = false
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,	
	}
	def title_none_found(model)
		query = @session.persistent_user_input(:search_query)
		@lookandfeel.lookup(:title_none_found, query)
	end
end
class EmptyResult < View::PublicTemplate
	CONTENT = View::Substances::EmptyResultForm
end
		end
	end
end
