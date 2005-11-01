#!/usr/bin/env ruby
# View::Drugs::Sequences -- oddb -- 08.02.2005 -- hwyss@ywesee.com

require 'view/resulttemplate'
require 'view/resultfoot'
require 'view/resultcolors'

module ODDB
	module View
		module Drugs
class SequenceList < HtmlGrid::List
	include View::ResultColors
	COMPONENTS = {
		[0,0]	=>	:iksnr,
		[1,0]	=>	:name_base,
		[2,0]	=>	:galenic_form,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'small result-edit',
		[1,0]	=>	'result-big',
		[2,0]	=>	'result',
	}
	SORT_DEFAULT = :name
	SORT_REVERSE = false
	SORT_HEADER = false
	SYMBOL_MAP = {
		:iksnr	=>	PointerLink,
	}
	include AlphaHeader
	def name_base(model, session)
		link = HtmlGrid::Link.new(:name_base, model, session, self)
		link.value = model.name_base
		query = (atc = model.atc_class) ? atc.code : 'atcless'
		args = {
			'search_query'	=>	query,
		}
		link.href = @lookandfeel._event_url(:search, args)
		link.css_class = 'result-big' << resolve_suffix(model)
		link
	end
end
class SequencesComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=> :title_sequences,
		[1,0]		=>	SearchForm,
		[0,1]	=> View::Drugs::SequenceList,
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
	def title_sequences(model)
		unless(model.empty?)
			@lookandfeel.lookup(:title_sequences, 
				@session.state.interval, @model.size)
		end
	end
end
class Sequences < View::ResultTemplate
	CONTENT = View::Drugs::SequencesComposite
end
		end
	end
end
