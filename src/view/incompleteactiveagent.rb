#!/usr/bin/env ruby
# IncompleteActiveAgentView -- oddb -- 23.06.2003 -- hwyss@ywesee.com 

require 'view/activeagent'

module ODDB
	class IncompleteActiveAgentInnerComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	:th_source,
			[0,1]	=>	:source,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0]	=>	"subheading",
		}
		SYMBOL_MAP = {
			:th_source	=>	HtmlGrid::Text,
		}
		def source(model, session)
			HtmlGrid::Value.new(:source, model.parent(session.app), session, self)	
		end
	end
	class IncompleteActiveAgentComposite < ActiveAgentComposite
		COMPONENTS = {
			[0,0]	=>	:agent_name,
			[0,1]	=>	ActiveAgentForm,
			[0,2]	=>	IncompleteActiveAgentInnerComposite,
		}
		def source(model, session)
			HtmlGrid::Value.new(:source, model.parent(session.app), session, self)	
		end
	end
	class IncompleteActiveAgentView < PrivateTemplate
		SNAPBACK_EVENT = :incomplete_registrations
		CONTENT = IncompleteActiveAgentComposite
	end
end
