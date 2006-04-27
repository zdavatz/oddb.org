#!/usr/bin/env ruby
# View::Admin::IncompleteActiveAgent -- oddb -- 23.06.2003 -- hwyss@ywesee.com 

require 'view/drugs/privatetemplate'
require 'view/admin/activeagent'

module ODDB
	module View
		module Admin
class IncompleteActiveAgent < View::Drugs::PrivateTemplate
	SNAPBACK_EVENT = :incomplete_registrations
	CONTENT = View::Admin::RootActiveAgentComposite
end
		end
	end
end
