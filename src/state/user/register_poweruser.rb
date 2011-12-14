#!/usr/bin/env ruby
# encoding: utf-8
# State::User::RegisterPowerUser -- oddb -- 29.07.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/paypal/checkout'
require 'view/user/register_poweruser'

module ODDB
	module State
		module User
class RenewPowerUser < Global
	include State::PayPal::Checkout
	VIEW = View::User::RenewPowerUser
end
class RegisterPowerUser < Global
	include State::PayPal::Checkout
	VIEW = View::User::RegisterPowerUser
end
		end
	end
end
