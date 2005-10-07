#!/usr/bin/env ruby
# View::Migel::Product -- oddb -- 05.10.2005 -- ffricker@ywesee.com

require 'view/privatetemplate'
require 'view/migel/result'
require 'view/pointervalue'
require 'model/migel/product'
require 'view/dataformat'

module ODDB
	module View
		module Migel
class AccessoryList < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:migel_code
	}
	CSS_MAP = {
		[0,0] =>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'subheading'
	SORT_HEADER = false
	SORT_DEFAULT = :migel_code
	SYMBOL_MAP = {
		:migel_code	=>	PointerLink,
	}
end
class ProductInnerComposite < HtmlGrid::Composite
	include DataFormat
	SYMBOL_MAP = {
		:date		=> HtmlGrid::DateValue,
	}
	COMPONENTS = {
		[0,0] => :migel_code,
		[0,1]	=> :group,
		[0,2] => :subgroup,
		[0,3]	=> :product_text,
		[0,4]	=> :description,
		[0,5] => :limitation_text,
		[0,6] => :date,
		[0,7] => :price,
	}
	CSS_MAP = {
		[0,0,1,8] => 'list top',
		[1,0,1,8] => 'list',
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
		description(model.group, :group)
	end
	def limitation_text(model)
		description(model.limitation_text, :limitation_text)
	end
	def product_text(model)
		description(model.product_text, :product_text)
	end
	def subgroup(model)
		description(model.subgroup, :subgroup)
	end
end
class ProductComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=>	'migel_product',
		[0,1] =>  ProductInnerComposite,
		#[0,2] =>	:accessories,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	def accessories(model)
		acc = model.accessories
		if(!acc.empty?)
			AccessoryList.new(acc, @session, self)
		end
	end
end
class Product < View::PrivateTemplate
	CONTENT = ProductComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end

