#!/usr/bin/env ruby
# encoding: utf-8
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
			:addresses, :email, :ydim_id
		attr_reader :ean13
		alias :fullname :name
    alias :contact_email :email
		def initialize(ean13)
			@addresses = [Address2.new]
			@ean13 = ean13
		end
		def contact
			(addr = @addresses.first) && addr.name
		end
		def search_terms
			terms = [
				@name, @ean13, @business_unit, @email
			]
			@addresses.each { |addr| 
				terms += addr.search_terms
			}
			ODDB.search_terms(terms)
		end
		def search_text
			search_terms.join(' ')
		end
		def pointer_descr
			[@name, @business_unit].compact.join(' ')
		end
	end
end
