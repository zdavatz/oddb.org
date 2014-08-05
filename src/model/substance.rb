#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Substance -- oddb.org -- 19.02.2012 -- mhatakeyama@ywesee.com 
# ODDB::Substance -- oddb.org -- 25.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'util/levenshtein_distance'
require 'util/language'
require 'util/soundex'
require 'model/sequence_observer'

module ODDB
	class Substance
		include Persistence
		include SequenceObserver
		ODBA_SERIALIZABLE = [ '@descriptions', '@synonyms' ]
    attr_reader :chemical_forms, :effective_form, :sequences
		attr_accessor :swissmedic_code, :casrn
		include Comparable
		include Language
		def initialize
			super()
			@sequences = []
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
			values.dup.each { |key, value|
				if(key.to_s.size == 2)
          newval = value.to_s.gsub(/\S+/u) { |match|
						match.capitalize
					}
          newval.gsub!(/(?<=\s)[a-z]{1,4}[\s.]/iu) { |match|
            match.downcase 
          }
					newval.gsub!(/\bhcl\b/iu, 'HCl')
          newval.gsub!(/([\d\(\)\-].)|(\b[dl]{1,2}-.)|(\..)|(\b[IVX]+\b)/iu) { |match|
            match.upcase 
          }
          values[key] = newval
				else
					case key
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
			@sequences.empty? && !is_effective_form?
		end
		def has_effective_form?
			!@effective_form.nil?
		end
		def is_effective_form?
			@effective_form == self
		end
		def merge(other)
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
			other.descriptions.dup.each { |key, value|
				unless(self.descriptions.has_key?(key))
					self.descriptions.update_values( { key => value } )
				end
			}
			# long format, because each of these methods are overridden
			self.synonyms = self.synonyms + other.synonyms \
				+ other.descriptions.values - self.descriptions.values
			self
		end
		def name
			# First call to descriptions should go to lazy-initialisator
			#if(lt = self.descriptions['lt']) && !lt.empty?
			if descrs = self.descriptions and lt = descrs['lt'] and !lt.empty?
				lt.to_s
      elsif @descriptions and en = @descriptions['en']
				en.to_s
      else
        ''
			end
    rescue => e
      @@name_error_count ||= 0
      @@name_error_count += 1
      warn "#{@@name_error_count}, ODDB::Substance#descriptions error: Substance#odba_id = #{self.odba_id}"
      ''
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
			} 
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
			keys = self.descriptions.values  \
				+ self.synonyms
			keys.push(name).collect { |key| ODDB.search_term(key) }
		end
		def similar_name?(astring)
			name.length/3.0 >= name.downcase.ld(astring.downcase)
		end
		def soundex_keys
			keys = self.search_keys.collect { |key|
				parts = ODDB.search_term(key).split(/\s/u)
				soundex = Text::Soundex.soundex(parts)
				soundex.join(' ')
			}
			keys.compact.uniq
		end
		def to_i
			oid
		end
		def to_s
			name
		end
		def unique_compare?(other)
			other_keys = other._search_keys
			own_keys = self.search_keys
			!(other_keys & own_keys).empty? # intersection
		end
		def update_values(values, origin=nil)
			super
		end
		def <=>(other)
			to_s.downcase <=> other.to_s.downcase
		end
	end
end
