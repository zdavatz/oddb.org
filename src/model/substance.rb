#!/usr/bin/env ruby
# Substance -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'util/levenshtein_distance'
require 'util/language'
require 'model/cyp450connection'

module ODDB
	class Substance
		include Persistence
		ODBA_PREFETCH = true
		attr_reader :sequences, :substrate_connections
		attr_accessor :connection_key
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
				elsif(key == :connection_key)
					values[key] = value.to_s.downcase
				end
			}
			values
		end
		def atc_classes
			@sequences.collect { |seq| seq.atc_class }.uniq
		end
		def connection_key
			if(@connection_key)
				@connection_key
			elsif(!@descriptions['en'].empty?)
				@descriptions['en']
			else
				@name
			end
		end
		def	create_cyp450substrate(cyp_id)
			conn = ODDB::CyP450SubstrateConnection.new(cyp_id)
			@substrate_connections.store(conn.cyp_id, conn)
			conn
		end
		def cyp450substrate(cyp_id)
			if(@substrate_connections)
				@substrate_connections[cyp_id]
			end
		end
		def delete_cyp450substrate(cyp_id)
			@substrate_connections.delete(cyp_id)
		end
		def has_connection_key?
			@connection_key ? true : false	
		end
		def interaction_connections(others)
			if(@substrate_connections)
				connections = {}
				@substrate_connections.each { |cyp450_id, subs_connection|
					others.each { |substance|
						interactions = subs_connection.interactions_with(substance)
						if(int_conn = connections[cyp450_id])
							int_conn.concat(interactions)
						else
							connections.store(cyp450_id, interactions)
						end
					}
				}
				connections
			else
				{}	
			end
		end
		def merge(other)
			other.sequences.dup.uniq.each { |sequence|
				if(active_agent = sequence.active_agent(other))
					if(@sequences.include?(sequence))
						sequence.delete_active_agent(other)
					else
						active_agent.substance = self
					end
				else
					other.remove_sequence(sequence)
				end
			}
			other.substrate_connections.values.dup.each { |substr_conn|
				if((cyp450substrate(substr_conn.cyp_id)).nil?)
					substr_conn.pointer = self.pointer + substr_conn.pointer.last_step
					substrate_connections.store(substr_conn.cyp_id, substr_conn)
				end
			}
			other.descriptions.dup.each { |key, value|
				unless(@descriptions.has_key?(key))
					@descriptions.update_values( { key => value } )
				end
			}
			unless(@connection_key)
				@connection_key = other.connection_key
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
			result = descriptions.any? { |lang, desc|
				desc.downcase == substance.to_s.downcase
			}
			unless(result==true)
				result = true if(substance.to_s.downcase == connection_key.downcase)
			end
			result
		end
		def similar_name?(astring)
			name.length/3.0 >= name.downcase.ld(astring.downcase)
		end
		def substrate_connections
			unless(@substrate_connections)
				@substrate_connections = {}
			end
			@substrate_connections
		end
		def to_s
			name
		end
		def <=>(other)
			to_s.downcase <=> other.to_s.downcase
		end
	end
end
