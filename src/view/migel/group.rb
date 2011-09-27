#!/usr/bin/env ruby
# View::Migel::Group -- oddb -- 05.10.2005 -- ffricker@ywesee.com

require 'view/privatetemplate'
require 'view/pointervalue'
require 'view/migel/result'
require 'model/migel/group'

module ODDB
	module View
		module Migel
class SubgroupList < HtmlGrid::List
	COMPONENTS = {
	[0,0]	=>	:migel_code,
	[1,0]	=>	:description,
	}
	CSS_MAP = {
		[0,0]	=>	'top list',
		[1,0]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'subheading'
	SORT_HEADER = false
	SORT_DEFAULT = :migel_code
	SYMBOL_MAP = {
		:migel_code	=>	PointerLink,
	}
	LOOKANDFEEL_MAP = {
		:migel_code	=>	:title_subgroup,
		:description	=>	:nbsp,
	}
  def migel_code(model=@model, session=@session)
    link = PointerLink.new(:migel_code, model, @session, self)
    event = :migel_search
    key = :migel_subgroup
    link.href = @lookandfeel._event_url(event, {key => model.migel_code.delete('.')})
    link
  end
end
class GroupInnerComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0] => :migel_code,
		[0,1]	=> :description,
		[0,2] => :limitation_text,
	}
	CSS_MAP = {
		[0,0,1,3] => 'list top',
		[1,0,1,3] => 'list',
	}
	LABELS = true
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	def description(model, key = :descr)
		value = HtmlGrid::Value.new(key, model, @session, self)
		if(model)
			value.value = model.send(@session.language)
		end
		value
	end
	def limitation_text(model)
		description(model.limitation_text, :limitation_text)
	end
end
class GroupComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=>	'migel_product',
		[0,1] =>  GroupInnerComposite,
		[0,2] =>  :subgroups,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,2]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	def subgroups(model)
		sub = model.subgroups.values
		if(!sub.empty?)
			SubgroupList.new(sub, @session, self)
		end
	end
end
class Group < View::PrivateTemplate
	CONTENT = GroupComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
