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
	class ObjectClassHeader < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	:obj_class,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'atc-result',
		}
		def obj_class(facade, session)
			txt = HtmlGrid::Component.new(facade, session, self)
			obj_class = facade.obj_class.to_s.downcase.split(/::/).last
			symbol = [ "found", obj_class+"s" ].join("_").intern
			txt.value = session.lookandfeel.lookup(symbol)
			txt
		end
	end
	class InteractionResultList < HtmlGrid::List
		COMPONENTS = {
			[0,1]	=>	:name,
		}
		REVERSE_MAP = {
			:name	=>	false,
		}
		CSS_MAP = {
			[0,0]	=>	'result-big',
		}
		CSS_CLASS = 'composite'
		DEFAULT_CLASS = HtmlGrid::Value
		SORT_DEFAULT = nil
		SUBHEADER = ObjectClassHeader
		def compose_subheader(facade, offset)
			subheader = self::class::SUBHEADER.new(facade, @session, self)
			@grid.add(subheader, *offset)
			@grid.add_style('result-atc', *offset)
			@grid.set_colspan(offset.at(0), offset.at(1), full_colspan)
		end
		def compose_list(model=@model, offset=[0,0])
			model.each { |facade|	
				compose_subheader(facade, offset)
				offset = resolve_offset(offset, self::class::OFFSET_STEP)
				objects = facade.objects
				super(objects, offset)
				offset[1] += objects.size+2
			}
		end
		def name(model, session)
			link = HtmlGrid::PopupLink.new(:added_to_interaction, model, session, self)
			link.width = 350
			link.height	= 250
			link.href = @lookandfeel.event_url(:added_to_interaction, {'pointer'=>model.pointer})
			link.value = model.name
			link.set_attribute('class', 'result-big')
			link
		end
	end
end
