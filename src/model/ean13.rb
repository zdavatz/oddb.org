#!/usr/bin/env ruby
# Ean13 -- oddb -- 01.10.2003 -- mhuggler@ywesee.com

require 'sbsm/validator'

module ODDB
	class Ean13 < String
		def initialize(str)
			super(str.strip)
			unless(valid?)
				raise SBSM::InvalidDataError.new(:e_invalid_ean_code, :ean13, str)
			end
		end
		def Ean13.checksum(str)
			str = str.strip
			sum = 0 
			val =	str.split(//u)
			12.times { |idx|
				fct = ((idx%2)*2)+1
				sum += fct*val[idx].to_i
			}
			((10-(sum%10))%10).to_s
		end
		def Ean13.new_unchecked(str)
			self.new(str.strip.ljust(12, '0')+checksum(str))
		end
		private
		def valid?
			(length == 13) \
				&& (Ean13.checksum(self[0,12]) == self[-1,1])
		end
	end
end
