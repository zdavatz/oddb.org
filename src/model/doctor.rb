#!/usr/bin/env ruby
# Doctor -- oddb -- 20.09.2004 -- jlang@ywesee.com

require 'util/persistence'
require 'model/address'

module ODDB
	class Doctor
		include Persistence
		attr_accessor :gender, :title, :name, :firstname,
			:email, :exam, :language, :specialist, :abilities,
			:skills, :praxis, :member, :salutation,
			:origin_db, :origin_id
			
		def initialize
			@addresses = Hash.new
			super
		end
		def init(app = nil)
			super
			@pointer.append(@oid)
		end
		def address(addr)
			@addresses[addr]
		end
		def create_address(addr)
			@addresses[addr] = Address.new
		end
		def record_match?(origin_db, origin_id)
			@origin_db == origin_db && @origin_id == origin_id
		end
	end
end
