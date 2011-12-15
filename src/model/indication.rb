#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Indication -- oddb.org -- 15.12.2011 -- mhatakeyama@ywesee.com 
# ODDB::Indication -- oddb.org -- 12.05.2003 -- hwyss@ywesee.com 

require 'util/language'
require 'util/searchterms'
require 'model/registration_observer'
require 'model/sequence_observer'

module ODDB
	class Indication
		include Language
		include RegistrationObserver
		include SequenceObserver
		ODBA_SERIALIZABLE = [ '@descriptions', '@synonyms' ]
		def atc_classes
			atcs = @registrations.inject([]) do |memo, reg| 
				memo.concat reg.atc_classes
      end
      @sequences.each { |seq| atcs.push seq.atc_class }
      atcs.compact.uniq
		end
    def empty?
      @registrations.empty? && @sequences.empty?
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
    def description(key=nil)
      super.force_encoding('utf-8')
    end
	end
end
