#!/usr/bin/env ruby
# State::Drugs::Sequences -- oddb -- 08.02.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'util/interval'
require 'view/drugs/sequences'

module ODDB
	module State
		module Drugs
class Sequences < State::Drugs::Global
	include IndexedInterval
	VIEW = View::Drugs::Sequences
	DIRECT_EVENT = :sequences
	PERSISTENT_RANGE = true
	LIMITED = true
	def index_lookup(range)
		sequences = @session.search_sequences(range, false) 
		sequences.delete_if { |seq| seq.public_packages.empty? }
		sequences
	end
end
		end
	end
end
