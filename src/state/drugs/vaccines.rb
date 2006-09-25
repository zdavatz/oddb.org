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
	def index_lookup(range)
		@session.search_vaccines(range)
	end
	def vaccines
		if(@range == user_range)
			self
		else
			Vaccines.new(@session, [])
		end
	end
	def intervals
		@intervals or begin
		values = ODBA.cache.index_keys('sequence_vaccine', 1)
		@intervals, numbers = values.partition { |char|
			/[a-z]/.match(char)
		}
		unless(numbers.empty?)
			@intervals.push('0-9')
		end
		@intervals
	end
	end
end
		end
	end
end
