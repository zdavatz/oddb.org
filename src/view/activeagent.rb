#!/usr/bin/env ruby
# ActiveAgentView -- oddb -- 22.04.2003 -- hwyss@ywesee.com 

require 'view/publictemplate'
require 'view/form'
require 'htmlgrid/errormessage'
require 'htmlgrid/value'

module ODDB
	class ActiveAgentInnerComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]		=>	:substance,
			[2,0]		=>	:dose,
		}
		CSS_MAP = {
			[0,0,4,2]	=>	'list',
		}
		DEFAULT_CLASS = HtmlGrid::Value	
		LABELS = true
	end
	class ActiveAgentForm < Form
		include HtmlGrid::ErrorMessage
		COMPONENTS = {
			[0,0]		=>	:substance,
			[2,0]		=>	:dose,
			[1,1]		=>	:submit,
			[1,1,0]	=>	:delete_item,
			[1,2]		=>	:new_activ_agent_button,
		}
		COMPONENT_CSS_MAP = {
			[0,0,4]	=>	'standard',
		}
		CSS_MAP = {
			[0,0,4,3]	=>	'list',
		}
		LABELS = true
		def init
			super
			error_message()
		end
		def new_activ_agent_button(model, session)
			unless(@model.is_a? Persistence::CreateItem)
				post_event_button(:new_active_agent)
			end
		end
	end
	class ActiveAgentComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	:agent_name,
			[0,1]	=>	ActiveAgentInnerComposite,
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
	class RootActiveAgentComposite < ActiveAgentComposite
		COMPONENTS = {
			[0,0]	=>	:agent_name,
			[0,1]	=>	ActiveAgentForm,
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
	class ActiveAgentView < PrivateTemplate
		CONTENT = ActiveAgentComposite
		SNAPBACK_EVENT = :result
	end
	class RootActiveAgentView < ActiveAgentView
		CONTENT = RootActiveAgentComposite
	end
end
