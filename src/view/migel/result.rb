#!/usr/bin/env ruby
# View::Migel::Result -- oddb -- 04.10.2005 -- ffricker@ywesee.com

require 'htmlgrid/list'
require 'htmlgrid/value'
require 'htmlgrid/urllink'
require 'iconv'
require 'model/migel/product'
require 'util/language'
require 'view/additional_information'
require 'view/dataformat'
require 'view/privatetemplate'
require 'view/pointervalue'
require 'view/resultfoot'


module ODDB
	module View
		module Migel
class ResultList < HtmlGrid::List
	include AdditionalInformation
	include DataFormat
	CSS_CLASS = 'composite'
	SYMBOL_MAP = {
		:date		=> HtmlGrid::DateValue,
	}
	COMPONENTS = {
		[0,0] =>	:limitation_text,
		[1,0] =>	:migel_code,
		[2,0]	=>	:product_description,
		[3,0] =>  :date,
		[4,0] =>  :price,
		[5,0]	=>  :google_search,
		[6,0] =>  :notify,
	}
	CSS_MAP = {
		[0,0,6]	=>	'list',
		[6,0] =>	'list-r',
	}
	CSS_HEAD_MAP = {
		[0,0]	=> 'th',
		[1,0]	=> 'th',
		[2,0] => 'th',
		[3,0] => 'th',
		[4,0] => 'th',
		[5,0] => 'th',
		[6,0] => 'th-r',
	}
	LOOKANDFEEL_MAP = {
		:limitation_text => :nbsp,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	SORT_DEFAULT = nil
	WIDTH = 6
	LEGACY_INTERFACE = false
	def compose_list(model=@model, offset=[0,0])
		bg_flag = false
		group = nil
		model.each { |subgroup|
			if(group != subgroup.group)
				group = subgroup.group
				compose_subheader(group, offset, 'migel-group')
				offset = resolve_offset(offset, self::class::OFFSET_STEP)
			end
			compose_subheader(subgroup, offset)
			offset = resolve_offset(offset, self::class::OFFSET_STEP)
			products = subgroup.products
			super(products, offset)
			offset[1] += products.size
		}
	end
	def compose_subheader(item, offset, css='result-atc')
		xval, yval = offset
		values = [limitation_text(item), item.migel_code, 
			product_description(item)]
		@grid.add(values, xval, yval)
		@grid.add_style(css, xval, yval, 3)
		@grid.set_colspan(xval + 2, yval, WIDTH - xval - 1)
	end
	def google_search(model)
		text = [
			(model.product_text if(model.respond_to?(:product_text))),
			model
		].compact.collect { |item| 
			item.send(@session.language) 
		}.join(': ').gsub("\n", ' ')
		glink = CGI.escape(Iconv.iconv('UTF-8', 'ISO_8859-1', text).first)
		link = HtmlGrid::Link.new(:google_search, @model, @session, self)
		link.href =  "http://www.google.com/search?q=#{glink}"
		link.css_class= 'google_search square'
		link.set_attribute('title', "#{@lookandfeel.lookup(:google_alt)}#{text}")
		link
	end
	def limitation_text(model)
		if(sltxt = model.limitation_text)
			limitation_link(sltxt)
		end
	end
	def notify(model)
		link = HtmlGrid::Link.new(:notify, model, @session, self)
		args = {
			:pointer => CGI.escape(model.pointer.to_s),
		}
		link.href = @lookandfeel._event_url(:notify, args)
		img = HtmlGrid::Image.new(:notify, model, @session, self)
		img.set_attribute('src', @lookandfeel.resource_global(:notify))
		link.value = img
		link.set_attribute('title', @lookandfeel.lookup(:notify_alt))
		link
	end
	def product_description(model)
		link = PointerLink.new(:to_s, model, @session, self)
		text = [
			(model.product_text if(model.respond_to?(:product_text))),
			model
		].compact.collect { |item| 
			item.send(@session.language) 
		}.join(': ').gsub("\n", ' ')
		link.value = text
		link
	end
end
class ResultComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=>	ResultList,
		[0,1]	=>	View::ResultFoot,
	}
end
class Result < View::PrivateTemplate
	CONTENT = ResultComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
