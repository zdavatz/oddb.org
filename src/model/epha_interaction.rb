#!/usr/bin/env ruby

require "util/persistence"
require "util/searchterms"
require "util/language"
require "util/logfile"
require "csv"

module ODDB
  module EphaInteractions
    # see http://matrix.epha.ch/#/56751,61537,39053,59256
    Ratings = {"A" => "Keine Massnahmen erforderlich",
               "B" => "Vorsichtsmassnahmen empfohlen",
               "C" => "Regelmässige Überwachung",
               "D" => "Kombination vermeiden",
               "X" => "Kontraindiziert"}
    # using the same color like https://raw.githubusercontent.com/zdavatz/AmiKo-Windows/master/css/interactions_css.css
    Colors = {"A" => "#caff70",
              "B" => "#ffec8b",
              "C" => "#ffb90f",
              "D" => "#ff82ab",
              "X" => "#ff6a6a"}
    @@epha_interactions ||= {}
    def self.get
      @@epha_interactions
    end
    CSV_FILE = File.join(ODDB::WORK_DIR, "csv/interactions_de_utf8.csv")
    CSV_ORIGIN_URL = "https://raw.githubusercontent.com/zdavatz/oddb2xml_files/master/interactions_de_utf8.csv"
    EPHA_INFO = Struct.new(:atc_code_self, :atc_code_other, # these two items are our unique index. They may not be changed
      :atc_name, :name_other, :info, :action, :effect, :measures, :severity)

    def self.read_from_csv(csv_file)
      unless File.exist?(csv_file)
        puts "Warning #{csv_file} not found. No EphaInteractions saved"
        return
      end
      startTime = Time.now
      FileUtils.makedirs(File.dirname(ODDB::EphaInteractions::CSV_FILE))
      FileUtils.cp(csv_file, ODDB::EphaInteractions::CSV_FILE, preserve: true, verbose: true) unless ODDB::EphaInteractions::CSV_FILE.eql?(csv_file)
      counter = 0
      File.readlines(csv_file).each do |line|
        line = line.force_encoding("utf-8")
        next if /ATC1.*Name1.*ATC2.*Name2/.match?(line)
        begin
          elements = CSV.parse_line(line)
        rescue CSV::MalformedCSVError
          msg << "CSV::MalformedCSVError in line #{counter}: #{line}"
          next
        end
        next if elements.size == 0 # Eg. empty line at the end
        epha_interaction = EPHA_INFO.new
        counter += 1
        epha_interaction.atc_code_self = elements[0]
        epha_interaction.atc_name = elements[1]
        epha_interaction.atc_code_other = elements[2]
        epha_interaction.name_other = elements[3]
        epha_interaction.info = elements[4]
        epha_interaction.action = elements[5]
        epha_interaction.effect = elements[6]
        epha_interaction.measures = elements[7]
        epha_interaction.severity = elements[8]
        @@epha_interactions [[epha_interaction.atc_code_self, epha_interaction.atc_code_other]] = epha_interaction
      end
      endTime = Time.now
      LogFile.debug("Took #{(endTime - startTime).to_i} seconds to load #{csv_file}")
    end

    def self.calculate_atc_codes(drugs)
      atc_codes = []
      if drugs and !drugs.empty?
        drugs.each { |ean, drug|
          atc_codes << drug.atc_class.code if drug and drug.atc_class
        }
      end
      atc_codes
    end

    def self.get_epha_interaction(atc_code_self, atc_code_other)
      result = nil
      @@epha_interactions.each { |key, value|
        if key[0].to_s.eql?(atc_code_self) and key[1].to_s.eql?(atc_code_other)
          result = value
          break
        end
      }
      result
    end

    def self.get_interactions(my_atc_code, drugs)
      atc_codes = calculate_atc_codes(drugs)
      results = []
      atc_codes.index(my_atc_code)
      atc_codes[0..-1].combination(2).to_a.each { |combination|
        [EphaInteractions.get_epha_interaction(combination[0], combination[1]),
          EphaInteractions.get_epha_interaction(combination[1], combination[0])].each { |interaction|
          next unless interaction
          next unless interaction.atc_code_self.eql?(my_atc_code)
          header = ""
          header += interaction.atc_code_self + ": " + interaction.atc_name + " => "
          header += interaction.atc_code_other + ": " + interaction.name_other
          header += " " + interaction.info
          text = ""
          text += interaction.severity + ": " + Ratings[interaction.severity]
          text += "<br>" + interaction.action
          text += "<br>" + interaction.measures + "<br>"

          results << {header: header,
                      severity: interaction.severity,
                    color: Colors[interaction.severity],
                    text: text}
        }
      }
      results.uniq.sort_by { |item| item[:severity] + item[:header] }.reverse
    end
  end
end
