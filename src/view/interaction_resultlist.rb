#!/usr/bin/env ruby
# InteractionResultList -- oddb -- 01.06.2004 -- maege@ywesee.com

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
require 'view/template'

module ODDB
=begin
	class InteractionFacadeHeader < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	:interaction_facade,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'atc-result',
		}
		def interaction_facade(facade, session)
			txt = HtmlGrid::Component.new(facade, session, self)
			obj_class = facade.obj_class.to_s.downcase.split(/::/).last
			symbol = [ "found", obj_class+"s" ].join("_").intern
			txt.value = session.lookandfeel.lookup(symbol)
			txt
		end
	end
=end
	class InteractionResultList < HtmlGrid::List
		COMPONENTS = {
			[0,0]		=>	:name,
			[0,0,1]	=>	:search_oddb,
			[2,0]		=>	:interaction_basket_status,
		}
		REVERSE_MAP = {
			:name	=>	false,
		}
		CSS_MAP = {
			[0,0]		=>	'result-big-unknown',
			[2,0]		=>	'result-b-r-unknown',
		}
		CSS_HEAD_MAP = {
			[0,0]	=>	'th',
		}
		CSS_CLASS = 'composite'
		DEFAULT_CLASS = HtmlGrid::Value
		SORT_DEFAULT = nil
		#SUBHEADER = InteractionFacadeHeader
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
				link
			else
				nil
			end
		end
		def name(model, session)
			if(session.interaction_basket.include?(model))
				model.name
			else
				link = HtmlGrid::Link.new(:add_to_interaction_basket, model, session, self)
				link.href = @lookandfeel.event_url(:add_to_interaction_basket, {'pointer'=>model.pointer})
				link.value = model.name
				link.set_attribute('class', 'result-big')
				link
			end
		end
		def search_oddb(model, session)
			link = HtmlGrid::Link.new(:search, model, session, self)
			link.href = @lookandfeel.event_url(:search, {'search_query'=>model.name})
			link.value = @lookandfeel.lookup(:search_oddb)
			link.set_attribute('style','text-decoration:none; color:black; margin:5px; font-size:8pt;')
			link
		end
	end
end
