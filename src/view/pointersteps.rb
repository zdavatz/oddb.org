#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::PointerSteps -- oddb.org -- 11.01.2011 -- mhatakeyama@ywesee.com 
# ODDB::View::PointerSteps -- oddb.org -- 21.03.2003 -- mhuggler@ywesee.com 

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
        unless(@lookandfeel.disabled?(:pointer_steps_header))
          compose_header(offset) 
        end
				offset = resolve_offset(offset, self::class::OFFSET_STEP)
				offset = compose_snapback(offset)
        model = if(model.respond_to? :structural_ancestors)
									model.structural_ancestors(@session.app) 
								elsif(sbm = @session.state.snapback_model)
									[sbm]
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
				#bg_flag = false
				model.each{ |mdl|
					@grid.add_field(self::class::STEP_DIVISOR, *offset)
					offset = resolve_offset(offset, self::class::OFFSET_STEP)
					_compose(mdl, offset)#, bg_flag)
					#compose_components(mdl, offset)
					#compose_css(offset, resolve_suffix(mdl, bg_flag))
					offset = resolve_offset(offset, self::class::OFFSET_STEP)
					#bg_flag = !bg_flag if self::class::STRIPED_BG
				}
				offset
			end
			def compose_snapback(offset)
				if @container.respond_to?(:snapback)
					event, url = @container.snapback
					link = HtmlGrid::Link.new(event, @model, @session, self)
					unless (@lookandfeel.direct_event == event)
						link.set_attribute('href', url)
						link.set_attribute('class', 'th-pointersteps')
						if(link.value.nil?)
							link.value = event
						end
					end
					@grid.add(link, *offset)
					offset = resolve_offset(offset, self::class::OFFSET_STEP)
				end
				offset
			end
      def pointer_descr(model, session=@session)
        link = PointerLink.new(:pointer_descr, model, @session, self)
        unless(@session.allowed?('edit', model))
          link.href = if model.pointer.respond_to?(:to_csv) and
                         smart_link_format = model.pointer.to_csv.gsub(/registration/, 'reg').gsub(/sequence/, 'seq').gsub(/package/, 'pack').split(/,/) and
                         smart_link_format.include?('reg')
                        @lookandfeel._event_url(:show, smart_link_format)
                      elsif model.is_a?(ODDB::GalenicGroup)
                        link_format = {:oid => model.oid}
                        @lookandfeel._event_url(:galenic_group, link_format)
                      elsif model.is_a?(ODDB::Doctor)
                        link_format = if model.ean13
                                        {:ean => model.ean13}
                                      else
                                        {:oid => model.oid}
                                      end
                        @lookandfeel._event_url(:doctor, link_format)
                      elsif model.is_a?(ODDB::Analysis::Group)
                        link_format = {:group => model.groupcd}
                        @lookandfeel._event_url(:analysis, link_format)
                      elsif model.is_a?(ODDB::Analysis::Position)
                        link_format = [:group, model.groupcd, :position, model.poscd]
                        @lookandfeel._event_url(:analysis, link_format)
                      else
                        old_link_format = {:pointer => model.pointer}
                        @lookandfeel._event_url(:show, old_link_format)
                      end
        end
        link
      end
		end
		module Snapback
			SNAPBACK_EVENT = nil
			def snapback
				state = @session.state
				event = state.direct_event
				ignore = nil
				path = {}
				while((event.nil? || event == ignore) \
              && (prev = state.previous) && prev != state)
          state = prev
					ignore ||= @session.state.snapback_event
					event = state.snapback_event
					path = state.direct_request_path
				end
				[event || self.class::SNAPBACK_EVENT, path]
			end
		end
	end
end
