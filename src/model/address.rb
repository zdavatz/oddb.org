#!/usr/bin/env ruby
# Address -- oddb -- 20.09.2004 -- jlang@ywesee.com

module ODDB
	class Address 
		attr_accessor :lines, :fon, :fax,
			:plz, :city, :type
		
		def search_terms
			[self.lines_without_title, @fon, @fax, @plz, @city].flatten
		end
		def lines_without_title
			@lines.select { |line|
				!/(Prof(\.|ess))|(dr\.\s*med)/i.match(line)
			}
		end
		def <=>(other)
			self.lines <=> other.lines
		end
	end
end
