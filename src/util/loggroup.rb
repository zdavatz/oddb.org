#!/usr/bin/env ruby
# LogGroup -- oddb -- 16.05.2003 -- hwyss@ywesee.com 

require 'date'
require 'util/log'
require 'util/persistence'

module ODDB
	class LogGroup
		include Persistence
		attr_reader :key, :logs
		def initialize(key)
			@key = key
			@logs = {}
		end
		def create_log(date)
			@logs[date] = Log.new(date)
		end
		def latest
			@logs[newest_date]
		end
		def log(date)
			@logs[date]
		end
		def months(year)
			@logs.keys.select { |date| 
				date.year == year 
			}.collect { |date| 
				date.month 
			}.sort
		end
		def newest_date
			@logs.keys.max
		end
		def years
			@logs.keys.collect { |date| date.year }.uniq.sort
		end
	end
end
