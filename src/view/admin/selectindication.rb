#!/usr/bin/env ruby
# View::Admin::SelectIndication -- oddb -- 23.11.2004 -- hwyss@ywesee.com

require 'view/privatetemplate'
require 'view/admin/selectsubstance'

module ODDB
	module View
		module Admin
class SelectIndicationForm < HtmlGrid::Form
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]			=>	:selection_list,
		[0,1]			=>	:pointer,
		[0,1,0]		=>	:user_input,
		[0,1,0,0]	=>	:user_input_hint,
		[0,2]			=>	:submit,
	}
	LABELS = false
	SYMBOL_MAP = {
		:user_input_hint =>	 HtmlGrid::Text,
	}
	EVENT = :update
	def init
		if(@model.selection.empty?)
			@components = {
				[0,0]			=>	:pointer,
				[0,0,0]		=>	:user_input,
				[0,0,0,0]	=>	:user_input_hint,
				[0,1]			=>	:submit,
			}
		end
		super
	end
	def pointer(model, session)
		HtmlGrid::InputRadio.new(:pointer, model.new_indication, session, self)
	end
	def	selection_list(model, session)
		SelectionList.new(model.selection, session, self)
	end
	def user_input(model, session)
		model.user_input[:indication]
	end
end		
class SelectIndicationComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:registration_name,
		[0,1]	=>	"select_indication_list",
		[0,2]	=>	View::Admin::SelectIndicationForm,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,1]	=>	'subheading',
	}
	def registration_name(model, session)
		reg = model.registration
		[
			reg.name_base, 
			@lookandfeel.lookup(:select_indication)
		].compact.join('&nbsp;-&nbsp;')	
	end
end	
class SelectIndication < View::PrivateTemplate
	CONTENT = View::Admin::SelectIndicationComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
