#!/usr/bin/env ruby
# State::User::RegisterDownload -- oddb -- 22.12.2004 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/paypal/checkout'
require 'view/user/register_download'

module ODDB
	module State
		module User
class RegisterDownload < Global
	include State::PayPal::Checkout
	VIEW = View::User::RegisterDownload
	def checkout_keys
		checkout_mandatory() + [:business_area, :company_name]
	end
	def checkout_mandatory
		super + [ :address, :plz, :location, :phone ]
	end
end
		end
	end
end
