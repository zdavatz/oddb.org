#!/usr/bin/env ruby
# View::Admin::ActiveAgent -- oddb -- 22.04.2003 -- hwyss@ywesee.com 

require 'view/publictemplate'
require 'view/form'
require 'htmlgrid/errormessage'
require 'htmlgrid/value'

module ODDB
	module View
		module Admin
class ActiveAgentInnerComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	:substance,
		[2,0]		=>	:dose,
		[0,1]		=>	:chemical_substance,
		[2,1]		=>	:chemical_dose,
		[0,2]		=>	:equivalent_substance,
		[2,2]		=>	:equivalent_dose,
	}
	CSS_MAP = {
		[0,0,4,2]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value	
	LABELS = true
	def substance(model, session)
		[ model.substance.send(@lookandfeel.language), 
			model.sequence.spagyric_type, 
			model.sequence.spagyric_dose ].compact.join(' ')
	end
end
class ActiveAgentForm < View::Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]		=>	:substance,
		[2,0]		=>	:spagyric_type,
		[4,0]		=>	:spagyric_dose,
		[6,0]		=>	:dose,
		[0,1]		=>	:chemical_substance,
		[2,1]		=>	:chemical_dose,
		[0,2]		=>	:equivalent_substance,
		[2,2]		=>	:equivalent_dose,
		[1,3]		=>	:submit,
		[1,3,0]	=>	:delete_item,
		[1,4]		=>	:new_active_agent_button,
	}
	COLSPAN_MAP = {
		[3,1]	=>	3,
		[3,2]	=>	3,
	}
	COMPONENT_CSS_MAP = {
		[0,0,8,3]	=>	'standard',
		[3,0]	=>	'medium',
		[5,0]	=>	'small',
	}
	CSS_MAP = {
		[0,0,8,6]	=>	'list',
	}
	LABELS = true
	def init
		super
		error_message()
	end
	def new_active_agent_button(model, session)
		unless(@model.is_a? Persistence::CreateItem)
			post_event_button(:new_active_agent)
		end
	end
end
class ActiveAgentComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:agent_name,
		[0,1]	=>	View::Admin::ActiveAgentInnerComposite,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
	def agent_name(model, session)
		sequence = model.parent(session.app)
		[sequence.name, model.pointer_descr].compact.join('&nbsp;-&nbsp;')	
	end
end
class RootActiveAgentComposite < View::Admin::ActiveAgentComposite
	COMPONENTS = {
		[0,0]	=>	:agent_name,
		[0,1]	=>	View::Admin::ActiveAgentForm,
		[0,2]	=>	'th_source',
		[0,3]	=>	:source,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,2]	=>	'subheading',
	}
	def source(model, session)
		HtmlGrid::Value.new(:source, model.sequence, @session, self)
	end
end
class ActiveAgent < View::PrivateTemplate
	CONTENT = View::Admin::ActiveAgentComposite
	SNAPBACK_EVENT = :result
end
class RootActiveAgent < View::Admin::ActiveAgent
	CONTENT = View::Admin::RootActiveAgentComposite
end
		end
	end
end
