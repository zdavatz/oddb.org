#!/usr/bin/env ruby
# View::Drugs::IncompleteActiveAgent -- oddb -- 23.06.2003 -- hwyss@ywesee.com 

require 'view/drugs/activeagent'

module ODDB
	module View
		module Drugs
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
class IncompleteActiveAgentComposite < View::Drugs::ActiveAgentComposite
	COMPONENTS = {
		[0,0]	=>	:agent_name,
		[0,1]	=>	View::Drugs::ActiveAgentForm,
		[0,2]	=>	View::Drugs::IncompleteActiveAgentInnerComposite,
	}
	def source(model, session)
		HtmlGrid::Value.new(:source, model.parent(session.app), session, self)	
	end
end
class IncompleteActiveAgent < View::PrivateTemplate
	SNAPBACK_EVENT = :incomplete_registrations
	CONTENT = View::Drugs::IncompleteActiveAgentComposite
end
		end
	end
end
