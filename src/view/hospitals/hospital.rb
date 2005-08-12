#!/usr/bin/env ruby
# View::Hospitals::Hospital -- oddb -- 09.03.2005 -- usenguel@ywesee.com, jlang@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/labeltext'
require 'htmlgrid/select'
require 'htmlgrid/text'
require 'htmlgrid/urllink'
require 'htmlgrid/value'
require 'htmlgrid/inputfile'
require	'htmlgrid/errormessage'
require	'htmlgrid/infomessage'
require 'view/descriptionform'
require 'view/form'
require 'view/pointervalue'
require 'view/privatetemplate'
require 'view/sponsorlogo'
require 'view/address'


module ODDB
	module View
		module Hospitals 
class HospitalInnerComposite < HtmlGrid::Composite
	include VCardMethods
	include AddressMap
	COMPONENTS = {
		[0,0]			=>	:business_unit_header,
		[0,0,1]		=>	:nbsp,
		[0,0,2]		=>	:business_unit,
		[0,1]		=>	:ean13_header,
		[0,1,1]	=>	:nbsp,
		[0,1,2]	=>	:ean13,
		[0,2]			=>	:address_header,
		[0,3]			=>	:address,
		#[0,12]		=>	:map,
		[0,4]		=>	:vcard,
	}
	SYMBOL_MAP = {
		:business_unit_header	=>	HtmlGrid::LabelText,
		:address_header	=>	HtmlGrid::LabelText,
		:ean13_header		=>	HtmlGrid::LabelText,
		:fons_header		=>	HtmlGrid::LabelText,
		:fax_header			=>	HtmlGrid::LabelText,
		:nbsp						=>	HtmlGrid::Text,
		:url						=>	HtmlGrid::HttpLink,
	}		
	CSS_MAP = {
		[0,0,1,3] => 'list',
		[0,4,1,2] => 'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	def mapsearch_format(*args)
		args.compact.join('-').gsub(/\s+/, '-')
	end		
	def address(model)
		Address.new(model.addresses.first, @session, self)
	end
	def location(model)
		if(addr = model.addresses.first)
			addr.location
		end
	end
end
class HospitalComposite < HtmlGrid::Composite
	include VCardMethods
	COMPONENTS = {
		[0,0]		=>	:title,
		[0,0,1]	=>	:nbsp,
		[0,0,2]	=>	:firstname,
		[0,0,3]	=>	:nbsp,
		[0,0,4]	=>	:name,
		[0,1]		=> HospitalInnerComposite,
		#[0,3]		=>	:vcard,
	}
	SYMBOL_MAP = {
		:nbsp						=>	HtmlGrid::Text,
	}	
	CSS_MAP = {
		[0,0]	=> 'th',
		[0,1]	=> 'list',
	}
	CSS_CLASS = 'composite'
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
end
class Hospital < PrivateTemplate
	CONTENT = View::Hospitals::HospitalComposite
	SNAPBACK_EVENT = :result
end
class EmptyResultForm < HtmlGrid::Form
	COMPONENTS = {
		[0,0]		=>	:search_query,
		[0,0,1]	=>	:submit,
		[0,1]		=>	:title_none_found,
		[0,2]		=>	'e_empty_result',
		[0,3]		=>	'explain_search_hospital',
	}
	CSS_MAP = {
		[0,0]			=>	'search',	
		[0,1]			=>	'th',
		[0,2,1,2]	=>	'result-atc',
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
class EmptyResult < View::PublicTemplate
	CONTENT = View::Hospitals::EmptyResultForm
end
		end
	end
end
