#!/usr/bin/env ruby
# Address -- oddb -- 20.09.2004 -- jlang@ywesee.com

require 'util/persistence'

module ODDB
	class Address 
		include Persistence
		attr_accessor :street, :fon, :fax, :email, 
			:plz, :city
	end
end
