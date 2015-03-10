#!/usr/bin/env ruby
# encoding: utf-8
require 'util/persistence'
require 'util/searchterms'
require 'util/language'
require 'mechanize'
require 'csv'

module ODDB
  module EphaInteractions
    # see http://matrix.epha.ch/#/56751,61537,39053,59256
    Ratings = {  'A' => 'Keine Massnahmen erforderlich',
                  'B' => 'Vorsichtsmassnahmen empfohlen',
                  'C' => 'Regelmässige Überwachung',
                  'D' => 'Kombination vermeiden',
                  'X' => 'Kontraindiziert',
              }
    # using the same color like https://raw.githubusercontent.com/zdavatz/AmiKo-Windows/master/css/interactions_css.css
    Colors =  {  'A' => '#caff70',
                 'B' => '#ffec8b',
                 'C' => '#ffb90f',
                 'D' => '#ff82ab',
                 'X' => '#ff6a6a',
                 }
    @@epha_interactions ||= {}
    def EphaInteractions.get
      @@epha_interactions
    end
    def EphaInteractions.set(interactions)
      @@epha_interactions = interactions
    end
    CSV_FILE = File.expand_path('../../data/csv/interactions_de_utf8.csv', File.dirname(__FILE__))
    CSV_ORIGIN_URL  = 'https://download.epha.ch/data/matrix/matrix.csv'
    def self.calculate_atc_codes(drugs)
      atc_codes = []
      if drugs and !drugs.empty?
        drugs.each{ |ean, drug|
          atc_codes << drug.atc_class.code if drug and drug.atc_class
        }
      end
      atc_codes
    end
    def EphaInteractions.get_epha_interaction(atc_code_self, atc_code_other)
      result = nil
      @@epha_interactions.each{ | key, value |
                                if key[0].to_s.eql?(atc_code_self) and  key[1].to_s.eql?(atc_code_other)
                                  result = value
                                  break
                                end
                              }
      result
    end

    def EphaInteractions.get_interactions(my_atc_code, drugs)
      atc_codes = calculate_atc_codes(drugs)
      results = []
      idx=atc_codes.index(my_atc_code)
      atc_codes[0..-1].combination(2).to_a.each {
        |combination|
        [ EphaInteractions.get_epha_interaction(combination[0], combination[1]),
          EphaInteractions.get_epha_interaction(combination[1], combination[0]),
        ].each{
                |interaction|
          next unless interaction
          next unless interaction.atc_code_self.eql?(my_atc_code)
          header = ''
          header += interaction.atc_code_self  + ': ' + interaction.atc_name + ' => '
          header += interaction.atc_code_other + ': ' + interaction.name_other
          header += ' ' + interaction.info
          text = ''
          text += interaction.severity + ': ' + Ratings[interaction.severity]
          text += '<br>' + interaction.action
          text += '<br>' + interaction.measures + '<br>'

          results << { :header => header,
                      :severity => interaction.severity,
                    :color => Colors[interaction.severity],
                    :text => text
                    }
        }
      }
      results.uniq.sort_by { |item| item[:severity] + item[:header]  }.reverse
    end
  end
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
        @info, @action, @effect,
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
