#!/usr/bin/env ruby
# Substance -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'util/levenshtein_distance'
require 'util/language'
require 'util/soundex'
require 'model/cyp450connection'

module ODDB
	class Substance
		include Persistence
		ODBA_PREFETCH = true
		ODBA_SERIALIZABLE = [ '@descriptions', '@connection_keys' ]
		attr_reader :sequences, :substrate_connections
		include Comparable
		include Language
		def initialize
			super()
			@sequences = []
			@substrate_connections = {}
		end
		def add_sequence(sequence)
			@sequences.push(sequence)
			@sequences.odba_isolated_store
			sequence
		end
		def adjust_types(values, app=nil)
			values.each { |key, value|
				if(key.to_s.size == 2)
					values[key] = value.to_s.gsub(/\b[A-Z].+?\b/) { |match| match.capitalize }
				elsif(key == :connection_keys)
					values[key] = [ value ].flatten
				end
			}
			values
		end
		def atc_classes
			@sequences.collect { |seq| seq.atc_class }.uniq
		end
		def connection_keys
			@connection_keys or if(!self.descriptions['en'].empty?)
				self.connection_keys = [@descriptions['en']]
			else
				self.connection_keys = [@name]
			end
		end
		def connection_keys=(keys)
			@connection_keys = keys.collect { |key|
				format_connection_key(key)
			}.delete_if { |key| key.empty? }.uniq.sort
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
		def empty?
			(@substances.nil? || @substances.empty?)
		end
		def format_connection_key(key)
			key.to_s.downcase.gsub(/[^a-z0-9]/, '')
		end
		def has_connection_key?(test_key=nil)
			if(test_key)
				key = format_connection_key(test_key)
				!key.empty? && @connection_keys.include?(key)
			else
				@connection_keys && !@connection_keys.empty?
			end
		end
		def search_keys
			keys = (self.descriptions.values + [@name]).compact
			keys.delete_if { |key|
				key.empty?
			}.uniq
			keys
		end
		def soundex_keys
			names = self.descriptions.values + self.connection_keys
			names.push(name)
			keys = names.compact.uniq.collect { |key|
				parts = key.split(/\s/)
				soundex = Text::Soundex.soundex(parts)
				soundex.join(' ')
			}
			keys.compact.uniq
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
			other.sequences.dup.each { |sequence|
				if(active_agent = sequence.active_agent(other))
					if(@sequences.include?(sequence))
						sequence.delete_active_agent(other)
					else
						active_agent.substance = self
						active_agent.odba_isolated_store
					end
				else
					other.remove_sequence(sequence)
				end
			}
			other.substrate_connections.values.each { |substr_conn|
				if((cyp450substrate(substr_conn.cyp_id)).nil?)
					substr_conn.pointer = self.pointer + substr_conn.pointer.last_step
					substrate_connections.store(substr_conn.cyp_id, substr_conn)
					substr_conn.odba_isolated_store
				end
			}
			substrate_connections.odba_isolated_store
			other.descriptions.dup.each { |key, value|
				unless(self.descriptions.has_key?(key))
					self.descriptions.update_values( { key => value } )
				end
			}
			self.descriptions.odba_isolated_store
			# long format, because each of these methods are overridden
			self.connection_keys = self.connection_keys + other.connection_keys
			@connection_keys.odba_isolated_store
		end
		def name
			# First call to descriptions should go to lazy-initialisator
			if(@name)
				@descriptions['lt'] = @name if(self.descriptions['lt'].empty?)
				@name
			elsif(self.descriptions && !@descriptions['lt'].empty?) 
				@descriptions['lt']
			elsif(self.descriptions)
				@descriptions['en']
			end
		end
		alias :pointer_descr :name
		def remove_sequence(sequence)
			del = @sequences.delete(sequence)
			@sequences.odba_isolated_store
			del
		end
		def same_as?(substance)
			teststr = substance.to_s.downcase
			descriptions.any? { |lang, desc|
				desc.is_a?(String) && desc.downcase == teststr
			} || (connection_keys.include?(format_connection_key(teststr)))
		end
		def similar_name?(astring)
			name.length/3.0 >= name.downcase.ld(astring.downcase)
		end
		def substrate_connections
			@substrate_connections ||= {}
		end
		def to_s
			name
		end
		def <=>(other)
			to_s.downcase <=> other.to_s.downcase
		end
	end
end
