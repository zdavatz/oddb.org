#!/usr/bin/env ruby
# Substance -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'util/levenshtein_distance'
require 'util/language'
require 'model/cyp450connection'

module ODDB
	class Substance
		#include Persistence
		attr_reader :sequences, :substrate_connections
		include Comparable
		include Language
		def initialize
			super()
=begin
			if(name)
				@name = name.gsub(/\b[A-Z].+?\b/) { |match| match.capitalize }
			end
=end
			@sequences = []
			@substrate_connections = {}
		end
		def add_sequence(sequence)
			@sequences.push(sequence)
		end
		def adjust_types(values, app=nil)
			values.each { |key, value|
				if(key.to_s.size == 2)
					values[key] = value.to_s.gsub(/\b[A-Z].+?\b/) { |match| match.capitalize }
				end
			}
			values
		end
		def atc_classes
			@sequences.collect { |seq| seq.atc_class }.uniq
		end
		def create_cyp450substrate(cyp_id)
			#puts 'creating substrate'
			conn = ODDB::CyP450SubstrateConnection.new(cyp_id)
			@substrate_connections.store(conn.cyp_id, conn)
			conn
		end
		def cyp450substrate(cyp_id)
			@substrate_connections[cyp_id]
		end
		def delete_cyp450substrate(cyp_id)
			@substrate_connections.delete(cyp_id)
		end
		def has_interaction_with?(other)
			@substrate_connections.each { |conn|
				conn.has_interaction_with?(other)
			}
		end
		def name
			if(@name)
				@name
			# First call to descriptions should go to lazy-initialisator
			elsif(descriptions && @descriptions['lt']!="") 
				@descriptions['lt']
			elsif(@descriptions)
				@descriptions['en']
			end
		end
		def remove_sequence(sequence)
			@sequences.delete(sequence)
		end
		def same_as?(astring)
			descriptions.any? { |lang, desc|
				desc.downcase == astring.to_s.downcase
			}
		end
		def similar_name?(astring)
			name.length/3.0 >= name.downcase.ld(astring.downcase)
		end
		def to_s
			name
		end
		def <=>(other)
			to_s.downcase <=> other.to_s.downcase
		end
	end
end
