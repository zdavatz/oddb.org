#!/usr/bin/env ruby
# State::User::PayPalThanks -- oddb -- 10.09.2003 -- mhuggler@ywesee.com

require 'state/user/global'
require 'view/user/paypal_thanks'

module ODDB
	module State
		module User
class PayPalThanks < State::User::Global
	VIEW = View::User::PayPalThanks
end
		end
	end
end
