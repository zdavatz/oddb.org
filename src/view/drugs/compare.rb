#!/usr/bin/env ruby
# View::Drugs::Compare -- oddb -- 20.03.2003 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/datevalue'
require 'htmlgrid/list'
require 'view/drugs/privatetemplate'
require 'view/resultcolors'
require 'view/resultfoot'
require 'view/dataformat'
require 'view/sponsorhead'

module ODDB
	module View
		module Drugs
class CompareList < HtmlGrid::List
	include DataFormat
	include View::ResultColors
	include View::AdditionalInformation
	COMPONENTS = {}
	CSS_CLASS = 'composite'
	CSS_KEYMAP = {
		:active_agents     => 'list italic',
		:company_name			 => 'list italic',
		:comparable_size	 => 'list',
		:ddd_price				 => 'list right',
		:deductible				 => 'list right',
		:ikscat						 => 'list italic',
		:most_precise_dose => 'list right',
		:name_base				 => 'list big',
		:price_difference	 => 'list bold right',
		:price_public			 => 'list pubprice',
	}
	CSS_HEAD_KEYMAP = {
		:active_agents     => 'th',
		:company_name			 => 'th',
		:comparable_size	 => 'th',
		:ddd_price				 => 'th right',
		:deductible				 => 'th right',
		:ikscat						 => 'th',
		:most_precise_dose => 'th right',
		:name_base				 => 'th',
		:price_difference	 => 'th right',
		:price_public			 => 'th right',
	}
	CSS_HEAD_MAP = {}
	CSS_MAP = {}
	DEFAULT_CLASS = HtmlGrid::Value
	SORT_DEFAULT = nil
	SORT_HEADER = false
	SORT_REVERSE = false
	SYMBOL_MAP = {
		:registration_date	=>	HtmlGrid::DateValue,
	}
	def init
		reorganize_components
		super
	end
	def reorganize_components
		@components = @lookandfeel.compare_list_components
		@css_map = {}
		@css_head_map = {}
		@components.each { |key, val|
			if(klass = self::class::CSS_KEYMAP[val])
				@css_map.store(key, klass)
				@css_head_map.store(key, self::class::CSS_HEAD_KEYMAP[val] || 'th')
			end
		}
	end
	def package_line(offset)
		_compose(@model.package, offset)
		#compose_components(package, offset)
		#compose_css(offset, resolve_suffix(package, false))
	end
	def compose_empty_list(offset)
		package_line(offset)
		text = @lookandfeel.lookup(:no_comparables)
		offset = resolve_offset(offset, self::class::OFFSET_STEP)
		@grid.add(text, *offset)
		@grid.add_style('list', *offset)
		@grid.set_colspan(*offset)
	end
	def compose_list(model=@model, offset=[0,0])
		package_line(offset)
		offset = resolve_offset(offset, self::class::OFFSET_STEP)
		#offset = resolve_offset(offset, self::class::OFFSET_STEP)
		super(model.comparables, offset)
	end
	def price_difference(model, session)
		if(diff = model.price_difference)
			sprintf('%+d%', diff*100.0)
		end
	end
	def active_agents(model, session)
		model.active_agents.join(',<br>')
	end
end
class CompareComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0] => CompareList,
		[0,1] => View::ResultFoot,
	}
	CSS_MAP = {
		[0,1]	=>	'explain list',
	}
end
class Compare < PrivateTemplate
	include View::SponsorMethods
	CONTENT = CompareComposite
	SNAPBACK_EVENT = :result
end
class EmptyCompareComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	'compare_title_no_atc',
		[0,1]		=>	:compare_desc0_no_atc,
		[0,2,0]	=>	:compare_desc1_no_atc,
		[0,2,1]	=>	:ywesee_contact_email,
		[0,2,2]	=>	'point',
	}
	CSS_MAP = {
		[0,0]			=>	'th',
		[0,1,1,2]	=>	'list',
	}
	CSS_CLASS = 'composite'
	def compare_desc0_no_atc(model, session)
		query = model.package.name_base
		@lookandfeel.lookup(:compare_desc0_no_atc, query)
	end
	def compare_desc1_no_atc(model, session)
		query = model.package.name_base
		@lookandfeel.lookup(:compare_desc1_no_atc, query)
	end
	def ywesee_contact_email(model, session)
		link = HtmlGrid::Link.new(:ywesee_contact_email, model, session, self)
		link.href = @lookandfeel.lookup(:ywesee_contact_href)
		link.attributes['class'] = 'text'
		link
	end
end
class EmptyCompare < PrivateTemplate
	CONTENT = View::Drugs::EmptyCompareComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
