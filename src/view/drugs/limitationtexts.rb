#!/usr/bin/env ruby
# View::Drugs::LimitationTexts -- oddb -- 21.11.2005 -- hwyss@ywesee.com

require 'view/additional_information'
require 'view/alphaheader'
require 'view/resultcolors'
require 'view/resulttemplate'
require 'htmlgrid/list'

module ODDB
	module View
		module Drugs
class LimitationTextList < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=> :limitation_text,
		[1,0]	=> :name,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'small result',
		[1,0]	=>	'result-big',
	}
	SORT_DEFAULT = false
	SORT_HEADER = false
	LEGACY_INTERFACE = false
	LOOKANDFEEL_MAP = {
		:limitation_text	=>	:ltext,
	}
	include View::AlphaHeader
	include View::AdditionalInformation
	include View::ResultColors
	def name(model)
		link = HtmlGrid::Link.new(:name_base, model, @session, self)
		link.value = model.name_base
		args = {
			'search_query'	=>	model.name_base,
		}
		link.href = @lookandfeel._event_url(:search, args)
		link.css_class = 'result-big' << resolve_suffix(model)
		link
	end
end
class LimitationTextsComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=> :title_limitation_texts,
		[1,0]	=>	SearchForm,
		[0,1]	=> View::Drugs::LimitationTextList,
		[0,2]	=> View::ResultFoot,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'result-found list',
	}
	COLSPAN_MAP	= {
		[0,1]	=> 2,
		[0,2]	=> 2,
	}
	LEGACY_INTERFACE = false
	def title_limitation_texts(model)
		unless(model.empty?)
			@lookandfeel.lookup(:title_limitation_texts, 
				@session.state.interval, @model.size, 
				@session.limitation_text_count)
		end
	end
end
class LimitationTexts < ResultTemplate
	CONTENT = LimitationTextsComposite
end
		end
	end
end
