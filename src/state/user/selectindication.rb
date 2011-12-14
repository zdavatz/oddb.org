#!/usr/bin/env ruby
# encoding: utf-8
# State::User::SelectIndication -- oddb -- 30.11.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/admin/selectindication'
require 'state/user/selectindication'

module ODDB
	module State
		module User
class SuggestRegistration < Global; end
class SelectIndication < Global
	VIEW = View::Admin::SelectIndication
	REGISTRATION_STATE = State::User::SuggestRegistration
	include State::Admin::SelectIndicationMethods
end
		end
	end
end
