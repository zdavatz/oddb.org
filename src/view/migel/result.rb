#!/usr/bin/env ruby
# ODDB::View::Migel::Result -- oddb.org -- 28.08.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Migel::Result -- oddb.org -- 04.10.2005 -- ffricker@ywesee.com

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
require 'view/lookandfeel_components'

module ODDB
	module View
		module Migel
class List < HtmlGrid::List
	include View::AdditionalInformation
	include DataFormat
  include View::LookandfeelComponents
	COMPONENTS = {}
	CSS_CLASS = 'composite'
  CSS_HEAD_KEYMAP = {
    :feedback             => 'th right',
    :google_search        => 'th right',
    :notify               => 'th right',
    :price                => 'th right',
  }
  CSS_KEYMAP = {
    :date                 => 'list',
    :feedback             => 'list right',
    :google_search        => 'list right',
    :limitation_text      => 'list',
    :migel_code           => 'list',
    :notify               => 'list right',
    :price                => 'list right',
    :product_description  => 'list',
    :qty_unit             => 'list',
  }
	CSS_HEAD_MAP = {}
	CSS_MAP = {}
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
    reorganize_components(:migel_list_components)
		@width = @components.keys.collect { |x, y| x }.max
		super
	end
  def limitation_link(model)
    link = HtmlGrid::Link.new(:square_limitation, nil, @session, self)
    #link.href = @lookandfeel._event_url(:resolve, {'pointer'=>CGI.escape(sltxt.pointer.to_s)})
    event = :migel_search
    key = :migel_limitation
    link.href = @lookandfeel._event_url(event, {key => model.migel_code.delete('.')})
    link.set_attribute('title', @lookandfeel.lookup(:limitation_text))
    pos = components.index(:limitation_text)
    link.css_class = "square infos"
    link
  end
	def limitation_text(model)
		if(sltxt = model.limitation_text and !sltxt.to_s.empty?)
			limitation_link(model)
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
    key = if model.migel_code.length == 2
            :migel_group
          elsif model.migel_code.length == 5
            :migel_subgroup
          else
            :migel_product
          end
    link.href = @lookandfeel._event_url(:migel_search, {key => model.migel_code.gsub(/\./, '')})
		link.value = text
		link
	end
  def migel_code(model)
    if model.respond_to?(:items) and items = model.items and !items.empty?
    # If a migelid has only inactive products, link to empty result
      link = PointerLink.new(:to_s, model, @session, self)
      link.value = model.migel_code
      link.href = @lookandfeel._event_url(:migel_search, {:migel_code => model.migel_code.gsub(/\./, '')})
      link
    else
      model.migel_code
    end
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
		values = [limitation_text(item), nil, migel_code(item), nil, product_description(item)]
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
