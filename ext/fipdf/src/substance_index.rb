#!/usr/bin/env ruby
# SubstanceIndex -- oddb/fipdf -- 18.02.2004 -- mwalder@ywesee.com

module ODDB
	module FiPDF
		class SubstanceIndex < Hash
			def store(key, value)
				value.collect! { |val|
					val.to_s
				}
				(self[key] ||= []).push(value)
			end
			def sort
				arr = sort_by { |key, element|
          ODDB.search_term(key).downcase
        }
				arr.each { |key, element| 
					element.sort! 
				}
				arr
			end
		end
	end
end
