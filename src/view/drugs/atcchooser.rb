#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::AtcChooser -- oddb.org -- 22.06.2012 -- yasaka@ywesee.com
# ODDB::View::Drugs::AtcChooser -- oddb.org -- 24.10.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Drugs::AtcChooser -- oddb.org -- 14.07.2003 -- mhuggler@ywesee.com

require 'view/drugs/privatetemplate'
require 'view/publictemplate'
require 'htmlgrid/list'
require 'view/pointervalue'

module ODDB
	module View
		module Drugs
module AtcLink
  def atc_ddd_link(atc, session=@session)
    if(atc && atc.has_ddd?)
      link = HtmlGrid::Link.new(:ddd, atc, session, self)
      link.href = @lookandfeel._event_url(:ddd, {'atc_code'=>atc.code})
      link.set_attribute('class', 'square infos')
      link.set_attribute('title', @lookandfeel.lookup(:ddd_title))
      link
    end
  end
  def atc_drugbank_link(atc, session=@session)
    if(atc.db_id)
      link = HtmlGrid::Link.new(:drugbank, atc, session, self)
      link.href = "http://www.drugbank.ca/drugs/#{atc.db_id}"
      link.target = '_blank'
      link.set_attribute('class', 'list')
      link.set_attribute('title', @lookandfeel.lookup(:drugbank_title))
      link
    end
  end
  def atc_dosing_link(atc, session=@session)
    if(atc.ni_id)
      link = HtmlGrid::Link.new(:dosing, atc, session, self)
      link.href = "http://dosing.de/Niere/arzneimittel/#{atc.ni_id}.html"
      link.target = '_blank'
      link.set_attribute('class', 'list')
      link.set_attribute('title', @lookandfeel.lookup(:dosing_title))
      link
    end
  end
end
class AtcChooserList < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:description,
		[1,0]	=>	:atc_ddd_link,
	}	
	CSS_MAP = {
		[1,0]	=>	"list right"
	}
	COMPONENT_CSS_MAP = {}
	CSS_CLASS = "composite"
	DEFAULT_CLASS = HtmlGrid::Value
	OMIT_HEADER = true
	SORT_DEFAULT = false
	SORT_REVERSE = false 
	def init
		css_map.store([0,0], "atcchooser#{@model.level.next}")
		@model = @model.children
		if(@session.user.allowed?('login', 'org.oddb.RootUser'))
			components.store([2,0], :edit)
			css_map.store([2,0], 'list small')
		end
		## only call persistent_user_input once
		@atc = @session.persistent_user_input(:code)
		super
	end
	def compose_list(model=@model, offset=[0,0])
		code = @session.persistent_user_input(:code)
		model.each{ |mdl|
			if(mdl.has_sequence?)
				_compose(mdl, offset)
				#compose_components(mdl, offset)
				#compose_css(offset)
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
		link.href = @lookandfeel._event_url(event, args)
		link.value = mdl.pointer_descr(@session.language)
		link.attributes["class"] = css + mdl.level.to_s
		link
	end
	def edit(model, session)
		link = View::PointerLink.new(:code, model, session, self)
		link.value = @lookandfeel.lookup :edit_atc_class
		link.attributes['class'] = 'small'
		link.href = @lookandfeel._event_url(:atc_class, {:atc_code => model.code})
		link
	end
	def result_link?(mdl)
		mdl.code.length > 2 \
			&& (mdl.path_to?(@atc) \
			|| (!mdl.children.any?{ |child| 
				child.has_sequence? } \
			&& !mdl.sequences.empty?))
	end
end
class AtcChooserComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	"atc_chooser",
		[0,1]	=>	View::Drugs::AtcChooserList,
	}
	CSS_CLASS = "composite"
	CSS_MAP = {
		[0,0] =>	'th',
	}
	COMPONENT_CSS_MAP = {
		[0,1]	=>	'component',
	}
end
class AtcChooser < PrivateTemplate
	CONTENT = View::Drugs::AtcChooserComposite
	SNAPBACK_EVENT = :atc_chooser
end
		end
	end
end
