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
				old = @values[match[1]]
				ret = @values[match[1]] = args.first
				ret.odba_isolated_store
				@values.odba_isolated_store
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
			true
		end
	end
end

