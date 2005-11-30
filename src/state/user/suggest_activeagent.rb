#!/usr/bin/env ruby
# State::User::SuggestActiveAgent -- oddb -- 29.11.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/admin/activeagent'
require 'state/user/selectsubstance'
require 'view/admin/incompleteactiveagent'

module ODDB
	module State
		module User
class SuggestActiveAgent < Global
	include State::Admin::ActiveAgentMethods
	VIEW = View::Admin::IncompleteActiveAgent
	SELECT_STATE = State::User::SelectSubstance
end
		end
	end
end
