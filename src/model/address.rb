#!/usr/bin/env ruby
# Address -- oddb -- 20.09.2004 -- jlang@ywesee.com

module ODDB
	class Address 
		attr_accessor :lines, :fon, :fax,
			:plz, :city, :type
		
		def city
			if(match =/[^0-9]+/.match(self.lines[-1]))
				 match.to_s.strip
			end
		end
		def lines
			@lines.delete_if { |line| line.strip.empty? }
		end
		def lines_without_title
			@lines.select { |line|
				!/(Prof(\.|ess))|(dr\.\s*med)/i.match(line)
			}
		end
		def number 
			if(match = /[0-9][^,]*/.match(self.lines[-2]))
				match.to_s.strip
			end
		end
		def plz
			if(match = /[1-9][0-9]{3}/.match(self.lines[-1]))
				 match.to_s
			end
		end
		def search_terms
			[self.lines_without_title, @fon, @fax, @plz, @city]
		end
		def street
			if(match = /[^0-9,]+/.match(self.lines[-2]))
				match.to_s.strip
			end
		end
		def <=>(other)
			self.lines <=> other.lines
		end
	end
end
