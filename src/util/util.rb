# encoding: utf-8
require 'swissmedic-diff'

module ODDB

  module Util
    # please keep this constant in sync between (GEM) swissmedic-diff/lib/swissmedic-diff.rb and (GEM) oddb2xml/lib/oddb2xml/extractor.rb
    def Util.check_column_indices(sheet)
      if  /Zugelassene Verpackungen/i.match(sheet[2][0].value)
        row = sheet[3] # Headers are found at row 3
      elsif /Zulassungs-nummer/i.match(sheet[4][0].value)
        row = sheet[4] # Headers are found at row 4
      elsif /Zulassungs-nummer/i.match(sheet[5][0].value)
        row = sheet[5] # Headers are found at row 4
      else
        raise "Did not find Zugelassene Verpackunge in row 3, 4 or 5"
      end

      error_2015 = nil
      COLUMNS_FEBRUARY_2019.each{
        |key, value|
        header_name = row[COLUMNS_FEBRUARY_2019.keys.index(key)].value
        unless value.match(header_name)
          puts "#{__LINE__}: #{key} ->  #{COLUMNS_FEBRUARY_2019.keys.index(key)} #{value}\nbut was  #{header_name}" if $VERBOSE
          error_2015 = "Packungen.xlslx_has_unexpected_column_#{COLUMNS_FEBRUARY_2019.keys.index(key)}_#{key}_#{value.to_s}_but_was_#{header_name}"
          break
        end
      }
      raise "#{error_2015}" if error_2015
    end
    COLUMNS_FEBRUARY_2019 = SwissmedicDiff::Diff::COLUMNS_FEBRUARY_2019
  end
end
