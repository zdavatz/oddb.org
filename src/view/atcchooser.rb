#!/usr/bin/env ruby
# AtcChooserView -- oddb -- 14.07.2003 -- maege@ywesee.com

require 'view/additional_information'
require 'view/privatetemplate'
require 'view/publictemplate'
require 'htmlgrid/list'
require 'view/pointervalue'

module ODDB
	class AtcChooserList < HtmlGrid::List
		include AdditionalInformation
		COMPONENTS = {
			[0,0]	=>	:description,
			[1,0]	=>	:atc_ddd_link,
		}	
		CSS_MAP = {
			[1,0]	=>	"result-infos"
		}
		#CSS_CLASS = "composite"
		DEFAULT_CLASS = HtmlGrid::Value
		OMIT_HEADER = true
		SORT_DEFAULT = false
		SORT_REVERSE = false 
		def init
			@model = @model.children
			if(@session.user.is_a? RootUser)
				components.store([1,0], :edit)
			end
			super
		end
		def compose_list(model=@model, offset=[0,0])
			code = @session.persistent_user_input(:code)
			model.each{ |mdl|
				if(mdl.has_sequence?)
					compose_components(mdl, offset)
					compose_css(offset)
					offset = resolve_offset(offset, self::class::OFFSET_STEP)
					if(mdl.path_to?(code))
						open = AtcChooserList.new(mdl, @session, self)
						#open.attributes["class"] = "atcchooser#{mdl.level}"
						@grid.add(open, *offset)
						@grid.set_colspan(*offset)
						offset = resolve_offset(offset, self::class::OFFSET_STEP)
					end
				end
			}
			offset
		end	
		def description(mdl, session)
			link = HtmlGrid::Link.new(:atcchooser, mdl, @session, self)
			event, args, css = if(result_link?(mdl))
				[
					:search, 
					{'search_query'=>mdl.code}, 
					"atclink",
				]
			else
				#@lookandfeel.event_url(:atc_chooser, {'code'=>mdl.code})
				[
					:atc_chooser,
					{'code'=>mdl.code}, 
					"atcchooser",
				]
			end
			link.href = @lookandfeel.event_url(event, args)
			link.value = mdl.pointer_descr(@session.language)
			link.attributes["class"] = css + mdl.level.to_s
			link
		end
		def edit(model, session)
			link = PointerLink.new(:code, model, session, self)
			link.value = @lookandfeel.lookup :edit_atc_class
			link.attributes['class'] = 'small'
			link
		end
		def result_link?(mdl)
			atc = @session.persistent_user_input(:code)
			mdl.code.length > 2 \
				&& (mdl.path_to?(atc) \
				|| (!mdl.children.any?{ |child| 
					child.has_sequence? } \
				&& !mdl.sequences.empty?))
		end
	end
	class AtcChooserComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	"atc_chooser",
			[0,1]	=>	AtcChooserList,
		}
		CSS_CLASS = "composite"
		CSS_MAP = {
			[0,0] =>	'th',
		}
	end
	class AtcChooserView < PrivateTemplate
		CONTENT = AtcChooserComposite
		SNAPBACK_EVENT = :atc_chooser
	end
end
