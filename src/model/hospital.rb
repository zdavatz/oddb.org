#!/usr/bin/env ruby
# Hospitals -- oddb -- 15.02.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'util/persistence'

module ODDB
	class Hospital
		include Persistence
		ODBA_SERIALIZABLE = []
		attr_accessor :name, :business_unit, :address, :plz,
			:location, :phone, :fax, :canton
		attr_reader :ean13
		def initialize(ean13)
			@ean13 = ean13
		end
		def search_terms
			([
				@name, @business_unit,  
				@address,
				@phone,
				@ean13,
			]).flatten.compact
		end
		def search_text
			search_terms.join(' ')
		end
		def pointer_descr
			[@name, @business_unit].compact.join(' ')
		end
	end
end
