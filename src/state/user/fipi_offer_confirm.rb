#!/usr/bin/env ruby
# State::User::FiPiOfferConfirm -- oddb -- 29.06.2004 -- mhuggler@ywesee.com

require 'state/user/global'
require 'view/user/fipi_offer_confirm'

module ODDB
	module State
		module User
class FiPiOfferConfirm < State::User::Global
	VIEW = View::User::FiPiOfferConfirm
end
		end
	end
end
