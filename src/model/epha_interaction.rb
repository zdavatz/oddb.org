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
    CSV_FILE = File.expand_path('../../data/csv/interactions_de_utf8.csv', File.dirname(__FILE__))
    CSV_ORIGIN_URL  = 'https://download.epha.ch/cleaned/matrix.csv'
    def EphaInteractions.read_csv
      @csv_file_path = CSV_FILE
      unless CSV_FILE and File.exist?(CSV_FILE)
        target = Mechanize.new.get(CSV_ORIGIN_URL)
        target.save_as @csv_file_path
        $stdout.puts  "#{Time.now}: EphaInteractionPlugin.update: #{File.expand_path(@csv_file_path)} ?  #{File.exists?(@csv_file_path)}"
      end
      if File.exist?(@csv_file_path)
        @lineno = 0
        first_line = nil
        File.readlines(@csv_file_path).each do |line|
          @lineno += 1
          line = line.force_encoding('utf-8')
          next if /ATC1.*Name1.*ATC2.*Name2/.match(line)
          begin
            elements = CSV.parse_line(line)
          rescue CSV::MalformedCSVError
            $stdout.puts "CSV::MalformedCSVError in line #{@lineno}: #{line}"
            next
          end
          epha_interaction = EphaInteraction.new
          epha_interaction.atc_code_self = elements[0]
          epha_interaction.atc_name = elements[1]
          epha_interaction.atc_code_other = elements[2]
          epha_interaction.name_other = elements[3]
          epha_interaction.info = elements[4]
          epha_interaction.action = elements[5]
          epha_interaction.effect = elements[6]
          epha_interaction.measures = elements[7]
          epha_interaction.severity = elements[8]
          EphaInteractions.get[ [epha_interaction.atc_code_self, epha_interaction.atc_code_other  ]] = epha_interaction
        end
        $stdout.puts "#{Time.now}: Added #{EphaInteractions.get.size} interaction from #{@csv_file_path}"; $stdout.flush
        FileUtils.mv(@csv_file_path, @csv_file_path.sub(/\.csv$/, '-latest.csv'), :verbose => true) unless defined?(MiniTest)
      end
    end

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
      EphaInteractions.get[ [atc_code_self, atc_code_other] ]
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
    # Based on information contained in http://community.epha.ch/interactions_de_utf8.csv
    # ATC1  Name1 ATC2  Name2 Info  Mechanismus Effekt  Massnahmen  Grad
    # N06AB06 Sertralin M03BX02 Tizanidin Keine Interaktion Tizanidin wird über CYP1A2 metabolisiert. Sertralin beeinflusst CYP1A2 jedoch nicht.  Keine Interaktion.  Die Kombination aus Sertralin und Tizanidin hat kein bekanntes Interaktionspotential. A
    attr_accessor :atc_code_self, :atc_code_other # these two items are our unique index. They may not be changed
    attr_accessor :atc_name, :name_other, :info, :action, :effect, :measures, :severity
    EphaInteractions.read_csv if EphaInteractions.get.size == 0
    
    def initialize
    end

    def init(app)
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
