#!/usr/bin/env ruby
# View::Interactions::ResultList -- oddb -- 01.06.2004 -- maege@ywesee.com

require 'htmlgrid/list'
require 'htmlgrid/value'
require 'htmlgrid/datevalue'
require 'htmlgrid/popuplink'
require 'htmlgrid/urllink'
require 'view/additional_information'
require 'view/pointervalue'
require 'view/publictemplate'
require 'view/dataformat'
require 'view/resultcolors'
require 'view/descriptionvalue'

module ODDB
	module View
		module Interactions
class ResultList < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:name,
		[1,0]	=>	:search_oddb,
		[2,0]	=>	:interaction_basket_status,
	}
	REVERSE_MAP = {
		:name												=>	false,
		:search_oddb								=>	false,
		:interaction_basket_status	=>	false,
	}
	CSS_MAP = {
		[0,0]	=>	'result big unknown',
		[1,0]	=>	'result-small-font',
		[2,0]	=>	'result big unknown',
	}
	CSS_CLASS = 'composite'
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'th'
	SORT_DEFAULT = nil
	STRIPED_BG = true
	#SUBHEADER = FacadeHeader
=begin
	def compose_subheader(facade, offset)
		subheader = self::class::SUBHEADER.new(facade, @session, self)
		@grid.add(subheader, *offset)
		@grid.add_style('result-atc', *offset)
		@grid.set_colspan(offset.at(0), offset.at(1), full_colspan)
	end
	def compose_list(model=@model, offset=[0,0])
		model.each { |substance|	
			#compose_subheader(facade, offset)
			offset = resolve_offset(offset, self::class::OFFSET_STEP)
			objects = substance
			super(objects, offset)
			offset[1] += objects.size+2
		}
	end
	def name(model, session)
		if(session.interaction_basket.include?(model))
			model.name
		else
			link = HtmlGrid::PopupLink.new(:interaction_basket_confirmation, model, session, self)
			link.width = 350
			link.height	= 250
			link.href = @lookandfeel.event_url(:interaction_basket_confirmation, {'pointer'=>model.pointer})
			link.value = model.name
			link.set_attribute('class', 'result-big')
			link
		end
	end
=end
	def interaction_basket_status(model, session)
		if(session.interaction_basket.include?(model))
			link = HtmlGrid::Link.new(:interaction_basket, model, session, self)
			link.href = @lookandfeel.event_url(:interaction_basket)
			link.value = @lookandfeel.lookup(:in_interaction_basket)
			link.set_attribute('font-weight', 'bold')
			link
		end
	end
	def name(model, session)
		if(session.interaction_basket.include?(model))
			model.name
		else
			link = HtmlGrid::Link.new(:add_to_interaction_basket, model, session, self)
			link.href = @lookandfeel.event_url(:add_to_interaction_basket, {'pointer'=>CGI.escape(model.pointer.to_s)})
			link.value = model.name
			link.set_attribute('class', 'result-big')
			link
		end
	end
	def search_oddb(model, session)
		result = @session.app.search(model.name, @session.language)
		unless(result.atc_classes.empty?)
			link = HtmlGrid::Link.new(:substance_result, model, session, self)
			link.href = @lookandfeel.event_url(:search, {'search_query' => model.name, 'zone'	=> :drugs})
			link.value = @lookandfeel.lookup(:search_oddb)
			link
		end
	end
end
		end
	end
end
