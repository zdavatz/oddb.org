#!/usr/bin/env ruby
# ODBAStub -- ODDB -- 16.09.2004 -- hwyss@ywesee.com

require 'odba'

module ODBA
	class CacheStub
		def delete(anything)
		end
		def store(anything)
		end
		def prefetch
		end
		def bulk_fetch(*args)
			[]
		end
		def fetch_named(*argsm, &block)
			block.call
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
