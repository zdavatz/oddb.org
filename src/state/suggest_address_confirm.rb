#!/usr/bin/env ruby
# SuggestAddressConfirm -- oddb -- 08.08.2005 -- jlang@ywesee.com


require 'state/drugs/global'
require 'view/suggest_address_confirm'

module ODDB
	module State
class AddressConfirm < State::Drugs::Global
	VIEW = View::AddressConfirm
end
	end
end
