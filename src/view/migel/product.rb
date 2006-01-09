#!/usr/bin/env ruby
# View::Migel::Product -- oddb -- 05.10.2005 -- ffricker@ywesee.com

require 'view/dataformat'
require 'view/privatetemplate'
require 'view/pointervalue'
require 'view/migel/result'
require 'model/migel/product'
require 'htmlgrid/urllink'
require 'view/additional_information'

module ODDB
	module View
		module Migel
class AccessoryList < HtmlGrid::List
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
		:migel_code	=>	:title_accessories,
		:description	=>	:nbsp,
	}
end
class AccessoryOfList < AccessoryList	
	LOOKANDFEEL_MAP = {
		:migel_code	=>	:title_accessories_of,
		:description	=>	:nbsp,
	}
end
class ProductInnerComposite < HtmlGrid::Composite
	include AdditionalInformation
	include DataFormat
	SYMBOL_MAP = {
		:date		=> HtmlGrid::DateValue,
		:feedback_label	=> HtmlGrid::LabelText,
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
		[1,7]	=> :qty_unit, 
		[0,8] => :feedback_label,
		[1,8] => :feedback,
	}
	CSS_MAP = {
		[0,0,1,9] => 'list top',
		[1,0,1,9] => 'list',
	}
	LABELS = true
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	@@migel_pattern = /(\d\d)(?:\.(\d\d)(?:\.(\d\d\.\d\d\.\d))?)?/
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
		obj = description(model.limitation_text, :limitation_text)
		if(str = obj.value)
			obj.value = str.gsub(@@migel_pattern) {
				code = $~[1]
				ptr = Persistence::Pointer.new([:migel_group, code])
				if(code = $~[2])
					ptr += [:subgroup, code]
					if(code = $~[3])
						ptr += [:product, code]
					end
				end
				args = {:pointer => ptr}
				'<a class="list" href="' << @lookandfeel._event_url(:resolve, args) << 
					'">' << $~[0] << '</a>'
			}
		end
		obj
	end
	def subgroup(model)
		pointer_link(model.subgroup)
	end
	def pointer_link(model)
		link = PointerLink.new(:to_s, model, @session, self)
		link.value = model.send(@session.language)
		link
	end
	def product_text(model)
		description(model.product_text, :product_text)
	end
end
class ProductComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=>	'migel_product',
		[0,1] =>  ProductInnerComposite,
		[0,2] =>	:accessories,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,2]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	def accessories(model)
		acc = model.accessories
		prods = model.products
		if(!acc.empty?)
			AccessoryList.new(acc, @session, self)
		elsif(!prods.empty?)
			AccessoryOfList.new(prods, @session, self)
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
