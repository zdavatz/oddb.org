#!/usr/bin/env ruby
# View::Companies::Company -- oddb -- 27.05.2003 -- mhuggler@ywesee.com

require 'htmlgrid/composite'
require	'htmlgrid/errormessage'
require	'htmlgrid/infomessage'
require 'htmlgrid/inputcheckbox'
require 'htmlgrid/inputcurrency'
require 'htmlgrid/inputdate'
require 'htmlgrid/inputfile'
require 'htmlgrid/labeltext'
require 'htmlgrid/link'
require 'htmlgrid/select'
require 'htmlgrid/text'
require 'htmlgrid/urllink'
require 'htmlgrid/value'
require 'htmlgrid/booleanvalue'
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
		[4,0]	=>	:out_of_trade,
	}
	CSS_MAP = {
		[0,0,5]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'subheading'
	EVENT = :new_sequence
	SORT_HEADER = false
	SORT_DEFAULT = :iksnr
	SYMBOL_MAP = {
		:iksnr	=>	View::PointerLink,
		:out_of_trade			=>	HtmlGrid::BooleanValue,
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
		[0,6]		=>	:nbsp,
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
end
class UserCompanyForm < View::Form
	include HtmlGrid::ErrorMessage
	include HtmlGrid::InfoMessage
	COMPONENTS = {
		[0,0]			=>	:company_name,
		[2,0]			=>	:invoice_email,
		[0,1]			=>	:contact,
		[2,1]			=>	:contact_email,
		[2,2]			=>	:regulatory_email,
		[1,2]			=>	:set_pass,
		[0,4]			=>	:address,
		[0,5]			=>	:plz,
		[2,5]			=>	:city,
		[0,6]			=>	:fon,
		[2,6]			=>	:fax,
		[0,7]			=>	:url,
		[2,7]			=>	:address_email,
		[0,9]			=>	:business_area,
		[2,9]			=>	:ean13,
		[0,10]		=>	:registration_count,
		[0,11]		=>	:generic_type,
		[2,11]		=>	:complementary_type,
		[1,12]		=>	:submit,
		[3,12]		 =>	:patinfo_stats,
	}
	CSS_MAP = {
		[0,0,4,13]	=>	'list',
	}
	COMPONENT_CSS_MAP = {
		[1,0,3,2]	=>	'standard',
		[3,2]	=>	'standard',
		[1,4,3,8]	=>	'standard',
	}
	LABELS = true
	LEGACY_INTERFACE = false
	SYMBOL_MAP = {
		:nbsp									=>	HtmlGrid::Text,
		:address_header				=>	HtmlGrid::Text,
		:business_area				=>	HtmlGrid::Select,
		:generic_type					=>	HtmlGrid::Select,
		:complementary_type		=>	HtmlGrid::Select,
		:registration_count		=>	HtmlGrid::Value,	
	}
	TAG_METHOD = :multipart_form
	def init
		super
		error_message()
		info_message()
	end
	def address(model, session=@session)
		address_delegate(model, :address)
	end
	def address_delegate(model, symbol)
		input = HtmlGrid::InputText.new(symbol,
			model.address(0), @session, self)
		if(input.value.is_a?(Array))
			input.value = input.value.join(', ')
		end
		input
	end
	def city(model, session=@session)
		address_delegate(model, :city)
	end
	def company_name(model, session=@session)
		HtmlGrid::InputText.new('name', model, session, self)
	end
	def fax(model, session=@session)
		address_delegate(model, :fax)
	end
	def fon(model, session=@session)
		address_delegate(model, :fon)
	end
	def patinfo_stats(model, session=@session)
		link = HtmlGrid::Link.new(:patinfo_stats, model , session, self)
		args = {
			:pointer	=>	model.pointer,
		}
		link.href = @lookandfeel._event_url(:patinfo_stats, args)
		link.set_attribute('title', @lookandfeel.lookup(:patinfo_stats))
		link
	end
	def plz(model, session=@session)
		address_delegate(model, :plz)
	end
	def set_pass(model, session=@session)
		button = HtmlGrid::Button.new(:set_pass, model, session, self)
		script = 'this.form.event.value="set_pass"; this.form.submit();'
		button.set_attribute('onClick', script)
		button
	end
end
class AjaxCompanyForm < UserCompanyForm
	SYMBOL_MAP = {
		:address_header						=>	HtmlGrid::Text,
		:cl_status								=>	HtmlGrid::Select,
		:complementary_type				=>	HtmlGrid::Select,
		:disable_autoinvoice			=>	HtmlGrid::InputCheckbox,
		:generic_type							=>	HtmlGrid::Select,
		:index_invoice_date				=>	HtmlGrid::InputDate,
		:index_package_price			=>	HtmlGrid::InputCurrency,
		:index_price							=>	HtmlGrid::InputCurrency,
		:invoice_htmlinfos				=>	HtmlGrid::InputCheckbox,
		:logo_file								=>	HtmlGrid::InputFile,
		:lookandfeel_invoice_date	=>	HtmlGrid::InputDate,
		:lookandfeel_member_price	=>	HtmlGrid::InputCurrency,
		:lookandfeel_price				=>	HtmlGrid::InputCurrency,
		:nbsp											=>	HtmlGrid::Text,
		:pref_invoice_date				=>	HtmlGrid::InputDate,
		:registration_count				=>	HtmlGrid::Value,	
	}
	def business_area(model, session=@session)
		select = HtmlGrid::Select.new(:business_area, model, @session, self)
		url = @lookandfeel._event_url(:ajax, {:business_area => ''})
		script = "update_company('#{url}' + this.value)"
		select.set_attribute('onChange', script)
		select
	end
end
class AjaxPharmaCompanyForm < AjaxCompanyForm
	COMPONENTS = {
		[0,0]		=>	:business_area,
		[0,1]		=>	:company_name,
		[2,1]		=>	:invoice_email,
		[0,2]		=>	:contact,
		[2,2]		=>	:contact_email,
		[1,3]		=>	:set_pass,
		[2,3]		=>	:regulatory_email,
		[2,4]		=>	:competition_email,
		[0,5]		=>	:disable_autoinvoice,
		[2,5]		=>	:pref_invoice_date,
		[0,6]		=>	:invoice_htmlinfos,
		[2,6]		=>	:patinfo_price,
		[2,7]		=>	:index_invoice_date,
		[0,8]		=>	:index_price,
		[2,8]		=>	:index_package_price,
		[0,9]		=>	:address,
		[0,10]		=>	:plz,
		[2,10]		=>	:city,
		[0,11]		=>	:fon,
		[2,11]		=>	:fax,
		[0,12]		=>	:url,
		[2,12]		=>	:address_email,
		[0,13]	=>	:powerlink,
		[2,13]	=>	:logo_file,
		[0,15]	=>	:business_area,
		[2,15]	=>	:ean13,
		[0,16]	=>	:cl_status,
		[2,16]	=>	:registration_count,
		[0,17]	=>	:generic_type,
		[2,17]	=>	:complementary_type,
		[1,18]	=>	:patinfo_stats,
		[1,19]	=>	:submit,
		[1,19,0]=>	:delete_item,
	}
	CSS_MAP = {
		[0,0,4,20]	=>	'list',
	}
	COMPONENT_CSS_MAP = {
		[1,0,3,3]	=>	'standard',
		[3,3,1,5]	=>	'standard',
		[1,8,3,10]	=>	'standard',
	}
end
class AjaxInfoCompanyForm < AjaxCompanyForm
	COMPONENTS = {
		[0,0]		=>	:business_area,
		[0,1]		=>	:company_name,
		[2,1]		=>	:invoice_email,
		[0,2]		=>	:contact,
		[2,2]		=>	:contact_email,
		[1,3]		=>	:set_pass,
		[0,4]		=>	:lookandfeel_price,
		[2,4]		=>	:lookandfeel_invoice_date,
		[0,6]		=>	:address,
		[0,7]		=>	:plz,
		[2,7]		=>	:city,
		[0,8]		=>	:fon,
		[2,8]		=>	:fax,
		[0,9]	=>	:url,
		[2,9]	=>	:address_email,
		[0,10]	=>	:ean13,
		[2,10]	=>	:logo_file,
		[0,11]	=>	:cl_status,
		[1,12]	=>	:submit,
		[1,12,0]=>	:delete_item,
	}
	CSS_MAP = {
		[0,0,4,13]	=>	'list',
	}
	COMPONENT_CSS_MAP = {
		[1,0,3,3]	=>	'standard',
		[1,4,3,8]	=>	'standard',
	}
end
class AjaxInsuranceCompanyForm < AjaxCompanyForm
	COMPONENTS = {
		[0,0]		=>	:business_area,
		[0,1]		=>	:company_name,
		[2,1]		=>	:invoice_email,
		[0,2]		=>	:contact,
		[2,2]		=>	:contact_email,
		[1,3]		=>	:set_pass,
		[0,4]		=>	:lookandfeel_price,
		[2,4]		=>	:lookandfeel_invoice_date,
		[0,5]		=>	:lookandfeel_member_price,
		[2,5]		=>	:lookandfeel_member_count,
		[0,7]		=>	:address,
		[0,8]		=>	:plz,
		[2,8]		=>	:city,
		[0,9]		=>	:fon,
		[2,9]		=>	:fax,
		[0,10]	=>	:url,
		[2,10]	=>	:address_email,
		[0,11]	=>	:ean13,
		[2,11]	=>	:logo_file,
		[0,12]	=>	:cl_status,
		[1,13]	=>	:submit,
		[1,13,0]=>	:delete_item,
	}
	CSS_MAP = {
		[0,0,4,14]	=>	'list',
	}
	COMPONENT_CSS_MAP = {
		[1,0,3,3]	=>	'standard',
		[1,4,3,9]	=>	'standard',
	}
end
class AjaxOtherCompanyForm < AjaxCompanyForm
	COMPONENTS = {
		[0,0]		=>	:business_area,
		[2,0]		=>	:company_name,
		[0,1]		=>	:contact,
		[2,1]		=>	:contact_email,
		[1,2]		=>	:set_pass,
		[0,3]		=>	:address,
		[0,4]		=>	:plz,
		[2,4]		=>	:city,
		[0,5]		=>	:fon,
		[2,5]		=>	:fax,
		[0,6]		=>	:url,
		[2,6]		=>	:address_email,
		[2,7]		=>	:logo_file,
		[0,8]		=>	:ean13,
		[0,9]		=>	:cl_status,
		[1,10]	=>	:submit,
		[1,10,0]=>	:delete_item,
	}
	CSS_MAP = {
		[0,0,4,11]	=>	'list',
	}
	COMPONENT_CSS_MAP = {
		[1,0,3,2]	=>	'standard',
		[1,3,3,6]	=>	'standard',
	}
end
class AjaxUnknownCompanyForm < AjaxCompanyForm
	COMPONENTS = {
		[0,0]		=>	:business_area,
	}
	CSS_MAP = {
		[0,0,2]	=>	'list',
	}
end
class PowerLinkCompanyForm < UserCompanyForm
	COMPONENTS = {
		[0,0]		=>	:contact,
		[0,1]		=>	:address,
		[0,2]		=>	:plz,
		[0,3]		=>	:city,
		[0,4]		=>	:fon,
		[0,5]		=>	:invoice_email,
		[0,6]		=>	:url,
		[0,7]		=>	:powerlink,
		[1,8]		=>	:submit,
	}
	CSS_MAP = {
		[0,0,4,9]	=>	'list',
	}
	COMPONENT_CSS_MAP = {
		[1,0,3,8]	=>	'standard',
	}
	LOOKANDFEEL_MAP = {
		#:invoice_email	=>	:address_email,
	}
	SYMBOL_MAP = {
		:address_header =>	HtmlGrid::LabelText,
		:url						=>	HtmlGrid::HttpLink,
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
		[1,1]	=>	'logo right',
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
		[1,1]	=>	'logo right',
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
class AjaxCompanyComposite < CompanyComposite
	CSS_ID = 'company-content'
	def AjaxCompanyComposite.select_company_form(company)
		case company.business_area
			#when nil 
			#AjaxUnknownCompanyForm
		when 'ba_pharma'
			AjaxPharmaCompanyForm
		when 'ba_insurance'
			AjaxInsuranceCompanyForm
		when 'ba_info'
			AjaxInfoCompanyForm
		else 
			AjaxOtherCompanyForm
		end
	end
	def company_form(model, session=@session)
		klass = AjaxCompanyComposite.select_company_form(model)
		klass.new(model, @session, self)
	end
end
class RootPharmaCompanyComposite < AjaxCompanyComposite
	COMPONENTS = {
		[0,0]	=>	:nbsp,
		[0,1]	=>	:company_form,
		[1,1]	=>	View::CompanyLogo,
		[0,2]	=>  :inactive_text,
		[0,3]	=>	:inactive_registrations,
	}
end
class RootOtherCompanyComposite < AjaxCompanyComposite
	COMPONENTS = {
		[0,0]	=>	:nbsp,
		[0,1]	=>	:company_form,
		[1,1]	=>	View::CompanyLogo,
	}
end
class PowerLinkCompanyComposite < View::Companies::CompanyComposite
	COMPONENTS = {
		[0,0]	=>	:nbsp,
		[0,1]	=>	View::Companies::PowerLinkCompanyForm,
		[1,1]	=>	View::CompanyLogo,
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
	SNAPBACK_EVENT = :home_companies
	def RootCompany.select_company_content(company)
		case company.business_area
		when 'ba_pharma'
			RootPharmaCompanyComposite
		else 
			RootOtherCompanyComposite
		end
	end
	def content(model, session=@session)
		klass = RootCompany.select_company_content(model)
		klass.new(model, @session, self)
	end
	def other_html_headers(context)
		res = super
		['dojo', 'company'].each { |name|
			properties = {
				"language"	=>	"JavaScript",
				"type"			=>	"text/javascript",
				"src"				=>	@lookandfeel.resource_global(:javascript, "#{name}.js"),
			}
			res << context.script(properties)
		}
		res
	end
end
class PowerLinkCompany < View::PrivateTemplate
	CONTENT = View::Companies::PowerLinkCompanyComposite
	SNAPBACK_EVENT = :home_companies
end
		end
	end
end
