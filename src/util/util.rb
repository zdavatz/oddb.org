# encoding: utf-8

module ODDB

  module Util
    # please keep this constant in sync between (GEM) swissmedic-diff/lib/swissmedic-diff.rb and (GEM) oddb2xml/lib/oddb2xml/extractor.rb
    def Util.check_column_indices(sheet)
      if  /Zugelassene Verpackungen/i.match(sheet[2][0].value)
        row = sheet[3] # Headers are found at row 3
      elsif /Zulassungs-nummer/i.match(sheet[4][0].value)
        row = sheet[4] # Headers are found at row 4
      else
        raise "Did not find Zugelassene Verpackunge in row 3 or 4"
      end

      error_2015 = nil
      COLUMNS_JULY_2015.each{
        |key, value|
        header_name = row[COLUMNS_JULY_2015.keys.index(key)].value
        unless value.match(header_name)
          puts "#{__LINE__}: #{key} ->  #{COLUMNS_JULY_2015.keys.index(key)} #{value}\nbut was  #{header_name}" if $VERBOSE
          error_2015 = "Packungen.xlslx_has_unexpected_column_#{COLUMNS_JULY_2015.keys.index(key)}_#{key}_#{value.to_s}_but_was_#{header_name}"
          break
        end
      }
      raise "#{error_2015}" if error_2015
    end

    # please keep this constant in sync between (GEM) swissmedic-diff/lib/swissmedic-diff.rb and (GEM) oddb2xml/lib/oddb2xml/extractor.rb
    COLUMNS_JULY_2015 = {
        :iksnr => /Zulassungs-Nummer/i,                  # column-nr: 0
        :seqnr => /Dosis+tärke-nummer/i, # Dosisstärke-nummer
        :name_base => /Präparatebezeichnung/i,
        :company => /Zulassungsinhaberin/i,
        :production_science => /Heilmittelcode/i,
        :index_therapeuticus => /IT-Nummer/i,            # column-nr: 5
        :atc_class => /ATC-Code/i,
        :registration_date => /Erstzulassungs-datum./i,
        :sequence_date => /Zul.datum Dosisstärke/i,
        :expiry_date => /Gültigkeitsdauer der Zulassung/i,
        :ikscd => /Packungscode/i,                 # column-nr: 10
        :size => /Packungsgrösse/i,
        :unit => /Einheit/i,
        :ikscat => /Abgabekategorie Packung/i,
        :ikscat_seq => /Abgabekategorie Dosisstärke/i,
        :ikscat_preparation => /Abgabekategorie Präparat/i, # column-nr: 15
        :substances => /Wirkstoff/i,
        :composition => /Zusammensetzung/i,
        :indication_registration => /Anwendungsgebiet Präparat/i,
        :indication_sequence => /Anwendungsgebiet Dosisstärke/i,
        :gen_production => /Gentechnisch hergestellte Wirkstoffe/i, # column-nr 20
        :insulin_category => /Kategorie bei Insulinen/i,
        :drug_index       => /Verz. bei betäubunsmittel-haltigen Präparaten/i,
    }
  end
end
