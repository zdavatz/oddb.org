#!/usr/bin/env ruby
# Doctor -- oddb -- 20.09.2004 -- jlang@ywesee.com

require 'util/persistence'
require 'model/address'

module ODDB
	class Doctor
		include Persistence
		ODBA_SERIALIZABLE = [
			'@addresses', '@specialities', '@abilities', '@skills', '@ean13',
		]
		attr_accessor :gender, :title, :name, :firstname,
			:email, :exam, :language, :specialities, :abilities,
			:skills, :praxis, :member, :salutation,
			:origin_db, :origin_id, :addresses, :ean13
			
		def initialize
			@addresses = []
			super
		end
		def init(app = nil)
			super
			@pointer.append(@oid)
		end
		def address(pos)
			@addresses[pos.to_i]
		end
=begin
		def create_address
			addr = Address.new
			@addresses[addr.oid] = addr
		end
=end
		def pointer_descr
			[@title, @firstname, @name].compact.join(' ')
		end
		def praxis_address
			@addresses.each { |addr| 
				if(addr.type == :praxis)
					return addr
				end
		  }
			nil
		end
		def praxis_addresses	
			@addresses.select { |addr| 
				addr.type == :praxis
		  }
		end
		def record_match?(origin_db, origin_id)
			@origin_db == origin_db && @origin_id == origin_id
		end
		def search_terms
			([
				@name, @firstname,  
				@email,
				@specialities,
				@ean13,
			] + @addresses.collect { |addr| addr.search_terms }).flatten.compact
		end
		def search_text
			search_terms.join(' ')
		end
		def work_addresses	
			@addresses.select { |addr| 
				addr.type == :work
		  }
		end
	end
end
