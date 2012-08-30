#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::DivisibilityPlugin -- oddb.org -- 30.08.2012 -- yasaka@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'csv'
require 'plugin/plugin'
require 'util/persistence'

module ODDB
  class DivisibilityPlugin < Plugin
    def initialize(app)
      super(app)
      @created_div = 0
      @updated_div = 0
      @updated_sequences = []
    end
    def report
      content = [
        "Teilbarkeiten (created): #{@created_div}",
        "Teilbarkeiten (updated): #{@updated_div}",
        "Updated Sequences: #{@updated_sequences.length}",
      ].join("\n")
      content << "\n\n"
      urls = []
      @updated_sequences.each do |seq|
        url = "http://#{SERVER_NAME}/de/gcc/drug/reg/#{seq.iksnr}/seq/#{seq.seqnr}"
        urls << url
      end
      content << urls.join("\n")
      content
    end
    def update_from_csv(path)
      if File.exists?(path) and File.extname(path) == '.csv'
        @updated_divisibilities = []
        @updated_sequences      = []
        CSV.foreach(path, :encoding => 'UTF-8', :col_sep => ';') do |row|
          iksnr = ikscd = nil
          if ean = row[0] and /^\d{13}/u =~ ean
            iksnr = ean[4..8]
            ikscd = ean[9..11]
          end
          if reg = @app.registration(iksnr) and
             pac = reg.package(ikscd) and
             seq = pac.sequence
            values = {}
            # row[0] ean, row[1] pharmacode and row[2] name
            values.store(:divisable,   row[3]) if row[3]
            values.store(:dissolvable, row[4]) if row[4]
            values.store(:crushable,   row[5]) if row[5]
            values.store(:openable,    row[6]) if row[6]
            values.store(:notes,       row[7]) if row[7]
            values.store(:source,      row[8]) if row[8]
            pointer = if div = seq.division
                        @updated_div += 1
                        div.pointer
                      else
                        @created_div += 1
                        Persistence::Pointer.new(:division).creator
                      end
            div = @app.update(pointer, values, :divisibility)
            @app.update(seq.pointer, {:division => div}, :divisibility)
            @updated_sequences << seq
          end
        end
        @updated_sequences
      else
        puts "Error: No such CSV File #{path}"
      end
    end
  end
end
