#!/usr/bin/env ruby
# Substance -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'util/levenshtein_distance'
require 'util/language'
require 'util/soundex'
require 'model/sequence_observer'
require 'model/cyp450connection'

module ODDB
	class Substance
		include Persistence
		include SequenceObserver
		ODBA_PREFETCH = true
		ODBA_SERIALIZABLE = [ '@descriptions', '@connection_keys', '@synonyms' ]
		attr_reader :sequences, :substrate_connections
		attr_accessor :effective_form
		attr_writer :synonyms
		include Comparable
		include Language
		def Substance.format_connection_key(key)
			key.to_s.downcase.gsub(/[^a-z0-9]/, '')
		end
		def initialize
			super()
			@sequences = []
			@substrate_connections = {}
			@connection_keys = []
		end
		def adjust_types(values, app=nil)
			values.each { |key, value|
				if(key.to_s.size == 2)
					values[key] = value.to_s.gsub(/\b[A-Z].+?\b/) { |match| match.capitalize }
				else
					case key
					when :connection_keys
						values[key] = [ value ].flatten
					when :effective_form
						values[key] = value.resolve(app)
					end
				end
			}
			values
		end
		def atc_classes
			@sequences.collect { |seq| seq.atc_class }.uniq
		end
		def connection_keys
			keys = (@connection_keys || []) + self.descriptions.values \
				+ self.synonyms  + [self.name]
			@connection_keys = keys.collect { |key|
				format_connection_key(key)
			}.delete_if { |key| key.empty? }.uniq.sort
		end
		def connection_keys=(keys)
			@connection_keys += keys
			self.connection_keys
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
		def format_connection_key(key)
			Substance.format_connection_key(key)
		end
		def has_connection_key?(test_key)
			key = format_connection_key(test_key)
			!key.empty? && self.connection_keys.include?(key)
		end
		def has_effective_form?
			!@effective_form.nil?
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
		def interactions_with(other)
			interactions = _interactions_with(other) 
			if(has_effective_form? && !is_effective_form?)
				interactions += @effective_form._interactions_with(other)
			end
			interactions
		end
		def _interactions_with(other)
			if(@substrate_connections)
				@substrate_connections.values.collect { |conn|
					conn.interactions_with(other)
				}.flatten
			else
				[]
			end
		end
		def is_effective_form?
			@effective_form == self
		end
		def merge(other)
			other.sequences.uniq.each { |sequence|
				if(active_agent = sequence.active_agent(other))
					#puts "found active-agent: #{active_agent}"
					if(active_agent.sequence.nil?)
						#puts "no sequence - deleting active_agent"
						active_agent.odba_delete
					else
						#puts "setting substance to #{self}"
						active_agent.substance = self
						#puts "calling active_agent_isolated_store"
						active_agent.odba_isolated_store
					end
				else
					warn("Substance.merge: no active agent, only removing sequence")
					other.remove_sequence(sequence)
				end
			}
			other.substrate_connections.values.each { |substr_conn|
				unless(cyp450substrate(substr_conn.cyp_id))
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
			# long format, because each of these methods are overridden
			self.synonyms = self.synonyms + other.synonyms \
				+ other.descriptions.values - self.descriptions.values
			self.connection_keys = self.connection_keys + other.connection_keys
			self
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
		def primary_connection_key
			@primary_connection_key ||= format_connection_key(self.name)
		end
		def same_as?(substance)
			teststr = substance.to_s.downcase
			_search_keys.any? { |desc|
				desc.downcase == teststr
			} || (connection_keys.include?(format_connection_key(teststr)))
		end
		def search_keys
			keys = self._search_keys
			if(has_effective_form? && !is_effective_form?)
				keys += @effective_form.search_keys
			end
			keys.compact!
			keys.delete_if { |key|
				key.empty?
			}
			keys.uniq
		end
		def _search_keys
			keys = self.descriptions.values + self.connection_keys \
				+ self.synonyms
			keys.push(name)
			keys.compact
		end
		def similar_name?(astring)
			name.length/3.0 >= name.downcase.ld(astring.downcase)
		end
		def soundex_keys
			keys = self.search_keys.collect { |key|
				parts = key.split(/\s/)
				soundex = Text::Soundex.soundex(parts)
				soundex.join(' ')
			}
			keys.compact.uniq
		end
		def substrate_connections
			@substrate_connections ||= {}
		end
		def synonyms
			@synonyms ||= []
		end
		def synonyms=(syns)
			@synonyms = syns.compact.delete_if { |syn| syn.empty?  }
		end
		def to_s
			name
		end
		def unique_compare?(other)
			other_keys = other.connection_keys + other._search_keys
			own_keys = self.connection_keys + self.search_keys
			!(other_keys & own_keys).empty? # intersection
		end
		def <=>(other)
			to_s.downcase <=> other.to_s.downcase
		end
	end
end
