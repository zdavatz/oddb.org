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
	}
	SORT_DEFAULT = :name
	SORT_REVERSE = false
	SORT_HEADER = false
	SYMBOL_MAP = {
		:iksnr	=>	PointerLink,
	}
	include AlphaHeader
	def name(model, session)
		link = HtmlGrid::Link.new(:name, model, session, self)
		link.value = model.name
		query = (atc = model.atc_class) ? atc.code : 'atcless'
		args = {
			'search_query'	=>	query,
		}
		link.href = @lookandfeel.event_url(:search, args)
		link.css_class = 'result-big' << resolve_suffix(model)
		link
	end
end
class SequencesComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=> View::Drugs::SequenceList,
		[0,1]	=> View::ResultFoot,
	}
	CSS_CLASS = 'composite'
end
class Sequences < View::ResultTemplate
	CONTENT = View::Drugs::SequencesComposite
end
		end
	end
end
