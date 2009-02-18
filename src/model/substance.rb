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
		ODBA_SERIALIZABLE = [ '@descriptions', '@connection_keys', '@synonyms' ]
    attr_reader :chemical_forms, :effective_form, :sequences, :narcotic,
      :substrate_connections
		attr_accessor :swissmedic_code, :casrn
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
      @chemical_forms = []
		end
    def add_chemical_form(form)
      if(form && form != self && !@chemical_forms.include?(form))
        @chemical_forms.push(form)
        @chemical_forms.odba_isolated_store
      end
      odba_isolated_store
      form
    end
		def adjust_types(values, app=nil)
			values.each { |key, value|
				if(key.to_s.size == 2)
          newval = value.to_s.gsub(/\S+/) { |match| 
						match.capitalize
					}
          newval.gsub!(/(?<=\s)[a-z]{1,4}[\s.]/i) { |match| 
            match.downcase 
          }
					newval.gsub!(/\bhcl\b/i, 'HCl')
          newval.gsub!(/([\d\(\)\-].)|(\b[dl]{1,2}-.)|(\..)|(\b[IVX]+\b)/i) { |match| 
            match.upcase 
          }
          values[key] = newval
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
    def checkout
      @sequences.odba_delete
      self.narcotic = nil
      @substrate_connections.values.each { |conn| conn.odba_delete }
      @substrate_connections.odba_delete
    end
		def connection_keys
			@connection_keys || self.update_connection_keys
		end
		def connection_keys=(keys)
			@connection_keys += keys
			self.connection_keys
		end
		def	create_cyp450substrate(cyp_id)
			conn = ODDB::CyP450SubstrateConnection.new(cyp_id)
      conn.substance = self
			@substrate_connections.store(conn.cyp_id, conn)
			conn
		end
		def cyp450substrate(cyp_id)
			if(@substrate_connections)
				@substrate_connections[cyp_id]
			end
		end
		def delete_cyp450substrate(cyp_id)
			if(cyp = @substrate_connections.delete(cyp_id))
				@substrate_connections.odba_isolated_store
				cyp
			end
		end
    def effective_form=(form)
      if(@effective_form.respond_to?(:remove_chemical_form))
        @effective_form.remove_chemical_form(self)
      end
      if(form.respond_to?(:add_chemical_form))
        form.add_chemical_form(self)
      end
      @effective_form = form
    end
		def empty?
			@sequences.empty? && @narcotic.nil? \
				&& @substrate_connections.empty? && !is_effective_form?
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
				interactions += @effective_form.interactions_with(other)
			end
      if(other.has_effective_form? && !other.is_effective_form?)
				interactions += interactions_with(other.effective_form)
      end
			interactions.uniq
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
      if(@narcotic.nil? && other.narcotic)
        narc = other.narcotic
        other.narcotic = nil
        self.narcotic = narc
      end
      @swissmedic_code ||= other.swissmedic_code
      @casrn ||= other.casrn
			other.sequences.uniq.each { |sequence|
        sequence.compositions.dup.each do |composition|
          if(active_agent = composition.active_agent(other))
            if(active_agent.sequence.nil?)
              active_agent.odba_delete
            else
              active_agent.substance = self
              active_agent.odba_isolated_store
            end
          else
            warn("Substance.merge: no active agent, only removing sequence")
            other.remove_sequence(sequence)
          end
        end
			}
      ocons = other.substrate_connections
			ocons.dup.each { |key, substr_conn|
				unless(cyp450substrate(substr_conn.cyp_id))
					substr_conn.pointer = self.pointer + substr_conn.pointer.last_step
					substrate_connections.store(substr_conn.cyp_id, substr_conn)
					substr_conn.odba_isolated_store
          ocons.delete(key)
				end
			}
			substrate_connections.odba_isolated_store
      ocons.odba_isolated_store
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
				#@descriptions['lt'] = @name if(self.descriptions['lt'].empty?)
				@name.to_s
			elsif(lt = self.descriptions['lt']) && !lt.empty?
				lt
			else
				@descriptions['en'].to_s
			end
		end
		alias :pointer_descr :name
    def names
			names = self._names
			if(has_effective_form? && !is_effective_form?)
				names += @effective_form.names
			end
			names.compact!
			names.delete_if { |name|
				name.empty?
			}
      names
    end
    def _names
      self.descriptions.values + self.synonyms
    end
		def narcotic=(narc)
			if(@narcotic)
				@narcotic.remove_substance(self)
			end
			if(narc)
				narc.add_substance(self)
			end
			@narcotic = narc
		end
		def primary_connection_key
			@primary_connection_key ||= format_connection_key(self.name)
		end
    def remove_chemical_form(form)
      if(@chemical_forms.delete(form))
        @chemical_forms.odba_isolated_store
      end
      form
    end
		def same_as?(substance)
			teststr = ODDB.search_term(substance.to_s.downcase)
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
			ODDB.search_terms(keys).uniq
		end
		def _search_keys
			keys = self.descriptions.values + self.connection_keys \
				+ self.synonyms
			keys.push(name).collect { |key| ODDB.search_term(key) }
		end
		def similar_name?(astring)
			name.length/3.0 >= name.downcase.ld(astring.downcase)
		end
		def soundex_keys
			keys = self.search_keys.collect { |key|
				parts = ODDB.search_term(key).split(/\s/)
				soundex = Text::Soundex.soundex(parts)
				soundex.join(' ')
			}
			keys.compact.uniq
		end
		def substrate_connections
			@substrate_connections ||= {}
		end
		def to_i
			oid
		end
		def to_s
			name
		end
		def unique_compare?(other)
			other_keys = other.connection_keys + other._search_keys
			own_keys = self.connection_keys + self.search_keys
			!(other_keys & own_keys).empty? # intersection
		end
		def update_connection_keys
			keys = (@connection_keys || []) + self.descriptions.values \
				+ self.synonyms  + [self.name]
			@connection_keys = keys.collect { |key|
					format_connection_key(key)
			}.delete_if { |key| key.empty? }.uniq.sort
		end
		def update_values(values, origin=nil)
			super
			update_connection_keys
		end
		def <=>(other)
			to_s.downcase <=> other.to_s.downcase
		end
	end
end
