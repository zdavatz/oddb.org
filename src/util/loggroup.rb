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
		def newest_date
			@logs.keys.max
		end
	end
end
