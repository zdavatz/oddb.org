#!/usr/bin/env ruby
# Array -- oddb -- 22.04.2003 -- hwyss@ywesee.com 

module ODDB
	class PointerArray < Array
		attr_accessor :pointer
		def initialize(values, pointer)
			super()
			values.each { |val|
				self << val
			}
			@pointer = pointer
		end
		def sort_by(*args, &block)
			result = super
			PointerArray.new(result, @pointer)
		end
	end
	class PointerHash < Hash
		attr_accessor :pointer
		def initialize(hash, pointer)
			super()
			update(hash)
			@pointer = pointer
		end
	end
end
