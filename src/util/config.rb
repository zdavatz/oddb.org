#!/usr/bin/env ruby
# Config -- oddb -- 14.10.2004 -- hwyss@ywesee.com, usenguel@ywesee.com

require 'util/persistence'

module ODDB
	class Config
		include Persistence
		def initialize
			@values = {}
		end
		def method_missing(method, *args)
			key = method.to_s
			if(match = /^create_(.*)$/.match(key))
				@values[match[1]] ||= Config.new
			elsif(match = /^(.*)=$/.match(key))
				@values[match[1]] = args.first
			else
				@values[key]
			end
		end
		def method(mth)
			Proc.new {
				@values[mth.to_s]
			}
		end
		def respond_to?(mth)
			true
		end
	end
end

