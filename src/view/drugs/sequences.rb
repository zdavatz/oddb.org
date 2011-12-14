#!/usr/bin/env ruby
# encoding: utf-8
# View::Drugs::Sequences -- oddb -- 08.02.2005 -- hwyss@ywesee.com

require 'view/alphaheader'
require 'view/additional_information'
require 'view/resulttemplate'
require 'view/resultfoot'
require 'view/resultcolors'
require 'view/lookandfeel_components'
require 'view/pager'

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
	COMPONENTS = { }
	DEFAULT_CLASS = HtmlGrid::Value
	CSS_CLASS = 'composite'
  CSS_KEYMAP = {
    :fachinfo       => 'list',
    :compositions   => 'list',
    :google_search  => 'list bold right',
    :iksnr          => 'small',
    :name_base      => 'list big',
    :notify         => 'list bold right',
    :patinfo        => 'list',
  }
  CSS_HEAD_KEYMAP = {}
	CSS_MAP = {}
	COMPONENT_CSS_MAP = {
		[0,0]		=>	'small',
	}
	SORT_DEFAULT = false
	SORT_HEADER = false
	SYMBOL_MAP = {
		:iksnr	=>	PointerLink,
	}
	LEGACY_INTERFACE = false
	include AlphaHeader
  include LookandfeelComponents
  def init
    reorganize_components(:sequence_list_components)
    super
  end
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
			'search_query' => name.gsub('/', '%2F'),
		}
    if @lookandfeel.disabled?(:best_result)
      link.href = @lookandfeel._event_url(:search, args)
    else
      link.href = @lookandfeel._event_url(:search, args, "best_result")
    end
		link.css_class = 'big' << resolve_suffix(model)
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
    [1,0] =>  'right',
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
