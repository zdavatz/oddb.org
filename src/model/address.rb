#!/usr/bin/env ruby
# Address -- oddb -- 20.09.2004 -- jlang@ywesee.com

require 'util/persistence'

module ODDB
	class Address 
		attr_accessor :lines, :fon, :fax, :email, 
			:plz, :city, :type

		def <=>(other)
			self.lines <=> other.lines
		end
	end
end
