#!/usr/bin/env ruby
# View::Drugs::Sequences -- oddb -- 08.02.2005 -- hwyss@ywesee.com

require 'view/alphaheader'
require 'view/additional_information'
require 'view/resulttemplate'
require 'view/resultfoot'
require 'view/resultcolors'

module ODDB
	module View
		module Drugs
class OffsetPager < View::Pager
	COMPONENTS = {
		[0,0]	=>	:offset_link,
	}
	CSS_CLASS = 'pager'
	def compose_header(offset)
		offset
	end
	def compose_footer(offset)
		offset
	end
	def offset_link(model, session)
		page_link(:content, model)
	end
	def resolve_suffix(model, bg_flag=false)
		model == @page ? ' migel-group' : ''
	end
end
class SequenceList < HtmlGrid::List
	include View::ResultColors
	include View::AdditionalInformation
	COMPONENTS = {
		[0,0]	=>	:iksnr,
		[1,0]	=>  :fachinfo,
		[2,0]	=>	:patinfo,
		[3,0]	=>	:name_base,
		[4,0]	=>	:galenic_form,
		[5,0]	=>	:feedback,
		[6,0]	=>  :google_search,
		[7,0]	=>	:notify,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]		=>	'small result-edit',
		[1,0,2]	=>	'result-infos',
		[3,0]		=>	'result-big',
		[4,0]		=>	'result',
		[5,0,3]	=>	'result-b-r',
	}
	SORT_DEFAULT = false
	SORT_HEADER = false
	SYMBOL_MAP = {
		:iksnr	=>	PointerLink,
	}
	LEGACY_INTERFACE = false
	include AlphaHeader
	def compose_header(offset=[0,0])
		offset = super
		unless(@model.empty?)
			@grid.add(OffsetPager.new(@session.state.pages, @session, self, 
																:sequences, {:range => @session.state.range}), 
																*offset)
			@grid.set_colspan(offset.at(0), offset.at(1), full_colspan)
			@grid.add_style('tab', *offset)
			offset = resolve_offset(offset, self::class::OFFSET_STEP)
		end
		offset
	end
	def name_base(model)
		link = HtmlGrid::Link.new(:name_base, model, @session, self)
		name = model.name_base
		link.value = name
		args = {
			'search_query'	=>	name,
		}
		link.href = @lookandfeel._event_url(:search, args, 'best_result')
		link.css_class = 'result-big' << resolve_suffix(model)
		link
	end
end
class SequencesComposite < HtmlGrid::Composite
	include ResultFootBuilder
	COMPONENTS = {
		[0,0]	=> :title_sequences,
		[1,0]		=>	SearchForm,
		[0,1]	=> View::Drugs::SequenceList,
		[0,2]	=> :result_foot,
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
				@session.state.interval, @session.state.model.size)
		end
	end
end
class Sequences < View::ResultTemplate
	CONTENT = View::Drugs::SequencesComposite
end
		end
	end
end
