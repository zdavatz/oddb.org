#!/usr/bin/env ruby
# View::Admin::IncompleteActiveAgent -- oddb -- 23.06.2003 -- hwyss@ywesee.com 

require 'view/drugs/privatetemplate'
require 'view/admin/activeagent'

module ODDB
	module View
		module Admin
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
class IncompleteActiveAgentComposite < View::Admin::ActiveAgentComposite
	COMPONENTS = {
		[0,0]	=>	:agent_name,
		[0,1]	=>	View::Admin::ActiveAgentForm,
		[0,2]	=>	View::Admin::IncompleteActiveAgentInnerComposite,
	}
	def source(model, session)
		HtmlGrid::Value.new(:source, model.parent(session.app), session, self)	
	end
end
class IncompleteActiveAgent < View::Drugs::PrivateTemplate
	SNAPBACK_EVENT = :incomplete_registrations
	CONTENT = View::Admin::IncompleteActiveAgentComposite
end
		end
	end
end
