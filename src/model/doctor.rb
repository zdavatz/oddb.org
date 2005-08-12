#!/usr/bin/env ruby
# Doctor -- oddb -- 20.09.2004 -- jlang@ywesee.com

require 'util/persistence'
require 'model/address'

module ODDB
	class Doctor
		include Persistence
		include AddressObserver
		ODBA_SERIALIZABLE = [
			'@addresses', '@specialities', '@ean13',
		]
		attr_accessor :gender, :title, :name, :firstname,
			:email, :exam, :language, :specialities, 
			:praxis, :member, :salutation,
			:origin_db, :origin_id, :addresses, :ean13
			
		def initialize
			@addresses = []
			super
		end
		def init(app = nil)
			super
			@pointer.append(@oid)
		end
		def refactor_address(addr, idx)
			new_addr = Address2.new
			lines = addr.lines_without_title
			new_addr.title = (addr.lines - lines).first
			new_addr.name = lines.at(0)
			new_addr.additional_lines = lines[1..-3]
			new_addr.address = lines.at(-2)
			new_addr.location = lines.at(-1)
			if(type = addr.type)
				new_addr.type = "at_#{type}"
			end
			new_addr.fon = addr.fon
			new_addr.fax = addr.fax
			new_addr.pointer = @pointer + [:address, idx]
			new_addr
		end
		def refactor_addresses
			addrs = []
			@addresses.each_with_index { |addr, idx|
				addrs.push(refactor_address(addr, idx))
			}
			@addresses = addrs
		end
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
