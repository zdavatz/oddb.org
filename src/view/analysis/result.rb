#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Analysis::Result -- oddb.org -- 10.01.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Analysis::Result -- oddb.org -- 14.06.2006 -- sfrischknecht@ywesee.com

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
    [0,0] => :limitation_text,
		[1,0]	=> :chapter,
		[2,0]	=> :code,
		[3,0]	=> :analysis_revision,
		[4,0]	=> :taxpoints,
		[5,0]	=> :description,
		[6,0]	=> :lab_areas,
		[7,0]	=> :google_search,
	}
	CSS_CLASS = 'composite'
	CSS_HEAD_MAP = {
		[0,0]	=>	'th',
		[1,0]	=>	'th',
		[2,0]	=>	'th',
		[3,0]	=>	'th',
		[4,0]	=>	'th',
		[5,0]	=>	'th',
		[6,0]	=>	'th',
	}
	CSS_MAP = {
    [0,0]   =>  'small list',
		[0,0,7]	=>	'list',
		[7,0,1]	=>	'list right',
	}
	LEGACY_INTERFACE = false
	LOOKANDFEEL_MAP = {
		:description => :analysis_description,
    :limitation_text  =>  :ltext,
	}
	SORT_DEFAULT = :code
	def description(model)
		link = PointerLink.new(:to_s, model, @session, self)
		text = model.send(@session.language).gsub("\n", ' ')
		if(text.size > 60)
			if(match = /^([\S]*block)/u.match(text))
				text = match[1]
			elsif(match = /^(Blutgase)/u.match(text))
				text = match[1]
			else
				text = text[0..60]
				text = text[0..text.rindex(" ")] << '...'
			end
		end
		link.value = text
    link.href = @lookandfeel._event_url(:analysis, [:group, model.groupcd, :position, model.poscd]) if model.is_a?(ODDB::Analysis::Position)
		link
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
