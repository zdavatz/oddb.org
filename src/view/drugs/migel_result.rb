#!/usr/bin/env ruby
# View::MigelResult -- oddb -- 29.09.2005 -- ffricker@ywesee.com

require 'view/privatetemplate'
require 'view/additional_information'
require 'htmlgrid/list'
require 'view/dataformat'
require 'view/resultfoot'

module ODDB
	module View
		module Drugs
class MigelResultList < HtmlGrid::List
	include AdditionalInformation
	include DataFormat
	CSS_CLASS = 'composite'
	SYMBOL_MAP = {
		:date		=> HtmlGrid::DateValue
	}
	COMPONENTS = {
		[0,0] =>	:limitation_text,
		[1,0] =>	:migel_code,
		[2,0]	=>	:description,
		[3,0] =>  :date,
		[4,0] =>  :price,
	}
	CSS_MAP = {
		[0,0,4]	=>	'list',
		[4,0] =>	'list-r',
	}
	CSS_HEAD_MAP = {
		[0,0]	=> 'th',
		[1,0]	=> 'th',
		[2,0] => 'th',
		[3,0] => 'th',
		[4,0] => 'th-r',
	}
	LOOKANDFEEL_MAP = {
		:limitation_text => :nbsp,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	SORT_DEFAULT = nil
	WIDTH = 4
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
			item.send(@session.language)]
		@grid.add(values, xval, yval)
		@grid.add_style(css, xval, yval, 3)
		@grid.set_colspan(xval + 2, yval, WIDTH - xval - 1)
	end
	def description(model)
		model.send(@session.language)
	end
	def limitation_text(model)
		if(sltxt = model.limitation_text)
			limitation_link(sltxt)
		end
	end
end
class MigelResultComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=>	MigelResultList,
		[0,1]	=>	View::ResultFoot,
	}
end
class MigelResult < View::PrivateTemplate
	CONTENT = MigelResultComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
