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
			if(@values.odba_instance.nil?)
				@values = {}
			end
			key = method.to_s
			if(match = /^create_(.*)$/.match(key))
				@values[match[1]] ||= Config.new
				@values.odba_store
				odba_store
			elsif(match = /^(.*)=$/.match(key))
				old = @values[match[1]]
				ret = @values[match[1]] = args.first
				ret.odba_isolated_store
				@values.odba_isolated_store
				odba_store
				if(old.respond_to?(:odba_delete) && !old.eql?(ret))
					old.odba_delete
				end
				ret
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
			!%w{marshal_dump _dump marshal_load _load}.include?(mth.to_s)
		end
	end
end
