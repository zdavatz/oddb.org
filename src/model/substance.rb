#!/usr/bin/env ruby
# Substance -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'util/levenshtein_distance'
require 'util/language'
require 'model/cyp450connection'

module ODDB
	class Substance
		#include Persistence
		attr_reader :sequences
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
		def interaction_connections(others)
			#puts '=========substance'
			if(@substrate_connections)
				#puts 'substrate_connections found'
				connections = {}
				@substrate_connections.each { |cyp450_id, subs_connection|
					#puts "subs_connection: #{subs_connection}"
					others.each { |substance|
						#puts "other substance: #{substance}"
						interactions = subs_connection.interactions_with(substance)
						#puts "iiiiinnnnteractions: #{interactions.size}"
						if(int_conn = connections[cyp450_id])
							int_conn.concat(interactions)
						else
							connections.store(cyp450_id, interactions)
						end
					}
				}
				#puts "ccccccccccccccccccccconnections: #{connections.size}"
				connections
			else
				{}	
			end
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
		def same_as?(substance)
			descriptions.any? { |lang, desc|
				desc.downcase == substance.to_s.downcase
			}
		end
		def similar_name?(astring)
			name.length/3.0 >= name.downcase.ld(astring.downcase)
		end
		def substrate_connections
			@substrate_connections || {}
		end
		def to_s
			name
		end
		def <=>(other)
			to_s.downcase <=> other.to_s.downcase
		end
	end
end
