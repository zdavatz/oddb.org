#!/usr/bin/env ruby
# View::Companies::Company -- oddb -- 27.05.2003 -- mhuggler@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/labeltext'
require 'htmlgrid/select'
require 'htmlgrid/text'
require 'htmlgrid/link'
require 'htmlgrid/urllink'
require 'htmlgrid/value'
require 'htmlgrid/inputfile'
require	'htmlgrid/errormessage'
require	'htmlgrid/infomessage'
require 'view/address'
require 'view/descriptionform'
require 'view/form'
require 'view/pointervalue'
require 'view/resulttemplate'
require 'view/sponsorlogo'

module ODDB
	module View
		module Companies
class InactiveRegistrations < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:iksnr,
		[1,0]	=>	:name_base,
		[2,0]	=>	:inactive_date,
		[3,0]	=>	:market_date,
	}
	CSS_MAP = {
		[0,0,3]	=>	'list',
		[3,0]		=> 'result-infos',
	}
	COMPONENT_CSS_MAP = {
		[3,0]			=> 'result-infos',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'subheading'
	EVENT = :new_sequence
	SORT_HEADER = false
	SORT_DEFAULT = :iksnr
	SYMBOL_MAP = {
		:iksnr	=>	View::PointerLink,
	}
	CSS_CLASS = 'composite'
end
class UnknownCompanyInnerComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	:contact_header,
		[0,1]		=>	:contact,
		[0,2]		=>	:email_header,
		[0,3]		=>	:contact_email,
		[0,4]		=>	:address_header,
		[0,5]		=>	:address,
		#[0,5]		=>	:address,
		#[2,5]		=>	:phone_label,
		#[2,5,0]	=>	:nbsp,
		#[2,5,1]	=>	:phone,
		#[0,6]		=>	:plz,
		#[0,6,0]	=>	:nbsp,
		#[0,6,1]	=>	:city,
		#[2,6]		=>	:fax_label,
		#[2,6,0]	=>	:nbsp,
		#[2,6,1]	=>	:fax,
		[0,6]	=>	:nbsp,
		[0,7]		=>	:url_header,
		[0,8]		=>	:url,
		[1,8]		=>	:address_email,
	}
	SYMBOL_MAP = {
		:address_email	=>	HtmlGrid::MailLink,
		:address_header	=>	HtmlGrid::LabelText,
		:contact_email	=>	HtmlGrid::MailLink,
		:contact_header	=>	HtmlGrid::LabelText,
		:email_header		=>	HtmlGrid::LabelText,
		:nbsp						=>	HtmlGrid::Text,
		:phone_label		=>	HtmlGrid::Text,
		:fax_label			=>	HtmlGrid::Text,
		:url						=>	HtmlGrid::HttpLink,
		:url_header			=>	HtmlGrid::LabelText,
	}	
	CSS_MAP = {
		[0,0,2,5]	=>	'list',
		[0,6,2,3]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	def address(model)
		Address.new(model.address(0), @session, self)
	end
=begin
	def address(model, session)
		address_delegate(model, :address)
	end
	def city(model, session)
		address_delegate(model, :city)
	end
	def plz(model, session)
		address_delegate(model, :plz)
	end
	def address_delegate(model, data)
		if(addr = model.addresses.first)
			addr.send(data)
		end
	end
=end
end
class UserCompanyForm < View::Form
	include HtmlGrid::ErrorMessage
	include HtmlGrid::InfoMessage
	COMPONENTS = {
		[0,0]			=>	:company_name,
		[0,1]			=>	:contact,
		[2,1]			=>	:contact_email,
		[2,2]			=>	:regulatory_email,
		[1,2]			=>	:set_pass,
		[0,4]			=>	:address,
		[0,5]			=>	:plz,
		[2,5]			=>	:city,
		[0,6]			=>	:phone,
		[2,6]			=>	:fax,
		[0,7]			=>	:url,
		[2,7]			=>	:address_email,
		[0,9]			=>	:business_area,
		[2,9]			=>	:ean13,
		[0,10]		=>	:registration_count,
		#[2,10]		=>	:fi_status,
		#[2,11]    =>  :pi_status,
		[0,11]		=>	:generic_type,
		[2,11]		=>	:complementary_type,
		[1,12]		=>	:submit,
		[3,12]		 =>	:patinfo_stats,
	}
	CSS_MAP = {
		[0,0,4,13]	=>	'list',
	}
	LABELS = true
	SYMBOL_MAP = {
		:nbsp									=>	HtmlGrid::Text,
		:address_header				=>	HtmlGrid::Text,
		:generic_type					=>	HtmlGrid::Select,
		:complementary_type		=>	HtmlGrid::Select,
		:registration_count		=>	HtmlGrid::Value,	
		:fi_status						=>	HtmlGrid::Select,
		:pi_status						=>	HtmlGrid::Select,
	}
	TAG_METHOD = :multipart_form
	def init
		super
		error_message()
		info_message()
	end
	def address(model, session)
		address_delegate(model, :address)
	end
	def address_delegate(model, symbol)
		HtmlGrid::InputText.new(symbol,
			model.address(0), @session, self)
	end
	def city(model, session)
		address_delegate(model, :city)
	end
	def company_name(model, session)
		HtmlGrid::InputText.new('name', model, session, self)
	end
	def patinfo_stats(model, session)
		link = HtmlGrid::Link.new(:patinfo_stats, model , session, self)
		args = {
			:pointer	=>	model.pointer,
		}
		link.href = @lookandfeel.event_url(:patinfo_stats, args)
		link.set_attribute('title', @lookandfeel.lookup(:patinfo_stats))
		link
	end
	def plz(model, session)
		address_delegate(model, :plz)
	end
	def set_pass(model, session)
		button = HtmlGrid::Button.new(:set_pass, model, session, self)
		script = 'this.form.event.value="set_pass"; this.form.submit();'
		button.set_attribute('onClick', script)
		button
	end
end
class RootCompanyForm < View::Companies::UserCompanyForm
	COMPONENTS = {
		[0,0]			=>	:company_name,
		[0,1]			=>	:contact,
		[2,1]			=>	:contact_email,
		[1,2]			=>	:set_pass,
		[2,2]			=>	:regulatory_email,
		[0,4]			=>	:address,
		[0,5]			=>	:plz,
		[2,5]			=>	:city,
		[0,6]			=>	:phone,
		[2,6]			=>	:fax,
		[0,7]			=>	:url,
		[2,7]			=>	:address_email,
		[0,8]			=>	:powerlink,
		[2,8]			=>	:logo_file,
		[0,10]		=>	:business_area,
		[2,10]		=>	:ean13,
		[0,11]		=>	:cl_status,
		[2,11]		=>	:registration_count,
		[0,12]		=>	:generic_type,
		[2,12]		=>	:complementary_type,
		[1,13]		 =>	:patinfo_stats,
		[1,14]		=>	:submit,
		[1,14,0]	=>	:delete_item,
	}
	CSS_MAP = {
		[0,0,4,14]	=>	'list',
	}
	SYMBOL_MAP = {
		:nbsp									=>	HtmlGrid::Text,
		:address_header				=>	HtmlGrid::Text,
		:generic_type					=>	HtmlGrid::Select,
		:complementary_type		=>	HtmlGrid::Select,
		:registration_count		=>	HtmlGrid::Value,	
		:cl_status						=>	HtmlGrid::Select,
		:fi_status						=>	HtmlGrid::Select,
		:pi_status						=>	HtmlGrid::Select,
		:logo_file						=>	HtmlGrid::InputFile,
	}
end
class UnknownCompanyComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	:company_name,
		[0,0,0]	=>	:ean13,
		[0,1]		=>	View::Companies::UnknownCompanyInnerComposite,	
		[1,1]		=>	View::CompanyLogo,
	}
	COLSPAN_MAP = {
		[0,0]	=>	2,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
		[1,1]	=>	'logo-r',
	}
	def company_name(model, session)
		name = HtmlGrid::Value.new('name', model, session, self)
	end
	def ean13(model, session)
		if(model.ean13)
			"&nbsp;-&nbsp;"+model.ean13
		end
	end
end
class CompanyComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
		[1,1]	=>	'logo-r',
	}	
	COLSPAN_MAP = {
		[0,0]	=>	2,
		[0,2]	=>	2,
		[0,3]	=>	2,
	}
	SYMBOL_MAP = {
		:nbsp	=>	HtmlGrid::Text,
		:inactive_text => HtmlGrid::LabelText,
	}
	def inactive_registrations(model, session)
		InactiveRegistrations.new(model.inactive_registrations, session, self)
	end
end
class UserCompanyComposite < View::Companies::CompanyComposite
	COMPONENTS = {
		[0,0]	=>	:nbsp,
		[0,1]	=>	View::Companies::UserCompanyForm,
		[1,1]	=>	View::CompanyLogo,
		[0,2] =>	:inactive_text,
		[0,3]	=>	:inactive_registrations,
	}
end
class RootCompanyComposite < View::Companies::CompanyComposite
	COMPONENTS = {
		[0,0]	=>	:nbsp,
		[0,1]	=>	View::Companies::RootCompanyForm,
		[1,1]	=>	View::CompanyLogo,
		[0,2]	=>  :inactive_text,
		[0,3]	=>	:inactive_registrations,
	}
end
class UnknownCompany < View::PrivateTemplate
	CONTENT = View::Companies::UnknownCompanyComposite
	SNAPBACK_EVENT = :home_companies
end
class UserCompany < View::PrivateTemplate
	CONTENT = View::Companies::UserCompanyComposite
	SNAPBACK_EVENT = :home_companies
end
class RootCompany < View::PrivateTemplate
	CONTENT = View::Companies::RootCompanyComposite
	SNAPBACK_EVENT = :home_companies
end
		end
	end
end
