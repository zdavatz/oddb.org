#!/usr/bin/env ruby
# GalenicForm -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

require 'util/language'
require 'model/sequence_observer'

module ODDB
	class GalenicForm
		attr_reader :galenic_group
		include Comparable
		include Language
		include SequenceObserver
    include ODBA::Persistable ## include directly to get odba_index
		ODBA_SERIALIZABLE = [ '@descriptions', '@synonyms' ]
    odba_index :name, 'all_descriptions'
		def equivalent_to?(other)
			(self == other) || (@galenic_group == other.galenic_group)
		end
		def galenic_group=(group)
			@galenic_group.remove(self) unless(@galenic_group.nil?)
			group.add(self)
			@pointer = group.pointer + [:galenic_form, @oid]
			@galenic_group = group
		end
		def merge(other)
			other.sequences.dup.each { |seq|
        seq.compositions.each do |comp|
          if comp.galenic_form == other
            comp.galenic_form = self
            comp.odba_isolated_store
          end
        end
			}
			self.synonyms += other.all_descriptions - self.all_descriptions
		end
    def route_of_administration
      @galenic_group.route_of_administration if(@galenic_group)
    end
		def sequence_count
			@sequences.size
		end
		def <=>(other)
			to_s <=> other.to_s
		end
		private
		def adjust_types(values, app=nil)
			values = values.dup
			values.each { |key, value|
				case(key)
				when :galenic_group
					values[key] = value.resolve(app)
				end
			}
			values
		end
	end
end
