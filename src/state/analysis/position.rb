#!/usr/bin/env ruby
# encoding: utf-8
# State::Analysis::Position -- oddb.org -- 23.06.2006 -- sfrischknecht@ywesee.com

require 'view/analysis/position'

module ODDB
	module State
		module Analysis
class Position < Global
	VIEW = View::Analysis::Position
	LIMITED = true
end
		end
	end
end
