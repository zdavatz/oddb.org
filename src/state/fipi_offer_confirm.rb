#!/usr/bin/env ruby
# FiPiOfferConfirmState -- oddb -- 29.06.2004 -- maege@ywesee.com

require 'state/global_predefine'
require 'view/fipi_offer_confirm'

module ODDB
	class FiPiOfferConfirmState < GlobalState
		VIEW = FiPiOfferConfirmView
	end
end
