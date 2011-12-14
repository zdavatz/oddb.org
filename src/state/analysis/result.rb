#!/usr/bin/env ruby
# encoding: utf-8
# State::Analysis::Result -- oddb.org -- 14.06.2006 -- sfrischknecht@ywesee.com

require 'state/global_predefine'
require 'view/analysis/result'

module ODDB
	module State
		module Analysis
class Result < Global
	VIEW = View::Analysis::Result
	DIRECT_EVENT = :result
	LIMITED = true
	def init
		if(model.nil? || @model.empty?)
			@default_view = View::Analysis::EmptyResult
		end
	end
end
		end
	end
end
