#!/usr/bin/env ruby
# View::Admin::SelectSubstance -- oddb -- 28.04.2003 -- benfay@ywesee.com

require 'view/drugs/privatetemplate'
require 'view/privatetemplate'
require 'view/form'
require 'htmlgrid/list'
require 'htmlgrid/inputradio'

module ODDB
	module View
		module Admin
class SelectionList < HtmlGrid::List
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0,0]	=>	:pointer,
		[0,0,1]	=>	:name,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'subheading'
	EMPTY_LIST = true
	OMIT_HEADER = true
	SYMBOL_MAP = {
		:pointer =>	HtmlGrid::InputRadio
	}
end
class SelectSubstanceForm < HtmlGrid::Form
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]			=>	:selection_list,
		[0,1,0]		=>	:pointer,
		[0,1,1]		=>	:user_input,
		[0,1,2] 	=>	:user_input_hint,
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
				[0,0,0]		=>	:pointer,
				[0,0,1]		=>	:user_input,
				[0,0,2]	  =>	:user_input_hint,
				[0,1]			=>	:submit,
			}
		end
		super
	end
	def pointer(model, session)
		HtmlGrid::InputRadio.new(:pointer, model.new_substance, session, self)
	end
	def	selection_list(model, session)
		SelectionList.new(model.selection, session, self)
	end
	def user_input(model, session)
		model.user_input[:substance]
	end
end		
class AssignedList < HtmlGrid::List
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=>	:name,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'subheading'
	EMPTY_LIST = true 
	OMIT_HEADER = true
end
class SelectSubstanceComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:agent_name,
		[0,1]	=>	:select_substance_list,
		[0,2]	=>	View::Admin::SelectSubstanceForm,
		[0,3]	=>	:assigned_substances,
		[0,4]	=>	:assigned_list,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,1]	=>	'subheading',
		[0,3]	=>	'subheading',
	}
	SYMBOL_MAP = {
		:assigned_substances =>	 HtmlGrid::Text,
		:select_substance_list	=>	HtmlGrid::Text,
	}
	def init
		if(@model.selection.empty?)
			@components = {
				[0,0]	=>	:agent_name,
				[0,1]	=>	:select_substance_list_user,
				[0,2]	=>	View::Admin::SelectSubstanceForm,
				[0,3]	=>	:assigned_substances,
				[0,4]	=>	:assigned_list,
			}
			@symbol_map = {
				:assigned_substances =>	 HtmlGrid::Text,
				:select_substance_list_user	=>	HtmlGrid::Text,
			}
		end
		super
	end
	def agent_name(model, session)
		sequence = model.active_agent.sequence
		[sequence.name, @lookandfeel.lookup(:select_substance)].compact.join('&nbsp;-&nbsp;')	
	end
	def assigned_list(model, session)
		View::Admin::AssignedList.new(model.assigned, session, self)	
	end
end	
class SelectSubstance < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::SelectSubstanceComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
