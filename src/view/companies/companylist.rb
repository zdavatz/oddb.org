#!/usr/bin/env ruby
# View::Companies::CompanyList -- oddb -- 26.05.2003 -- maege@ywesee.com

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
		module Companies
module CompanyList
	include UmlautSort
	COMPONENTS = {
		[0,0]	=>	:name,
		[1,0]	=>	:business_area,
		[2,0]	=>	:url,
		[3,0]	=>	:contact,
	}	
	DEFAULT_CLASS = HtmlGrid::Value
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'list',
		[1,0]	=>	'list',
		[2,0]	=>	'list',
		[3,0]	=>	'list',
	}
	CSS_HEAD_MAP = {
		[0,0] =>	'th',
		[1,0] =>	'th',
		[2,0] =>	'th',
		[3,0] =>	'th',
	}
	LOOKANDFEEL_MAP = {
		:name						=>	:company_name,
		:business_area	=>	:company_business_area,
		:url						=>	:company_url,
		:contact				=>	:company_contact,
	}
	SORT_DEFAULT = :name
	SORT_REVERSE = false 
	def name(model, session)
		link = View::PointerLink.new(:name, model, session, self)
		if(model.ean13)
			link.set_attribute('title', @lookandfeel.lookup(:ean_code, model.ean13))
		end
		link
	end
	def url(model, session)
		HtmlGrid::HttpLink.new('url', model, session, self)
	end
	def contact(model, session)
		HtmlGrid::MailLink.new('contact_email', model, session, self)
	end
end
class CompaniesComposite < Form
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]		=>	:search_query,
		[0,0,1]	=>	:submit,
		[0,1]		=>	:company_list,
	}
	EVENT = :search
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,	
	}
	def company_list(model, session)
		self::class::COMPANY_LIST.new(model, session, self)
	end
end
class UnknownCompanyList < HtmlGrid::List
	include View::Companies::CompanyList	
	def init
		super
	end
end
class UnknownCompaniesComposite < CompaniesComposite
	COMPANY_LIST = UnknownCompanyList
end
class UnknownCompanies < View::ResultTemplate
	CONTENT = View::Companies::UnknownCompaniesComposite
end
class RootCompanyList < View::FormList
	include View::Companies::CompanyList	
	EVENT = :new_company
	include View::AlphaHeader
end
class RootCompaniesComposite < CompaniesComposite
	COMPANY_LIST = RootCompanyList
end
class RootCompanies < View::ResultTemplate
	CONTENT = View::Companies::RootCompaniesComposite
end
class EmptyResultForm < HtmlGrid::Form
	COMPONENTS = {
		[0,0]		=>	:search_query,
		[0,0,1]	=>	:submit,
		[0,1]		=>	:title_none_found,
		[0,2]		=>	'e_empty_result',
		[0,3]		=>	'explain_search_company',
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
	CONTENT = View::Companies::EmptyResultForm
end
		end
	end
end
