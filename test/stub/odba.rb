#!/usr/bin/env ruby
# ODBAStub -- ODDB -- 16.09.2004 -- hwyss@ywesee.com

require 'odba'

module ODBA
	class CacheStub
		attr_writer :retrieve_from_index
		def delete(anything)
		end
		def store(anything)
		end
		def retrieve_from_index(*args)
			@retrieve_from_index || []
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
		def next_id
			@id ||= 0
			@id = @id.next
		end
	end
	def batch(&block)
		block.call
	end
	alias :transaction :batch
	def cache
		@cache ||= CacheStub.new
	end
	def storage
		@storage ||= StorageStub.new
	end
	module_function :batch
	module_function :cache
	module_function :transaction
	module_function :storage
end
