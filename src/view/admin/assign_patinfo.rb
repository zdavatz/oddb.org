#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::AssignPatinfo -- oddb.org -- 06.01.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Admin::AssignPatinfo -- oddb.org -- 19.10.2005 -- hwyss@ywesee.com

require 'view/drugs/privatetemplate'
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
		if(model == seq || !@session.allowed?('edit', model))
			# nothing
		elsif([model.pdf_patinfo, model.patinfo].include?(test))
			@lookandfeel.lookup(:assign_patinfo_equal)			
		else
			check = HtmlGrid::InputCheckbox.new("pointer_list[#{@list_index}]", 
																					model, session, self)
																					check.value = model.pointer
																					check
		end
	end
	def compose_footer(matrix)
		super
		btn = HtmlGrid::Button.new(:back, @model, @session, self)
		args = [:reg, @model.sequence.iksnr, :seq, @model.sequence.seqnr]
		url = @lookandfeel._event_url(:drug, args)
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
class AssignPatinfo < View::Drugs::PrivateTemplate
	SNAPBACK_EVENT = :result
	CONTENT = AssignPatinfoComposite
end
		end
	end
end
