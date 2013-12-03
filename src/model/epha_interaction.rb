#!/usr/bin/env ruby
# encoding: utf-8
2
require 'util/persistence'
require 'util/searchterms'
require 'util/language'
  
module ODDB
  class EphaInteraction
    include ODBA::Persistable
    include Persistence
    # Based on information contained in http://community.epha.ch/interactions_de_utf8.csv
    # ATC1  Name1 ATC2  Name2 Info  Mechanismus Effekt  Massnahmen  Grad
    # N06AB06 Sertralin M03BX02 Tizanidin Keine Interaktion Tizanidin wird über CYP1A2 metabolisiert. Sertralin beeinflusst CYP1A2 jedoch nicht.  Keine Interaktion.  Die Kombination aus Sertralin und Tizanidin hat kein bekanntes Interaktionspotential. A
    attr_accessor :atc_code_self, :atc_code_other # these two items are our unique index. They may not be changed
    attr_accessor :atc_name, :name_other, :info, :action, :effect, :measures, :severity
    def initialize
      super
    end
    def init(app)
      @pointer.append(@oid)
    end
    def search_terms
      terms = [
        @atc_code_self, @atc_name,
        @atc_code_other, @name_other,
        @info ,@action, @effect, 
        @measures, @severity
      ]
      ODDB.search_terms(terms)
    end
    def search_text
      search_terms.join(' ')
    end
    def pointer_descr
      [@atc_code_self, @atc_name, @atc_code_other, @name_other, @info].compact.join(' ')
    end
    def to_s
      # bin/admin will not display lines longer than 200 chars
      [@atc_code_self, @atc_name, @atc_code_other, @name_other, @info,
        @action, @effect,  @measures, @severity].compact.join(';')[0..199]
    end
  end
end
