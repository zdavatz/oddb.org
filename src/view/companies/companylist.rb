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
class UnknownCompanyListList < HtmlGrid::List
	include View::Companies::CompanyList	
	def init
		@model = @model.select{ |company|
			company.listed?
		}
		super
	end
end
class CompanyUserListList < HtmlGrid::List
	include View::Companies::CompanyList	
	def init
		@model = @model.select{ |company|
			company.listed? || (company == @session.user.model)
		}
		super
	end
end
class RootCompanyListList < View::FormList
	include View::Companies::CompanyList	
	EVENT = :new_company
	include View::AlphaHeader
end
class UnknownCompanyList < View::PublicTemplate
	CONTENT = View::Companies::UnknownCompanyListList
end
class CompanyUserList < View::PublicTemplate
	CONTENT = View::Companies::CompanyUserListList
end
class RootCompanyList < View::PublicTemplate
	CONTENT = View::Companies::RootCompanyListList
end
		end
	end
end
