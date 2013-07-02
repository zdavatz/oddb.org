#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Companies::Company -- oddb.org -- 02.07.2013 -- yasaka@ywesee.com
# ODDB::View::Companies::Company -- oddb.org -- 02.11.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Companies::Company -- oddb.org -- 27.05.2003 -- mhuggler@ywesee.com

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
require 'view/admin/entities'
require 'view/address'
require 'view/descriptionform'
require 'view/form'
require 'view/pointervalue'
require 'view/resulttemplate'
require 'view/sponsorlogo'

module ODDB
	module View
		module Companies
class InactivePackages < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:ikskey,
		[1,0]	=>	:name_base,
		[2,0]	=>	:market_date,
		[3,0]	=>	:out_of_trade,
	}
	CSS_MAP = {
		[0,0,4]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'subheading'
	SORT_HEADER = false
	SORT_DEFAULT = :ikskey
	SYMBOL_MAP = {
		:ikskey	=>	View::PointerLink,
		:out_of_trade			=>	HtmlGrid::BooleanValue,
	}
	CSS_CLASS = 'composite'
end
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
    Address.new(model.address(0), @session, self) if model
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
		#[1,2]			=>	:set_pass,
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
		[3,13]	=>	:fipi_overview,
	}
	CSS_MAP = {
		[0,0,4,14]	=>	'list',
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
    :invoice_email        =>  HtmlGrid::Value,
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
  def fipi_overview(model, session=@session)
    link = HtmlGrid::Link.new(:fipi_overview, model, @session, self)
    args = unless model.ean13.to_s.strip.empty?
             {:company => model.ean13}
           else
             {:company => model.oid}
           end
    link.href = @lookandfeel._event_url(:fipi_overview, args)
    link
  end
	def fon(model, session=@session)
		address_delegate(model, :fon)
	end
	def patinfo_stats(model, session=@session)
		link = HtmlGrid::Link.new(:patinfo_stats, model , session, self)
    args = unless model.ean13.to_s.strip.empty?
             {:company => model.ean13}
           else
             {:company => model.oid}
           end
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
		:disable_invoice_fachinfo	=>	HtmlGrid::InputCheckbox,
		:disable_invoice_patinfo	=>	HtmlGrid::InputCheckbox,
		:disable_patinfo					=>	HtmlGrid::InputCheckbox,
		:generic_type							=>	HtmlGrid::Select,
		:invoice_date_fachinfo	  =>	HtmlGrid::InputDate,
		:invoice_date_index				=>	HtmlGrid::InputDate,
		:invoice_date_lookandfeel =>	HtmlGrid::InputDate,
		:invoice_date_patinfo     =>	HtmlGrid::InputDate,
    :invoice_email            =>  HtmlGrid::InputText,
		:invoice_htmlinfos				=>	HtmlGrid::InputCheckbox,
		:limit_invoice_duration  	=>	HtmlGrid::InputCheckbox,
		:force_new_ydim_debitor  	=>	HtmlGrid::InputCheckbox,
		:logo_file								=>	HtmlGrid::InputFile,
		:nbsp											=>	HtmlGrid::Text,
		:price_index							=>	HtmlGrid::InputCurrency,
		:price_index_package			=>	HtmlGrid::InputCurrency,
		:price_lookandfeel				=>	HtmlGrid::InputCurrency,
		:price_lookandfeel_member	=>	HtmlGrid::InputCurrency,
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
		[2,1]	  =>	:invoice_email,
		[0,2]	  =>	:ydim_id,
		[2,2]	  =>	:force_new_ydim_debitor,
		[0,3]		=>	:contact,
		[2,3]		=>	:regulatory_email,
		[0,4]		=>	:swissmedic_salutation,
		[2,4]		=>	:swissmedic_email,
		[0,5]		=>	:limit_invoice_duration,
		[2,5]		=>	:competition_email,
		[0,6]		=>	:disable_patinfo,
		[2,6]		=>	:invoice_date_patinfo,
		[0,7]		=>	:disable_invoice_patinfo,
		[2,7]		=>	:price_patinfo,
		[0,8]		=>	:invoice_htmlinfos,
		[2,8]		=>	:invoice_date_fachinfo,
		[0,9]		=>	:disable_invoice_fachinfo,
		[2,9]	  =>	:price_fachinfo,
		[2,10]	=>	:invoice_date_index,
		[0,11]	=>	:price_index,
		[2,11]	=>	:price_index_package,
		[0,12]	=>	:address,
		[0,13]	=>	:plz,
		[2,13]	=>	:city,
		[0,14]	=>	:fon,
		[2,14]	=>	:fax,
		[0,15]	=>	:url,
		[2,15]	=>	:address_email,
		[0,16]	=>	:powerlink,
		[2,16]	=>	:logo_file,
		[2,18]	=>	:ean13,
		[0,19]	=>	:cl_status,
		[2,19]	=>	:registration_count,
		[0,20]	=>	:generic_type,
		[2,20]	=>	:complementary_type,
		[1,21]	=>	:patinfo_stats,
		[1,22]	=>	:fipi_overview,
		[1,23,0]=>	:submit,
		[1,23,1]=>	:delete_item,
	}
	CSS_MAP = {
		[0,0,4,24]	=>	'list',
	}
	COMPONENT_CSS_MAP = {
		[1,0,3,5]	=>	'standard',
		[3,5,1,6]	=>	'standard',
		[1,10,3,10]	=>	'standard',
	}
end
class AjaxInfoCompanyForm < AjaxCompanyForm
	COMPONENTS = {
		[0,0]		 =>	:business_area,
		[0,1]		 =>	:company_name,
		[2,1]		 =>	:invoice_email,
		[0,2]		 =>	:contact,
		[2,2]		 =>	:contact_email,
		[0,4]		 =>	:price_lookandfeel,
		[2,4]		 =>	:invoice_date_lookandfeel,
		[0,6]		 =>	:address,
		[0,7]		 =>	:plz,
		[2,7]		 =>	:city,
		[0,8]		 =>	:fon,
		[2,8]		 =>	:fax,
		[0,9]	   =>	:url,
		[2,9]	   =>	:address_email,
		[0,10]	 =>	:ean13,
		[2,10]	 =>	:logo_file,
		[0,11]	 =>	:cl_status,
		[1,12,0] =>	:submit,
		[1,12,1] =>	:delete_item,
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
		#[1,3]		=>	:set_pass,
		[0,4]		=>	:price_lookandfeel,
		[2,4]		=>	:invoice_date_lookandfeel,
		[0,5]		=>	:price_lookandfeel_member,
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
		[1,13,0]=>	:submit,
		[1,13,1]=>	:delete_item,
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
		#[1,2]		=>	:set_pass,
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
		[1,10,0]=>	:submit,
		[1,10,1]=>	:delete_item,
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
		[2,0]		=>	:fipi_overview,
		[0,1]		=>	:address,
		[0,2]		=>	:plz,
		[0,3]		=>	:city,
		[0,4]		=>	:fon,
		[0,5]		=>	:invoice_email,
		[0,6]		=>	:url,
		[0,7]		=>	:powerlink,
		[0,8]		=>	:deductible_display,
		[1,9]		=>	:submit,
	}
	CSS_MAP = {
		[0,0,4,10]	=>	'list',
	}
	COMPONENT_CSS_MAP = {
		[1,0,3,8]	=>	'standard',
	}
	LOOKANDFEEL_MAP = {
		#:invoice_email	=>	:address_email,
	}
	SYMBOL_MAP = {
		:address_header     =>	HtmlGrid::LabelText,
		:deductible_display =>	HtmlGrid::InputCheckbox,
		:url						    =>	HtmlGrid::HttpLink,
    :invoice_email      =>  HtmlGrid::Value,
	}
end
class UnknownCompanyComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0,0]	=>	:company_name,
		[0,0,1]	=>	:ean13,
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
  LEGACY_INTERFACE = false
	def company_name(model, session=@session)
		name = HtmlGrid::Value.new('name', model, session, self)
	end
	def ean13(model, session=@session)
		if(model and model.ean13)
			"&nbsp;-&nbsp;"+model.ean13
		end
	end
end
class CompanyComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	SYMBOL_MAP = {
		:nbsp	=>	HtmlGrid::Text,
		:inactive_text => HtmlGrid::LabelText,
		:inactive_packages_label => HtmlGrid::LabelText,
		:users         => HtmlGrid::LabelText,
	}
  LEGACY_INTERFACE = false
  def inactive_packages(model, session=@session)
    InactivePackages.new(model.inactive_packages, @session, self)
  end
	def inactive_registrations(model, session=@session)
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
		[0,4]	=>	:inactive_packages_label,
		[0,5]	=>	:inactive_packages,
	}
	COLSPAN_MAP = {
		[0,0]	=>	2,
		[0,3]	=>	2,
		[0,5]	=>	2,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[1,1]	=>	'logo right',
    [0,2,2]   =>  'list',
    [0,4,2]   =>  'list',
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
  def company_users(model, session=@session)
    begin
      users = @session.user.entities.select { |entity|
        entity.get_preference('association', YUS_DOMAIN) == model.odba_id
      }
	    model = View::Admin::Entities.wrap_all(users)
    rescue Yus::NotPrivilegedError
      model = []
    end
    View::Admin::InnerEntityList.new(model, @session, self)
  end
end
class RootPharmaCompanyComposite < AjaxCompanyComposite
	COLSPAN_MAP = {
		[0,0]	=>	2,
		[0,3]	=>	2,
		[0,5]	=>	2,
		[0,7]	=>	2,
	}
	COMPONENTS = {
		[0,0]	=>	:nbsp,
		[0,1]	=>	:company_form,
		[1,1]	=>	View::CompanyLogo,
    [0,2] =>  :users,
    [0,3] =>  :company_users,
		[0,4]	=>  :inactive_text,
		[0,5]	=>	:inactive_registrations,
		[0,6]	=>	:inactive_packages_label,
		[0,7]	=>	:inactive_packages,
	}
	CSS_MAP = {
		[0,0]	    =>	'th',
		[1,1]	    =>	'logo-r',
    [0,2,2]   =>  'list',
    [0,4,2]   =>  'list',
    [0,6,2]   =>  'list',
	}	
end
class RootOtherCompanyComposite < AjaxCompanyComposite
	COMPONENTS = {
		[0,0]	=>	:nbsp,
		[0,1]	=>	:company_form,
		[1,1]	=>	View::CompanyLogo,
    [0,2] =>  :users,
    [0,3] =>  :company_users,
	}
	COLSPAN_MAP = {
		[0,0]	=>	2,
		[0,3]	=>	2,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[1,1]	=>	'logo right',
    [0,2,2]   =>  'list',
	}	
end
class PowerLinkCompanyComposite < View::Companies::CompanyComposite
	COMPONENTS = {
		[0,0]	=>	:nbsp,
		[0,1]	=>	View::Companies::PowerLinkCompanyForm,
		[1,1]	=>	View::CompanyLogo,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[1,1]	=>	'logo right',
	}	
	COLSPAN_MAP = {
		[0,0]	=>	2,
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
		['company'].each { |name|
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
