#!/usr/bin/env ruby
# View::Companies::Company -- oddb -- 27.05.2003 -- usenguel@ywesee.com

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

module ODDB
	module View
		module Doctors 
class Addresses < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:type,
		[0,1]	=>	:lines,
		[0,2] =>	:fons_header,
		[0,3]	=>	:fons,
		[0,4]	=>	:fax_header,
		[0,5]	=>	:fax,
	}
	SYMBOL_MAP = {
		:address_email	=>	HtmlGrid::MailLink,
		:praxis_header	=>	HtmlGrid::LabelText,
		:contact_email	=>	HtmlGrid::MailLink,
		:contact_header	=>	HtmlGrid::LabelText,
		:email_header		=>	HtmlGrid::LabelText,
		:fax_header			=>	HtmlGrid::LabelText,
		:fons_header		=>	HtmlGrid::LabelText,
		:nbsp						=>	HtmlGrid::Text,
		:phone_label		=>	HtmlGrid::Text,
		:work_header		=>	HtmlGrid::LabelText,
	}	
	CSS_MAP = {
		[0,0,1,6]	=> 'top address-width list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	SORT_DEFAULT = nil
	OMIT_HEADER = true
	OFFSET_STEP = [1,0]
	def fax_header(model) 
		if((fax = model.fax) && !fax.empty?)
			HtmlGrid::LabelText.new(:fax_header, model, @session, self)
		end
	end
	def fax(model)
		model.fax.join('<br>')
	end
	def fons(model)
		model.fon.join('<br>')
	end
	def lines(model)
		model.lines.join('<br>')
	end
	def type(model)
		HtmlGrid::LabelText.new("address_#{model.type}", model, @session, self)
	end
end
class DoctorInnerComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	:specialities_header,
		[0,1]	=>	:specialities,
		[0,2]		=>	:language_header,
		[0,2,1]	=>	:nbsp,
		[0,2,2]	=>	:language,
		[0,3]		=>	:exam_header,
		[0,3,1] =>	:nbsp,
		[0,3,2]	=>	:exam,
		[0,4]		=>	:email_header_doctor,
		[0,4,1]	=>	:nbsp,
		[0,4,2]	=>	:email,
	}
	SYMBOL_MAP = {
		:address_email	=>	HtmlGrid::MailLink,
		:praxis_header	=>	HtmlGrid::LabelText,
		:email	=>	HtmlGrid::MailLink,
		:contact_header	=>	HtmlGrid::LabelText,
		:email_header_doctor		=>	HtmlGrid::LabelText,
		:exam_header		=>	HtmlGrid::LabelText,
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
		[0,0,4,5]	=>	'list',
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
	COMPONENTS = {
		[0,0]		=>	:title,
		[0,0,1]	=>	:nbsp,
		[0,0,2]	=>	:firstname,
		[0,0,3]	=>	:nbsp,
		[0,0,4]	=>	:name,
		[0,1]	=> DoctorInnerComposite,
		[0,2]		=>	:addresses,
	}
	SYMBOL_MAP = {
		:nbsp						=>	HtmlGrid::Text,
	}	
	CSS_MAP = {
		[0,0]	=> 'th',
	}
	CSS_CLASS = 'composite'
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	def addresses(model)
		Addresses.new(model.addresses, @session, self)
	end
end
class Doctor < PrivateTemplate
	CONTENT = View::Doctors::DoctorComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
