#!/usr/bin/env ruby
# State::Analysis::Alphabetical -- oddb.org -- 05.07.2006 -- sfrischknecht@ywesee.com

require 'state/global_predefine'
require 'view/analysis/alphabetical'

module ODDB
	module State
		module Analysis
class Alphabetical < Global
	include IndexedInterval
	VIEW = View::Analysis::Alphabetical
	DIRECT_EVENT = :analysis_alphabetical
	PERSISTENT_RANGE = true
	LIMITED = true
	def index_lookup(range)
		@session.analysis_alphabetical(range)
	end
	def intervals
		@intervals or begin
			values = ODBA.cache.index_keys('analysis_alphabetical_index', 1)
			@intervals, numbers = values.partition { |char| 
				/[a-z]/.match(char)
			} 
			unless(numbers.empty?)
				@intervals.push('0-9')
			end
			@intervals
		end
	end
	def comparison_value(item)
		item.send(@session.user_input(:sortvalue) || :description)
	end
end
		end
	end
end
