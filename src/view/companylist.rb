#!/usr/bin/env ruby
# CompanyListView -- oddb -- 26.05.2003 -- maege@ywesee.com

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
			link = PointerLink.new(:name, model, session, self)
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
	class UnknownCompanyList < HtmlGrid::List
		include CompanyList	
		def init
			@model = @model.select{ |company|
				company.listed?
			}
			super
		end
	end
	class CompanyUserList < HtmlGrid::List
		include CompanyList	
		def init
			@model = @model.select{ |company|
				company.listed? || (company == @session.user.model)
			}
			super
		end
	end
	class RootCompanyList < FormList
		include CompanyList	
		EVENT = :new_company
		include AlphaHeader
	end
	class UnknownCompanyListView < PublicTemplate
		CONTENT = UnknownCompanyList
	end
	class CompanyUserListView < PublicTemplate
		CONTENT = CompanyUserList
	end
	class RootCompanyListView < PublicTemplate
		CONTENT = RootCompanyList
	end
end
