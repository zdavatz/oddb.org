#!/usr/bin/env ruby
# InteractionInitState -- oddb -- 26.05.2004 -- maege@ywesee.com

require 'state/init'
require 'view/interaction_search.rb'

module ODDB
	class InteractionInitState < InitState
		DIRECT_EVENT = :interaction_home
		VIEW = InteractionSearchView
	end
end
