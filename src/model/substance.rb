#!/usr/bin/env ruby
# Substance -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'util/levenshtein_distance'

module ODDB
	class Substance
		include Persistence
		ODBA_PREFETCH = true
		attr_reader :name, :sequences
		include Comparable
		def initialize(name)
			super()
			@name = name.gsub(/\b[A-Z].+?\b/) { |match| match.capitalize }
			@sequences = []
		end
		def add_sequence(sequence)
			@sequences.push(sequence)
		end
		def remove_sequence(sequence)
			@sequences.delete(sequence)
		end
		def similar_name?(astring)
			@name.length/3.0 >= @name.downcase.ld(astring.downcase)
		end
		def to_s
			@name
		end
		def <=>(other)
			@name.downcase <=> other.to_s.downcase 
		end
	end
end
