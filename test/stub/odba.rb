#!/usr/bin/env ruby
# encoding: utf-8
# ODBAStub -- ODDB -- 09.04.2012 -- yasaka@ywesee.com
# ODBAStub -- ODDB -- 16.09.2004 -- hwyss@ywesee.com

require 'odba'
module PG
  class PG::Result
  end
end
PGresult = PG::Result

module ODBA
	class CacheStub
		attr_writer :retrieve_from_index
		def delete(anything)
		end
    def ensure_index_deferred *args
    end
    def transaction(&block)
      block.call
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
		def next_id
			ODBA.storage.next_id
		end
    def fill_index(index_name, targets)
      unless self.indices.empty?
        self.indices[index_name].fill(targets)
      else
        []
      end
    end
    def drop_index(index_name)
    end
    def indices
      @indices ||= fetch_named('__cache_server_indices__', self) {
        {}
      }
    end
	end
	class StorageStub
		def next_id
			@id ||= 0
			@id = @id.next
		end
    def reset_id
      @id = nil
    end
    def restore
    end
    def restore_collection(hash)
      hash
    end
    def restore_named(name)
      nil
    end
	end
	def ODBA.transaction
		yield
	end
	def ODBA.cache
		@cache ||= CacheStub.new
	end
	def ODBA.storage
		@storage ||= StorageStub.new
	end
	def ODBA.storage=(storage)
		@storage = storage
	end
end
