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
		ODBA_SERIALIZABLE = [ '@descriptions', '@synonyms' ]
		class << self
			def reset_oid
				@@oid = 0
			end
		end
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
			other.sequences.each { |seq|
				seq.galenic_form = self
				seq.odba_isolated_store
			}
			self.synonyms += other.all_descriptions - self.all_descriptions
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
		protected
		def sequences
			@sequences.dup
		end
	end
end
