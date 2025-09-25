#!/usr/bin/env ruby

# ODDB::Indication -- oddb.org -- 26.06.2012 -- yasaka@ywesee.com
# ODDB::Indication -- oddb.org -- 15.12.2011 -- mhatakeyama@ywesee.com
# ODDB::Indication -- oddb.org -- 12.05.2003 -- hwyss@ywesee.com

require "util/language"
require "util/searchterms"
require "model/registration_observer"
require "model/sequence_observer"

module ODDB
  class Indication
    include Language
    include RegistrationObserver
    include SequenceObserver
    ODBA_SERIALIZABLE = ["@descriptions", "@synonyms"]
    def atc_classes
      atcs = []
      if @registrations
        atcs = @registrations.each_with_object([]) do |reg, memo|
          if reg.atc_classes.is_a? Array
            memo.concat reg.atc_classes
          end
        end
      end
      @sequences.each { |seq| atcs.push seq.atc_class }
      atcs.compact.uniq
    end

    def empty?
      @registrations.empty? && @sequences.empty?
    end

    def search_text(lang = nil)
      if lang
        super
      else
        ODDB.search_term(all_descriptions.join(" "))
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
      synonyms.concat(other.all_descriptions - all_descriptions).uniq!
      other
    end

    def description(key = nil)
      super.to_s.encode("utf-8")
    end
  end
end
