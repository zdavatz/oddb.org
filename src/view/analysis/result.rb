#!/usr/bin/env ruby
# View::Analysis::Result -- oddb.org -- 14.06.2006 -- sfrischknecht@ywesee.com

require 'htmlgrid/list'
require 'model/analysis/position'
require 'util/language'
require 'view/additional_information'
require 'view/pointervalue'
require 'view/privatetemplate'
require 'view/resultfoot'
require 'view/analysis/explain_result'

module ODDB
	module View
		module Analysis
class List < HtmlGrid::List
	include View::AdditionalInformation
	COMPONENTS = {
		[0,0]	=> :code,
		[1,0]	=> :lab_areas,
		[2,0]	=> :list_title,
		[3,0]	=> :description,
		[4,0]	=> :taxpoints,
		[5,0]	=> :analysis_revision,
#		[6,0]	=> :feedback,
		[6,0]	=> :google_search,
#		[7,0]	=> :notify,
	}
	CSS_CLASS = 'composite'
	CSS_HEAD_MAP = {
		[0,0]	=>	'th',
		[1,0]	=>	'th',
		[2,0]	=>	'th',
		[3,0]	=>	'th',
		[4,0]	=>	'th',
		[5,0]	=>	'th',
	}
	CSS_MAP = {
		[0,0,6]	=>	'list',
		[6,0,1]	=>	'list right',
	}
	LEGACY_INTERFACE = false
	LOOKANDFEEL_MAP = {
		:description => :analysis_description,
	}
	SORT_DEFAULT = :code
	def description(model)
		link = PointerLink.new(:to_s, model, @session, self)
		text = model.send(@session.language).gsub("\n", ' ')
		if(text.size > 60)
			if(match = /^([\S]*block)/.match(text))
				text = match[1]
			elsif(match = /^(Blutgase)/.match(text))
				text = match[1]
			else
				text = text[0..60]
				text = text[0..text.rindex(" ")] << '...'
			end
		end
		link.value = text
		link
	end
	def list_title(model, key = :list_title)
		if(model.list_title)
			value = HtmlGrid::Value.new(key, model, @session, self)
			value.value = model.list_title.send(@session.language)
			value
		end
	end
end
class ResultComposite < HtmlGrid::Composite
	include ResultFootBuilder	
	EXPLAIN_RESULT = View::Analysis::ExplainResult
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=>	List,
		[0,1]	=>	:result_foot,
	}
end
class Result < View::PrivateTemplate
	CONTENT = ResultComposite
	SNAPBACK_EVENT = :result
end
class EmptyResultForm < HtmlGrid::Form
	COMPONENTS = {
		[0,0,0]	=>	:search_query,
		[0,0,1]	=>	:submit,
		[0,1]		=>	:title_none_found,
		[0,2]		=>	'e_empty_result',
	}
	CSS_MAP	=	{
		[0,0]			=>	'search',
		[0,1]			=>	'th',
		[0,2,1,1]	=>	'atc',
	}
	CSS_CLASS = 'composite'
	EVENT = :search
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
		:search_query	=>	View::SearchBar
	}
	def title_none_found(model, session)
		query = session.persistent_user_input(:search_query)
		@lookandfeel.lookup(:title_none_found, query)
	end
end
class EmptyResult < View::ResultTemplate
	CONTENT = EmptyResultForm
end
		end
	end
end
