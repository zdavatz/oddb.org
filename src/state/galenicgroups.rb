#!/usr/bin/env ruby
#GalenicGroupsState -- oddb -- 25.03.2003 -- andy@jetnet.ch

require 'state/global_predefine'
require 'state/galenicgroup'
require 'view/galenicgroups'

module ODDB
	class GalenicGroupsState < GlobalState
		DIRECT_EVENT = :galenic_groups
		VIEW = GalenicGroupsView
	end
end
