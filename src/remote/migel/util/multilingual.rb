#!/usr/bin/env ruby
# enconding: utf-8
# Migel::Util::Multilingual -- migel -- 26.08.2011 -- mhatakeyama@ywesee.com

module Migel
  module Util
    module M10lMethods
      include Comparable
      attr_reader :canonical
      attr_reader :synonyms
      def initialize(canonical={})
        @canonical = canonical
      end
      def all
        @canonical.values
      end
      def empty?
        @canonical.empty?
      end
      def method_missing(meth, *args, &block)
        case meth.to_s
        when /^[a-z]{2}$/
          @canonical[meth]
        when /^([a-z]{2})=$/
          @canonical.store($~[1].to_sym, args.first)
        else
          super(meth, *args, &block)
        end
      end
      def to_s
        @canonical.values.compact.sort.first.to_s
      end
      def ==(other)
        case other
        when String
          @canonical.values.any? { |val| val == other } \
            || @synonyms.any? { |val| val == other }
        when M10lDocument
          @canonical == other.canonical && @synonyms == other.synonyms
        when M10lMethods
          @canonical == other.canonical
        else
          false
        end
      end
      def <=>(other)
        all.sort <=> other.all.sort
      end
    end
    class Multilingual 
      #include DRb::DRbUndumped
      include M10lMethods
      def initialize(canonical={})
        super
        @synonyms = []
      end
      def add_synonym(synonym)
        @synonyms.push(synonym).uniq! && synonym
      end
      def all
        terms = super.concat(@synonyms).compact
        terms.concat(terms.collect do |term| term.gsub(/[^\w]/, '') end)
        terms.uniq
      end
      def merge(other)
        @synonyms.concat(other.all).uniq!
      end
      def parent=(parent)
        # This is used when Migel::Importer updates the limitaion_text
        @parent = parent
      end
      def parent(arg = nil)
        # This is used when limitation_text is shown in ODDB::View::LimitationText
        @parent
      end
      def pointer
        'pointer'
      end
      def de
        @canonical[:de]
      end
      alias :en :de
      def fr
        @canonical[:fr]
      end
      # For PointerSteps (snapback links)
      def pointer_descr
        'Limitation'
      end
      def structural_ancestors(app)
        #[@parent.subgroup.group, @parent.subgroup, @parent]
        ancestors = []
        me = self
        while parent = me.parent
          ancestors.unshift parent
          me = parent
        end
        ancestors
      end
    end
  end
end

#require 'migel/util/m10l_document'
