#!/usr/bin/env ruby
# State::Admin::IncompleteActiveAgent -- oddb -- 22.06.2003 -- hwyss@ywesee.com 

require 'state/admin/activeagent'
require 'view/admin/incompleteactiveagent'

module ODDB 
	module State
		module Admin
class IncompleteActiveAgent < State::Admin::ActiveAgent
	VIEW = View::Admin::IncompleteActiveAgent
end
		end
	end
end
