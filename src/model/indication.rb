#!/usr/bin/env ruby
# Indication -- oddb -- 12.05.2003 -- hwyss@ywesee.com 

require 'util/language'
require 'model/registration_observer'
require 'model/sequence_observer'

module ODDB
	class Indication
		include Language
		include RegistrationObserver
		include SequenceObserver
		ODBA_SERIALIZABLE = [ '@descriptions', '@synonyms' ]
		def atc_classes
			atcs = @registrations.collect { |reg| 
				reg.atc_classes
			}.flatten
      @sequences.each { |seq| atcs.push seq.atc_class }
      atcs.compact.uniq
		end
		def search_text(lang=nil)
      if(lang)
        super
      else
        ODDB.search_term(self.all_descriptions.join(" "))
      end
		end
    def merge(other)
      if regs = other.registrations
        regs.dup.each do |reg|
          reg.indication = self
        end
      end
      if seqs = other.sequences
        seqs.dup.each do |seq|
          seq.indication = self
        end
      end
      self.synonyms.concat(other.all_descriptions - all_descriptions).uniq!
      other
    end
	end
end
