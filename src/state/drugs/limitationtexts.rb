#!/usr/bin/env ruby
# State::Drugs::LimitationTexts -- oddb -- 21.11.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/drugs/limitationtexts'
require 'util/interval'

module ODDB
	module State
		module Drugs
class LimitationTexts < Global
	include IndexedInterval
	VIEW = View::Drugs::LimitationTexts
	LIMITED = true
	DIRECT_EVENT = :limitation_texts
	PERSISTENT_RANGE = true
	def index_lookup(range)
		@session.search_sequences(range, false).select { |seq|
			seq.limitation_text
		}
	end
	def intervals
		@intervals or begin
		values = ODBA.cache.index_keys('sequence_limitation_text', 1)
		@intervals, numbers = values.partition { |char|
			/[a-z]/.match(char.to_s)
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
