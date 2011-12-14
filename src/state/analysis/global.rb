#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Analysis::Global -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Analysis::Global -- oddb.org -- 13.06.2006 -- sfrischknecht@ywesee.com

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
	def compare_entries(a, b)
		@sortby.each { |sortby|
			case sortby
			when :description
				sortby = [@session.language]
			when :list_title
				sortby = [sortby, @session.language]
			else
				sortby = [sortby]
			end
			aval, bval = nil
			begin
				aval = umlaut_filter(sortby.inject(a) { |memo, meth|
					memo.send(meth) })
				bval = umlaut_filter(sortby.inject(b) { |memo, meth|
					memo.send(meth) })
			rescue ::Exception => e
				puts e
				next
			end
			res = if (aval.nil? && bval.nil?)
				0
			elsif (aval.nil?)
				1
			elsif (bval.nil?)
				-1
			else 
				aval <=> bval
			end
			return res unless(res == 0)
		}
		0
	end
end
		end
	end
end
