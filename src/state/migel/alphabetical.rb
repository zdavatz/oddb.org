#!/usr/bin/env ruby
# State::Migel::Alphabetical -- oddb -- 02.02.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/migel/alphabetical'

module ODDB
	module State
		module Migel
class Alphabetical < Global
	include IndexedInterval
	VIEW = View::Migel::Alphabetical
	DIRECT_EVENT = :migel_alphabetical
	PERSISTENT_RANGE = true
	LIMITED = true
	def index_lookup(range)
		@session.migel_alphabetical(range)
	end
  def intervals
		@intervals or begin
			if(@session.language == 'en')
				lang = 'de'
			else
				lang = @session.language
			end
			values = ODBA.cache.index_keys("migel_index_#{lang}", 1).compact
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
