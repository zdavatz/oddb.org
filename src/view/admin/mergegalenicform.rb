#!/usr/bin/env ruby
# View::Admin::MergeGalenicForm -- oddb -- 04.04.2003 -- hwyss@ywesee.com 

require 'view/privatetemplate'
require 'view/form'
require 'htmlgrid/button'
require 'htmlgrid/composite'
require 'htmlgrid/errormessage'

module ODDB
	module View
		module Admin
class MergeGalenicFormForm < View::Form
	include HtmlGrid::ErrorMessage
	LABELS = false
	COMPONENTS = {
		[0,0,0] =>	:description,
		[0,0,1] =>	'merge_with',
		[1,0,2]	=>	:galenic_form,
		[1,1]		=>	:submit,
	}
	EVENT = 'merge'
	SYMBOL_MAP = {
		:galenic_form	=>	HtmlGrid::InputText
	}
	def init
		super
		error_message()
	end
	def description(model, offset)
		model.description(@lookandfeel.language)
	end
end
class MergeGalenicFormComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'galenic_form',
		[0,1]	=>	:merge_galenic_form,
		[0,2]	=>	View::Admin::MergeGalenicFormForm,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
	LABELS = true
	def merge_galenic_form(model, session)
		@lookandfeel.lookup(:merge_galenic_form, @model.sequence_count)
	end
end
class MergeGalenicForm < View::PrivateTemplate
	CONTENT = View::Admin::MergeGalenicFormComposite
	SNAPBACK_EVENT = :galenic_groups
end
		end
	end
end
