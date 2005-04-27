#!/usr/bin/env ruby
# State::User::PayPalRedirect -- ODDB -- 20.04.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/user/paypal_redirect'

module ODDB
	module State
		module User
class PayPalRedirect < Global
	VIEW = View::User::PayPalRedirect
	VOLATILE = true
end
		end
	end
end
