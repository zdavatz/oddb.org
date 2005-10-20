#!/usr/bin/env ruby
# View::Migel::Subgroup -- oddb -- 05.10.2005 -- ffricker@ywesee.com

require 'view/privatetemplate'
require 'view/migel/result'
require 'view/pointervalue'
require 'model/migel/subgroup'
require 'view/dataformat'

module ODDB
	module View
		module Migel
class ProductList < HtmlGrid::List
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
		:migel_code	=>	:title_product,
		:description	=>	:nbsp,
	}
end
class SubgroupInnerComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0] => :migel_code,
		[0,1]	=> :group,
		[0,2]	=> :description,
		[0,3] => :limitation_text,
	}
	CSS_MAP = {
		[0,0,1,4] => 'list top',
		[1,0,1,4] => 'list',
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
	def group(model)
		pointer_link(model.group)
	end
	def limitation_text(model)
		description(model.limitation_text, :limitation_text)
	end
	def pointer_link(model)
		link = PointerLink.new(:to_s, model, @session, self)
		link.value = model.send(@session.language)
		link
	end
end
class SubgroupComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=>	'migel_product',
		[0,1] =>  SubgroupInnerComposite,
	  [0,2] =>	:products,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,2]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	def products(model)
		prod = model.products.values
		if(!prod.empty?)
			ProductList.new(prod, @session, self)
		end
	end
end
class Subgroup < View::PrivateTemplate
	CONTENT = SubgroupComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
