#!/usr/bin/env ruby
#YweseeContactState -- oddb -- 04.08.2003 -- maege@ywesee.com

require 'state/global_predefine'
require 'view/yweseecontact'

module ODDB
	class YweseeContactState < GlobalState
		DIRECT_EVENT = :ywesee_contact
		VIEW = YweseeContactView
	end
end
