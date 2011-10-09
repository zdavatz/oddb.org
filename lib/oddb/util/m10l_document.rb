#!/usr/bin/env ruby
# M10lDocument -- de.oddb.org -- 13.03.2008 -- hwyss@ywesee.com

require 'oddb/model'
require 'oddb/util/multilingual'

module ODDB
  module Util
    class M10lDocument < Model
      include M10lMethods
      connector :canonical
      attr_reader :previous_sources
      def initialize(canonical={})
        super
        @previous_sources = {}
      end
      def add_previous_source(lang, source)
        sources = (@previous_sources[lang.to_sym] ||= [])
        sources.push source
        sources.compact!
        sources.uniq!
        sources
      end
      def empty?
        @canonical.empty?
      end
      def method_missing(meth, *args, &block)
        case meth.to_s
        when /^([a-z]{2})=$/
          lang = $~[1].to_sym
          if(previous = @canonical[lang])
            add_previous_source(lang, previous.source)
          end
          @canonical.store(lang, args.first)
        else
          super(meth, *args, &block)
        end
      end
    end
  end
end
