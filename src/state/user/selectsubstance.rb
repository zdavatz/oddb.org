#!/usr/bin/env ruby
# encoding: utf-8
# State::User::SelectSubstance -- oddb -- 30.11.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/admin/selectsubstance'

module ODDB
	module State
		module User
class SelectSubstance < Global
	VIEW = View::Admin::SelectSubstance
	include State::Admin::SelectSubstanceMethods
end
		end
	end
end
