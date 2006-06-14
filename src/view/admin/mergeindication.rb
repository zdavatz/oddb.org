#!/usr/bin/env ruby
# View::Admin::MergeIndication -- oddb -- 07.07.2003 -- hwyss@ywesee.com 

require 'view/drugs/privatetemplate'

module ODDB
	module View
		module Admin
class MergeIndicationForm < View::Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0,0] =>	:description,
		[0,0,1] =>	'merge_with',
		[1,0,2]	=>	:indication,
		[1,1]		=>	:submit,
	}
	SYMBOL_MAP = {
		:indication =>	HtmlGrid::InputText
	}
	EVENT = 'merge'
	LABELS = false
	def init
		super
		error_message()
	end
	def description(model, offset)
		model.description(@lookandfeel.language)
	end
end
class MergeIndicationComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'indication',
		[0,1]	=>	:merge_galenic_form,
		[0,2]	=>	View::Admin::MergeIndicationForm,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
	def merge_indication(model, session)
		@lookandfeel.lookup(:merge_indication, @model.registration_count)
	end
end
class MergeIndication < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::MergeIndicationComposite
	SNAPBACK_EVENT = :indications
end
		end
	end
end
