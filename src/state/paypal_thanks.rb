#!/usr/bin/env ruby
# PayPalThanksState -- oddb -- 10.09.2003 -- maege@ywesee.com

require 'state/global_predefine'
require 'view/paypal_thanks'

module ODDB
	class PayPalThanksState < GlobalState
		VIEW = PayPalThanksView
	end
end
