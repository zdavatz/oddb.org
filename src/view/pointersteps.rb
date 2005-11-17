#!/usr/bin/env ruby
# View::PointerSteps -- oddb -- 21.03.2003 -- mhuggler@ywesee.com 

require 'htmlgrid/list'
require 'htmlgrid/link'
require 'view/pointervalue'
require 'model/limitationtext'

module ODDB
	module View
		class PointerSteps < HtmlGrid::List
			COMPONENTS = {
				[0,0]	=>	:pointer_descr,
			}
			CSS_HEAD_MAP = {
				[0,0] =>	'th-pointersteps',
			}
			CSS_MAP = {
				[0,0] =>	'th-pointersteps',
			}
			OFFSET_STEP = [1,0]
			SORT_DEFAULT = nil
			SORT_HEADER = false
			SORT_REVERSE = false
			STEP_DIVISOR = '&nbsp;-&nbsp;'
			STRIPED_BG = false
			SYMBOL_MAP = {
				:pointer_descr =>	View::PointerLink,
			}
			def compose(model=@model, offset=[0,0])
				compose_header(offset)
				offset = resolve_offset(offset, self::class::OFFSET_STEP)
				offset = compose_snapback(offset)
				model = if(model.respond_to? :ancestors)
					model.ancestors(@session.app) 
				end || []	
				offset = compose_list(model, offset)
				compose_footer(offset)
			end
			def compose_footer(offset=[0,0])
				if(@model.is_a?(LimitationText))
					value = @lookandfeel.lookup(:limitation)
					compose_footer_add(value,offset)
				elsif @model.respond_to?(:pointer_descr) 
					value = View::PointerValue.new(:pointer_descr, @model, @session, self)
					compose_footer_add(value,offset)
				end
			end
			def compose_footer_add(value, offset=[0,0])
				@grid.add_field(self::class::STEP_DIVISOR, *offset)
				offset = resolve_offset(offset, self::class::OFFSET_STEP)
				@grid.add_field(value, *offset)
				@grid.add_style('th-pointersteps', *offset)
			end
			def compose_list(model=@model, offset=[0,0])
				bg_flag = false
				model.each{ |mdl|
					@grid.add_field(self::class::STEP_DIVISOR, *offset)
					offset = resolve_offset(offset, self::class::OFFSET_STEP)
					compose_components(mdl, offset)
					compose_css(offset, resolve_suffix(mdl, bg_flag))
					offset = resolve_offset(offset, self::class::OFFSET_STEP)
					bg_flag = !bg_flag if self::class::STRIPED_BG
				}
				offset
			end
			def compose_snapback(offset)
				if @container.respond_to?(:snapback)
					event, args = @container.snapback
					args ||= ['zone', @session.zone]
					link = HtmlGrid::Link.new(event, @model, @session, self)
					unless (@lookandfeel.direct_event == event)
						url = if(args.is_a?(String))
							args 
						else
							@lookandfeel._event_url(event, args)
						end
						link.set_attribute('href', url)
						link.set_attribute('class', 'th-pointersteps')
					end
					@grid.add(link, *offset)
					offset = resolve_offset(offset, self::class::OFFSET_STEP)
				end
				offset
			end
		end
		module Snapback
			SNAPBACK_EVENT = nil
			def snapback
				state = @session.state
				event = state.direct_event
				path = {}
				while(event.nil? && state)
					if((state = state.previous) \
						&& (event = state.direct_event))
						path = state.request_path
					end
				end
				[event || self.class::SNAPBACK_EVENT, path]
			end
		end
	end
end
