#!/usr/bin/env ruby
# State::Drugs::IncompleteActiveAgent -- oddb -- 23.06.2003 -- hwyss@ywesee.com 

require 'state/drugs/activeagent'
require 'view/drugs/incompleteactiveagent'

module ODDB 
	module State
		module Drugs
class IncompleteActiveAgent < State::Drugs::ActiveAgent
	VIEW = View::Drugs::IncompleteActiveAgent
end
		end
	end
end
