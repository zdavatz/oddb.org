#!/usr/bin/env ruby
# State::Drugs::Sequences -- oddb -- 08.02.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/page_facade'
require 'util/interval'
require 'view/drugs/sequences'

module ODDB
	module State
		module Drugs
class Sequences < State::Drugs::Global
	include IndexedInterval
	include OffsetPaging
	VIEW = View::Drugs::Sequences
	DIRECT_EVENT = :sequences
	LIMITED = true
	def index_lookup(range)
		@session.search_sequences(range, false).select { |seq|
		  seq.has_public_packages? 
    }
	end
	def sequences
		if(@range == user_range)
			self
		else
			Sequences.new(@session, [])
		end
	end
end
		end
	end
end
