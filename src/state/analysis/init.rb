#!/usr/bin/env ruby
# encoding: utf-8
# State::Analysis::Init -- oddb.org -- 13.06.2006 -- sfrischknecht@ywesee.com

require 'state/global_predefine'
require 'view/analysis/search'

module ODDB
	module State
		module Analysis
class Init < State::Analysis::Global
	VIEW = View::Analysis::Search
	DIRECT_EVENT = :home_analysis
end
		end
	end
end
