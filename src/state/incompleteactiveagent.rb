#!/usr/bin/env ruby
# IncompleteActiveAgentState -- oddb -- 23.06.2003 -- hwyss@ywesee.com 

require 'state/activeagent'
require 'view/incompleteactiveagent'

module ODDB 
	class IncompleteActiveAgentState < ActiveAgentState
		VIEW = IncompleteActiveAgentView
	end
end
