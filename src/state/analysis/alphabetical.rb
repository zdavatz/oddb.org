#!/usr/bin/env ruby
# encoding: utf-8
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
	def index_name
		if(@session.language == 'en')
			lang = 'de'
		else
			lang = @session.language
		end
		"analysis_alphabetical_index_#{lang}"
	end
end
		end
	end
end
