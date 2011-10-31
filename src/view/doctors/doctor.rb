#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Doctors::Doctor -- oddb.org -- 31.10.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Doctors::Doctor -- oddb.org -- 27.05.2003 -- usenguel@ywesee.com

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
		[0,2]		=>	:capabilities_header,
		[0,3]	  =>	:capabilities,
		[0,4,0]	=>	:language_header,
		[0,4,1]	=>	:nbsp,
		[0,4,2]	=>	:correspondence,
		[0,5,0]	=>	:exam_header,
		[0,5,1] =>	:nbsp,
		[0,5,2]	=>	:exam,
		[0,6,0]	=>	:ean13_header,
		[0,6,1]	=>	:nbsp,
		[0,6,2]	=>	:ean13,
		[0,7,0]	=>	:email_header_doctor,
		[0,7,1]	=>	:nbsp,
		[0,7,2]	=>	:email,
	}
	SYMBOL_MAP = {
		:address_email	=>	HtmlGrid::MailLink,
		:capabilities_header => HtmlGrid::LabelText,
		:email	=>	HtmlGrid::MailLink,
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
		[0,0,4,8]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	def specialities(model)
		spc = model.specialities
		spc.join('<br>') unless spc.nil?
	end
	def capabilities(model)
		spc = model.capabilities
		spc.join('<br>') unless spc.nil?
	end
end
class DoctorForm < View::Form
  include HtmlGrid::ErrorMessage
  COMPONENTS = {
    [0,0] => :title,
    [0,1] => :name_first,
    [2,1] => :name,
    [0,2] => :specialities,
    [0,3] => :capabilities,
    [0,4] => :correspondence,
    [0,5] => :exam,
    [0,6] => :ean13,
    [0,7] => :email,
    [1,8] => :submit,
  }
  COLSPAN_MAP = {
    [1,2] => 3,
    [1,3] => 3,
  }
	COMPONENT_CSS_MAP = {
		[0,0]	=>	'standard',
		[0,1]	=>	'standard',
		[2,1]	=>	'standard',
		#[0,2]	=>	'standard',
		#[0,3]	=>	'standard',
		[0,4]	=>	'standard',
		[0,5]	=>	'standard',
		[0,6]	=>	'standard',
		[0,7]	=>	'standard',
	}
	CSS_MAP = {
		[0,0,4,8]	=>	'list',
		[0,2,1,2]	=>	'list top',
	}
  LABELS = true
	LEGACY_INTERFACE = false
  def init
    super
    error_message
  end
  def capabilities(model)
    input = HtmlGrid::Textarea.new(:capabilities, model, @session, self)
    input.label = true
    input
  end
  def specialities(model)
    input = HtmlGrid::Textarea.new(:specialities, model, @session, self)
    input.label = true
    input
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
			addr = ODDB::Address2.new
			addr.pointer = model.pointer + [:address, 0]
			addrs.push(addr)
		end
		Addresses.new(addrs, @session, self)
	end
  def vcard(model)
    link = View::PointerLink.new(:vcard, model, @session, self)
    ean_or_oid = if ean = model.ean13 and ean.to_s.strip != ""
                   ean
                 else
                   model.oid
                 end
    link.href = @lookandfeel._event_url(:vcard, {:doctor => ean_or_oid})
    link
  end
end
class RootDoctorComposite < DoctorComposite
	COMPONENTS = {
		[0,0,0]	=>	:title,
		[0,0,1]	=>	:nbsp,
		[0,0,2]	=>	:firstname,
		[0,0,3]	=>	:nbsp,
		[0,0,4]	=>	:name,
		[0,1]		=> DoctorForm,
		[0,2]		=>	:addresses,
		[0,3]		=>	:vcard,
	}
end
class Doctor < PrivateTemplate
	CONTENT = View::Doctors::DoctorComposite
	SNAPBACK_EVENT = :result
end
class RootDoctor < PrivateTemplate
	CONTENT = RootDoctorComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
