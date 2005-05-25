#!/usr/bin/env ruby
# View::PointerSteps -- oddb -- 21.03.2003 -- mhuggler@ywesee.com 

require 'htmlgrid/list'
require 'htmlgrid/link'
require 'view/pointervalue'

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
				if @model.respond_to?(:pointer_descr) 
					value = View::PointerValue.new(:pointer_descr, @model, @session, self)
					@grid.add_field(self::class::STEP_DIVISOR, *offset)
					offset = resolve_offset(offset, self::class::OFFSET_STEP)
					@grid.add_field(value, *offset)
					@grid.add_style('th-pointersteps', *offset)
				end
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
					args ||= []
					link = HtmlGrid::Link.new(event, @model, @session, self)
					unless (@lookandfeel.direct_event == event)
						link.set_attribute('href', @lookandfeel.event_url(event, args))
						link.set_attribute('class', 'th-pointersteps')
					end
					@grid.add(link, *offset)
					offset = resolve_offset(offset, self::class::OFFSET_STEP)
				end
				offset
			end
		end
	end
end
