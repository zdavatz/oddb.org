#!/usr/bin/env ruby
# State::PayPal::Redirect -- ODDB -- 20.04.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/paypal/redirect'

module ODDB
	module State
		module PayPal
class Redirect < State::Global
	VIEW = View::PayPal::Redirect
	VOLATILE = true
end
		end
	end
end
