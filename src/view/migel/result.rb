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
class List < HtmlGrid::List
	include View::AdditionalInformation
	include DataFormat
	COMPONENTS = {
		[0,0] =>	:limitation_text,
		[1,0] =>	:migel_code,
		[2,0]	=>	:product_description,
		[3,0] =>  :date,
		[4,0] =>  :price,
		[5,0]	=>	:qty_unit,
	}
	CSS_CLASS = 'composite'
	CSS_HEAD_MAP = {
		[0,0]	=> 'th',
		[1,0]	=> 'th',
		[2,0] => 'th',
		[3,0] => 'th',
		[4,0] => 'th right',
		[5,0] => 'th',
	}
	CSS_MAP = {
		[0,0,4]	=>	'list',
		[4,0] =>	'list right',
		[5,0]		=>	'list',
	}
	LOOKANDFEEL_MAP = {
		:limitation_text => :nbsp,
	}
	SORT_HEADER = false
	SYMBOL_MAP = {
		:date		=> HtmlGrid::DateValue,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	SORT_DEFAULT = nil
	LEGACY_INTERFACE = false
	def init
		@width = 5
		unless(@lookandfeel.enabled?(:atupri_web, false))
			@width += 3
			components.update({
				[6,0] =>	:feedback,
				[7,0]	=>  :google_search,
				[8,0] =>  :notify,
			})
			css_map.store([6,0,3], 'list right')
			css_head_map.update({
				[6,0] => 'th right',
				[7,0] => 'th right',
				[8,0] => 'th right',
			})
		end
		super
	end
	def limitation_text(model)
		if(sltxt = model.limitation_text)
			limitation_link(sltxt)
		else
			''
		end
	end
	def product_description(model)
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
		link
	end
end
class ResultList < View::Migel::List
	def compose_list(model=@model, offset=[0,0])
		bg_flag = false
		group = nil
		model.each { |subgroup|
			if(group != subgroup.group)
				group = subgroup.group
				compose_subheader(group, offset, 'list migel-group')
				offset = resolve_offset(offset, self::class::OFFSET_STEP)
			end
			compose_subheader(subgroup, offset)
			offset = resolve_offset(offset, self::class::OFFSET_STEP)
			products = subgroup.products
			super(products, offset)
			offset[1] += products.size
		}
	end
	def compose_subheader(item, offset, css='list atc')
		xval, yval = offset
		values = [limitation_text(item), nil, item.migel_code, nil,
			product_description(item)]
		@grid.add(values, xval, yval)
		@grid.add_style(css, xval, yval, 3)
		@grid.set_colspan(xval + 2, yval, @width - xval - 1)
	end
end
class ExplainResult < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'explain_migel_position',
		[0,1]	=>	'explain_migel_date',
		[0,2]	=>	'explain_migel_price',
	}
	CSS_MAP = {	
		[0,0,1,3]	=>	'explain infos',
	}
end
class ResultComposite < HtmlGrid::Composite
	include ResultFootBuilder
	EXPLAIN_RESULT = View::Migel::ExplainResult
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=>	ResultList,
		[0,1]	=>	:result_foot,
	}
end
class Result < View::PrivateTemplate
	CONTENT = ResultComposite
	SNAPBACK_EVENT = :result
end
class EmptyResultForm < HtmlGrid::Form
	COMPONENTS = {
		[0,0,0]	=>	:search_query,
		[0,0,1]	=>	:submit,
		[0,1]		=>	:title_none_found,
		[0,2]		=>	'e_empty_result',
		[0,3]		=>	'e_empty_migel_result',
	}
	CSS_MAP = {
		[0,0]			=>	'search',	
		[0,1]			=>	'th',
		[0,2,1,2]	=>	'list atc',
	}
	CSS_CLASS = 'composite'
	EVENT = :search
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,	
	}
	def title_none_found(model, session)
		query = session.persistent_user_input(:search_query)
		@lookandfeel.lookup(:title_none_found, query)
	end
end
class EmptyResult < View::ResultTemplate
	CONTENT = EmptyResultForm
end
		end
	end
end
