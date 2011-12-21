#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Doctor -- oddb.org -- 21.12.2011 -- mhatakeyama@ywesee.com
# ODDB::Doctor -- oddb.org -- 20.09.2004 -- jlang@ywesee.com

require 'util/persistence'
require 'model/address'

module ODDB
	class Doctor
		include Persistence
		include AddressObserver
		ODBA_SERIALIZABLE = [
			'@addresses', '@capabilities', '@specialities', '@ean13',
		]
		attr_accessor :capabilities, :title, :name, :firstname,
			:email, :exam, :language, :specialities, 
			:praxis, :member, :salutation,
			:origin_db, :origin_id, :addresses, :ean13,
      :dummy_id
    alias :name_first :firstname
    alias :name_first= :firstname=
    alias :correspondence :language
    alias :correspondence= :language=
			
		def initialize
			@addresses = []
			super
		end
		def init(app = nil)
			super
			@pointer.append(@oid)
		end
		def fullname
			[@firstname, @name].join(' ')
		end
		def pointer_descr
			[@title, @firstname, @name].compact.join(' ')
		end
		def praxis_address
			@addresses.find { |addr| 
				addr.type == 'at_praxis'
		  }
		end
		def praxis_addresses	
			@addresses.select { |addr| 
				addr.type == 'at_praxis'
		  }
		end
		def record_match?(origin_db, origin_id)
			@origin_db == origin_db && @origin_id == origin_id
		end
		def search_terms
			ODDB.search_terms([
				@name, @firstname,  
				@email,
				@specialities,
				@ean13,
			] + @addresses.collect { |addr| 
				addr.search_terms 
			})
		end
		def search_text
			search_terms.join(' ')
		end
		def work_addresses	
			@addresses.select { |addr| 
				addr.type == 'at_work'
		  }
		end
    private
    def adjust_types(values, app=nil)
      values.dup.each { |key, value|
        case key
        when :specialities, :capabilities
          values.store(key, value.to_s.split(/[\r\n]+/u))
        when :exam
          values.store(key, value.to_i)
        end
      }
      values
    end
	end
end
