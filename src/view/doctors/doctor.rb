#!/usr/bin/env ruby
# View::Doctors::Doctor -- oddb -- 27.05.2003 -- usenguel@ywesee.com

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
require 'view/address'
require 'view/pointervalue'
require 'view/privatetemplate'
require 'view/sponsorlogo'

module ODDB
	module View
		module Doctors 
class Addresses < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	Address, 
	}
	CSS_MAP = {
		[0,0]	=>	'top',
	}
	SORT_DEFAULT = nil
	OMIT_HEADER = true
	OFFSET_STEP = [1,0]
	CSS_CLASS = 'component'
	BACKGROUND_SUFFIX = ' bg'
end
class DoctorInnerComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	:specialities_header,
		[0,1]	  =>	:specialities,
		[0,2,0]	=>	:language_header,
		[0,2,1]	=>	:nbsp,
		[0,2,2]	=>	:language,
		[0,3,0]	=>	:exam_header,
		[0,3,1] =>	:nbsp,
		[0,3,2]	=>	:exam,
		[0,4,0]	=>	:ean13_header,
		[0,4,1]	=>	:nbsp,
		[0,4,2]	=>	:ean13,
		[0,5,0]	=>	:email_header_doctor,
		[0,5,1]	=>	:nbsp,
		[0,5,2]	=>	:email,
	}
	SYMBOL_MAP = {
		:address_email	=>	HtmlGrid::MailLink,
		:praxis_header	=>	HtmlGrid::LabelText,
		:email	=>	HtmlGrid::MailLink,
		:contact_header	=>	HtmlGrid::LabelText,
		:email_header_doctor		=>	HtmlGrid::LabelText,
		:exam_header		=>	HtmlGrid::LabelText,
		:ean13_header		=>	HtmlGrid::LabelText,
		:language_header	=>	HtmlGrid::LabelText,
		:nbsp						=>	HtmlGrid::Text,
		:phone_label		=>	HtmlGrid::Text,
		:fax_label			=>	HtmlGrid::Text,
		:specialities_header => HtmlGrid::LabelText,
		:url						=>	HtmlGrid::HttpLink,
		:url_header			=>	HtmlGrid::LabelText,
		:work_header		=>	HtmlGrid::LabelText,
	}		
	CSS_MAP = {
		[0,0,4,6]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	def praxis_address(model)
		if(address = model.praxis_address)
			address.lines.join('<br>')
		end
	end
	def specialities(model)
		spc = model.specialities
		spc.join('<br>') unless spc.nil?
	end
end
class DoctorComposite < HtmlGrid::Composite
	include VCardMethods
	COMPONENTS = {
		[0,0,0]	=>	:title,
		[0,0,1]	=>	:nbsp,
		[0,0,2]	=>	:firstname,
		[0,0,3]	=>	:nbsp,
		[0,0,4]	=>	:name,
		[0,1]		=> DoctorInnerComposite,
		[0,2]		=>	:addresses,
		[0,3]		=>	:vcard,
	}
	SYMBOL_MAP = {
		:nbsp						=>	HtmlGrid::Text,
	}	
	CSS_MAP = {
		[0,0]	=> 'th',
		[0,2]	=> 'top',
		[0,3]	=> 'list',
	}
	CSS_CLASS = 'composite'
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	def addresses(model)
		addrs = model.addresses
		if(addrs.empty?)
			addrs = addrs.dup
			addr = Address2.new
			addr.pointer = model.pointer + [:address, 0]
			addrs.push(addr)
		end
		Addresses.new(addrs, @session, self)
	end
end
class Doctor < PrivateTemplate
	CONTENT = View::Doctors::DoctorComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
