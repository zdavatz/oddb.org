#!/usr/bin/env ruby
# View::Hospitals::HospitalList -- oddb -- 25.02.2005 --usenguel@ywesee.com, jlang@ywesee.com

require 'htmlgrid/value'
require 'htmlgrid/link'
require 'htmlgrid/urllink'
require 'htmlgrid/list'
require 'util/umlautsort'
require 'view/pointervalue'
require 'view/descriptionvalue'
require 'view/form'
require 'view/resultcolors'
require 'view/publictemplate'
require 'view/alphaheader'

module ODDB
	module View
		module Hospitals
class HospitalList < HtmlGrid::List
	include UmlautSort
	include AddressMap
	include VCardMethods
	COMPONENTS = {
		[0,0]	=>	:name,
		[1,0]	=>	:business_unit,
		[2,0]	=>	:location,
		[3,0]	=>	:plz,
		[4,0]	=>	:canton,
		[5,0]	=>	:map,
		[6,0]	=>	:vcard,
	}	
	DEFAULT_CLASS = HtmlGrid::Value
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'list',
		[1,0]	=>	'list',
		[2,0]	=>	'list',
		[3,0]	=>	'list',
		[4,0]	=>	'list',
		[5,0]	=>	'list',
		[6,0]	=>	'list',
	}
	CSS_HEAD_MAP = {
		[0,0] =>	'th',
		[1,0] =>	'th',
		[2,0] =>	'th',
		[3,0] =>	'th',
		[4,0] =>	'th',
		[5,0] =>	'th',
		[6,0] =>	'th',
	}
	LOOKANDFEEL_MAP = {
		:name						=>	:hospital_name,
		:canton					=>	:canton,
		#:url						=>	:company_url,
   	#:contact				=>	:company_contact,
	}
	SORT_DEFAULT = :name
	SORT_REVERSE = false	
	LEGACY_INTERFACE = false
	def init
		if(@session.state.paged?)
			extend(View::AlphaHeader)
		end
		super
	end
	def name(model)
		link = View::PointerLink.new(:name, model, @session, self)
		link.set_attribute('title', "EAN: #{model.ean13}")
		link
	end
end
class HospitalsComposite < Form
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]		=>	:search_query,
		[0,0,1]	=>	:submit,
		[0,1]		=>	:hospital_list,
	}
	EVENT = :search
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,	
		:map						=>	HtmlGrid::Link,
		:vcard					=>	HtmlGrid::Link,
	}
	def hospital_list(model, session)
		HospitalList.new(model, session, self)
	end
	def name(model, session)
		link = View::PointerLink.new(:name, model, session, self)
	end
end
class Hospitals < View::PublicTemplate
	CONTENT = View::Hospitals::HospitalsComposite
end
		end
	end
end
