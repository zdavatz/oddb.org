#!/usr/bin/env ruby
# encoding: utf-8
# View::Substances::Result -- oddb -- 23.08.2004 -- mhuggler@ywesee.com

require 'view/form'
require 'view/resulttemplate'
require 'view/substances/resultlist'
require 'view/searchbar'
require 'view/sponsorhead'

module ODDB
	module View
		module Substances
class ResultComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COLSPAN_MAP = {
		[0,1]	=>	2,
	}
	COMPONENTS = {
		[0,0]		=>	:title_found,
		[1,0]		=>	View::SearchForm,
		[0,1]		=>	View::Substances::ResultList,
	}
	LEGACY_INTERFACE = false
	def title_found(model)
		query = @session.persistent_user_input(:search_query)
		@lookandfeel.lookup(:title_found, query, @session.state.object_count)
	end
end
class Result < View::ResultTemplate
	CONTENT = View::Substances::ResultComposite
end
class EmptyResultForm < HtmlGrid::Form
	COMPONENTS = {
		[0,0,0]	=>	:search_query,
		[0,0,1]	=>	:submit,
		[0,1]		=>	:title_none_found,
		[0,2]		=>	'e_empty_result',
		[0,3]		=>	'explain_search',
	}
	CSS_MAP = {
		[0,0]			=>	'search',	
		[0,1]			=>	'th',
		[0,2,1,2]	=>	'list atc',
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
class EmptyResult < View::ResultTemplate
	CONTENT = View::Substances::EmptyResultForm
end
		end
	end
end
