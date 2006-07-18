#!/usr/bin/env ruby
# State::Analysis::Global -- oddb.org -- 13.06.2006 -- sfrischknecht@ywesee.com

require 'state/analysis/init'
require 'state/analysis/limit'

module ODDB
	module State
		module Analysis
class Global < State::Global
	HOME_STATE = State::Analysis::Init
	ZONE = :analysis
	ZONE_NAVIGATION = [:analysis_alphabetical]
	def limit_state
		State::Analysis::Limit.new(@session, nil)
	end
end
		end
	end
end
