#!/usr/bin/env ruby
# ODBAStub -- ODDB -- 16.09.2004 -- hwyss@ywesee.com

require 'odba'

module ODBA
	class CacheStub
		def store(anything)
		end
	end
	class StorageStub
	end
	def batch(&block)
		block.call
	end
	alias :transaction :batch
	def cache_server
		@cache_server ||= CacheStub.new
	end
	def storage
		@storage ||= StorageStub.new
	end
	module_function :batch
	module_function :cache_server
	module_function :transaction
	module_function :storage
end
