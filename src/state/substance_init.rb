#!/usr/bin/env ruby
# SubstanceInitState -- oddb -- 23.08.2004 -- maege@ywesee.com

require 'state/init'
require 'view/substance_search'

module ODDB
	class SubstanceInitState < InitState
		DIRECT_EVENT = :substance_home
		VIEW = SubstanceSearchView
	end
end
