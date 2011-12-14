#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Migel::Subgroup -- oddb.org -- 09.09.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Migel::Subgroup -- oddb.org -- 05.10.2005 -- ffricker@ywesee.com

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
	LEGACY_INTERFACE = false
	LOOKANDFEEL_MAP = {
		:migel_code	=>	:title_product,
		:description	=>	:nbsp,
	}
  def migel_code(model)
    if (items = model.items and !items.empty?)
      link = PointerLink.new(:migel_code, model, @session, self)
      event = :migel_search
      key = :migel_code
      link.href = @lookandfeel._event_url(event, {key => model.migel_code.delete('.')})
		  link
    else
      model.migel_code
    end
  end
	def description(model)
		link = PointerLink.new(:to_s, model, @session, self)
		text = [
			model,
			(model.product_text if(model.respond_to?(:product_text))),
		].compact.collect { |item| 
			item.send(@session.language) 
		}.join(': ').gsub("\n", ' ')
		if(text.size > 60)
			text = text[0,57] << '...'
		end
		link.value = text
    event = :migel_search
    key = :migel_product
    link.href = @lookandfeel._event_url(event, {key => model.migel_code.delete('.')})
		link
	end
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
    event = :migel_search
    key = :migel_group
    link.href = @lookandfeel._event_url(event, {key => model.migel_code})
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
# Note: ODDB::View::Migel::PointerSteps is defined in src/view/migel/product.rb
class Subgroup < View::PrivateTemplate
	CONTENT = SubgroupComposite
	SNAPBACK_EVENT = :result
  def backtracking(model, session=@session)
    ODDB::View::Migel::PointerSteps.new(model, @session, self)
  end
end
		end
	end
end
