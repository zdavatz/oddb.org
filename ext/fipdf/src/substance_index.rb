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
				arr = super
				arr.each { |key, element| 
					element.sort! 
				}
				arr
			end
		end
	end
end
