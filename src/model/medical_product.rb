#!/usr/bin/env ruby
# encoding: utf-8
2
require 'util/persistence'
require 'util/searchterms'
require 'util/language'
  
module ODDB
  class MedicalProduct
    include ODBA::Persistable
    attr_accessor :name, :ean13s, :chapters
    def initialize
      @name = name
      super
    end
    def init(app)
      @pointer.append(@oid)
    end
    def search_terms
      terms = [
        @atc_code, @ean13,
        @name_base, @chapters,
      ]
      ODDB.search_terms(terms)
    end
    def search_text
      search_terms.join(' ')
    end
    def pointer_descr
      [@name, @ean13s].compact.join(' ')
    end
    def to_s
      # bin/admin will not display lines longer than 200 chars
      [@name, @ean13s].compact.join(';')[0..199]
    end
  end
end
