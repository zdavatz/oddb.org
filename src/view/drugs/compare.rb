#!/usr/bin/env ruby
# View::Drugs::Compare -- oddb -- 20.03.2003 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/datevalue'
require 'htmlgrid/list'
require 'view/popuptemplate'
require 'view/resultcolors'
require 'view/resultfoot'
require 'view/dataformat'

module ODDB
	module View
		module Drugs
class CompareList < HtmlGrid::List
	include DataFormat
	include View::ResultColors
	COMPONENTS = {
		[0,0]	=>	:name_base,
		[1,0]	=>	:company_name,
		[2,0]	=>	:most_precise_dose,
		[3,0]	=>	:size,
		[4,0] =>	:active_agents,
		[5,0]	=>	:price_public,
		[6,0]	=>	:price_difference, 
		[7,0]	=>	:ikscat,
	}	
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'result-big',
		[1,0]	=>	'result-i',
		[2,0]	=>	'result-r',
		[3,0]	=>	'result',
		[4,0]	=>	'result-i',
		[5,0]	=>	'result-pubprice',
		[6,0]	=>	'result-b-r',
		[7,0]	=>	'result-i',
	}
	CSS_HEAD_MAP = {
		[0,0] =>	'th',
		[1,0] =>	'th',
		[2,0] =>	'th-r',
		[3,0]	=>	'th',
		[4,0]	=>	'th',
		[5,0]	=>	'th-pad-r',
		[6,0]	=>	'th-r',
		[7,0] =>	'th',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	SORT_DEFAULT = nil
	SORT_HEADER = false
	SORT_REVERSE = false
	SYMBOL_MAP = {
		:registration_date	=>	HtmlGrid::DateValue,
	}
	def package_line(offset)
		package = @model.package
		compose_components(package, offset)
		compose_css(offset, resolve_suffix(package, false))
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
	def name_base(model, session)
		txt = HtmlGrid::Component.new(model, session, self)
		txt.set_attribute('title', 'EAN-Code:&nbsp;'+model.barcode)
		txt.value = model.name_base 
		txt
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
end
class Compare < View::PrivateTemplate
	SNAPBACK_EVENT = :result
	CONTENT = CompareComposite
end

class EmptyCompareComposite < HtmlGrid::Composite

	COMPONENTS = {
		[0,0]		=>	'compare_title_no_atc',
		[0,1]		=>	:compare_desc0_no_atc,
		[0,2]		=>	:compare_desc1_no_atc,
		[0,2,0]	=>	:ywesee_contact_email,
		[0,2,1]	=>	'point',
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
class EmptyCompare < View::PrivateTemplate
	CONTENT = View::Drugs::EmptyCompareComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
