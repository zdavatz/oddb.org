#!/usr/bin/env ruby
# MergeIndicationView -- oddb -- 07.07.2003 -- hwyss@ywesee.com 

require 'view/privatetemplate'

module ODDB
	class MergeIndicationForm < Form
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
			[0,2]	=>	MergeIndicationForm,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	'th',
		}
		def merge_indication(model, session)
			@lookandfeel.lookup(:merge_indication, @model.registration_count)
		end
	end
	class MergeIndicationView < PrivateTemplate
		CONTENT = MergeIndicationComposite
		SNAPBACK_EVENT = :indications
	end
end
