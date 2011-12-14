#!/usr/bin/env ruby
# encoding: utf-8
# View::Companies::MergeCompanies -- oddb -- 17.06.2003 -- mhuggler@ywesee.com

require 'view/privatetemplate'
require 'view/form'
require 'htmlgrid/button'
require 'htmlgrid/inputtext'
require 'htmlgrid/composite'
require 'htmlgrid/errormessage'

module ODDB
	module View
		module Companies
class MergeCompaniesForm < View::Form
	include HtmlGrid::ErrorMessage
	LABELS = false
	COMPONENTS = {
		[0,0] =>	'merge_companies_form',
		[1,0]	=>	:company_form,
		[1,1]	=>	:submit,
	}
	EVENT = 'merge'
	SYMBOL_MAP = {
		:company_form	=>	HtmlGrid::InputText
	}
	def init
		super
		error_message()
	end	
end
class MergeCompaniesComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'company',
		[0,1]	=>	:merge_companies,
		[0,2]	=>	View::Companies::MergeCompaniesForm,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
	LABELS = true
	def merge_companies(model, session)
		@lookandfeel.lookup(:merge_companies, @model.registration_count)
	end
end
class MergeCompanies < View::PrivateTemplate
	CONTENT = View::Companies::MergeCompaniesComposite
	SNAPBACK_EVENT = :companylist
end
		end
	end
end
