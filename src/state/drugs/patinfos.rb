#!/usr/bin/env ruby
# State::Drugs::Patinfos -- oddb -- 21.11.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/drugs/patinfos'
require 'util/interval'

module ODDB
	module State
		module Drugs
class Patinfos < Global
	include IndexedInterval
	VIEW = View::Drugs::Patinfos
	LIMITED = true
	DIRECT_EVENT = :patinfos
	PERSISTENT_RANGE = true
	def index_lookup(range)
		@session.search_sequences(range, false).select { |seq|
			seq.has_patinfo?
		}
	end
end
		end
	end
end
