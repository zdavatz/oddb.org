#!/usr/bin/env ruby
# View::Admin::AssignPatinfo -- oddb -- 19.10.2005 -- hwyss@ywesee.com

require 'view/privatetemplate'
require 'view/admin/assign_deprived_sequence'
require 'htmlgrid/errormessage'

module ODDB
	module View
		module Admin
class AssignPatinfoForm < View::Admin::AssignDeprivedSequenceForm
	EVENT = :assign
	def patinfo_pointer(model, session)
		seq = @model.sequence
		test = seq.pdf_patinfo || seq.patinfo
		if(model == seq || !@session.user.allowed?(model))
			# nothing
		elsif([model.pdf_patinfo, model.patinfo].include?(test))
			@lookandfeel.lookup(:assign_patinfo_equal)			
		else
			check = HtmlGrid::InputCheckbox.new("pointers[]", 
				model, session, self)
			check.value = model.pointer
			check
		end
	end
	def compose_footer(matrix)
		super
		btn = HtmlGrid::Button.new(:back, @model, @session, self)
		args = {:pointer, @model.sequence.pointer}
		url = @lookandfeel._event_url(:resolve, args)
		script = "location.href='#{url}'"
		btn.set_attribute('onClick', script)
		@grid.add(btn, *matrix)
	end
end
class AssignPatinfoComposite < HtmlGrid::Composite
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0] => :name,
		[0,1] => View::Admin::SearchField,
		[0,2] => View::Admin::AssignPatinfoForm,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0] => 'th',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	def init
		super
		error_message(1)
	end
	def name(model)
		@lookandfeel.lookup(:assign_patinfo_explain, model.name_base)
	end
end
class AssignPatinfo < PrivateTemplate
	SNAPBACK_EVENT = :result
	CONTENT = AssignPatinfoComposite
end
		end
	end
end
