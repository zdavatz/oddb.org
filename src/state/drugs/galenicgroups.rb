#!/usr/bin/env ruby
# State::Drugs::GalenicGroups -- oddb -- 25.03.2003 -- andy@jetnet.ch

require 'state/drugs/global'
require 'state/drugs/galenicgroup'
require 'view/drugs/galenicgroups'

module ODDB
	module State
		module Drugs
class GalenicGroups < State::Drugs::Global
	DIRECT_EVENT = :galenic_groups
	VIEW = View::Drugs::GalenicGroups
end
		end
	end
end
