#!/usr/bin/env ruby
# Hospitals -- oddb -- 15.02.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'util/persistence'
require 'model/address'
require 'model/user'

module ODDB
	class Hospital
		include Persistence
		include AddressObserver
		include UserObserver
		ODBA_SERIALIZABLE = ['@addresses']
		attr_accessor :name, :business_unit, :narcotics,
			:addresses, :email, :invoice_email, :ydim_id
		attr_reader :ean13
		alias :fullname :name
		def initialize(ean13)
			@addresses = [Address2.new]
			@ean13 = ean13
		end
		def contact
			(addr = @addresses.first) && addr.name
		end
		def refactor_addresses
			addr = Address2.new
			addr.location = [@plz, @location].join(" ")
			addr.canton = @canton
			addr.address = @address
			addr.additional_lines = [@business_unit]
			addr.fon = [ @phone ].compact
			addr.fax = [ @fax ].compact
			@plz = @location = @canton = @street = @number =
				@phone = @fax = nil
			addr.pointer = @pointer + [:address, 0]
			@addresses = [ addr ]
		end
		def search_terms
			terms = [
				@name, @ean13, @business_unit, @email
			]
			@addresses.each { |addr| 
				terms += addr.search_terms
			}
			terms.compact
		end
		def search_text
			search_terms.join(' ')
		end
		def pointer_descr
			[@name, @business_unit].compact.join(' ')
		end
	end
end
