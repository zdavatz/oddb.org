#!/usr/bin/env ruby
# MergeCompaniesView -- oddb -- 17.06.2003 -- maege@ywesee.com

require 'view/privatetemplate'
require 'view/form'
require 'htmlgrid/button'
require 'htmlgrid/inputtext'
require 'htmlgrid/composite'
require 'htmlgrid/errormessage'

module ODDB
	class MergeCompaniesForm < Form
		include HtmlGrid::ErrorMessage
		LABELS = false
		COMPONENTS = {
			[0,0,1] =>	'merge_companies_form',
			[1,0,2]	=>	:company_form,
			[1,1]		=>	:submit,
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
			[0,2]	=>	MergeCompaniesForm,
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
	class MergeCompaniesView < PrivateTemplate
		CONTENT = MergeCompaniesComposite
		SNAPBACK_EVENT = :companylist
	end
end
