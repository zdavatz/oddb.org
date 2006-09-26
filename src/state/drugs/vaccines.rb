#!/usr/bin/env ruby
# State::Drugs::Vaccines -- oddb -- 06.02.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/page_facade'
require 'util/interval'
require 'view/drugs/vaccines'

module ODDB
	module State
		module Drugs
class Vaccines < State::Drugs::Global
	include IndexedInterval
	include OffsetPaging
	VIEW = View::Drugs::Vaccines
	DIRECT_EVENT = :vaccines
	LIMITED = true
	def vaccines
		if(@range == user_range)
			self
		else
			Vaccines.new(@session, [])
		end
	end
	def	index_name
		"sequence_vaccine"
	end
end
		end
	end
end
