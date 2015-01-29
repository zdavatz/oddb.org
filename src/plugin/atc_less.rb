#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Atc_lessPlugin -- oddb.org -- 11.03.2013 -- yasaka@ywesee.com
# ODDB::Atc_lessPlugin -- oddb.org -- 27.12.2011 -- mhatakeyama@ywesee.com
# ODDB::Atc_lessPlugin -- oddb.org -- 18.03.2008 -- hwyss@ywesee.com

require 'fileutils'
require 'mechanize'
require 'ostruct'
require 'plugin/plugin'
require 'util/persistence'
require 'util/today'
require 'rubyXL'
require 'spreadsheet'
require 'util/logfile'
require 'plugin/xml_definitions'

# Some monkey patching needed to avoid an error
module RubyXL
  class Row < OOXMLObject
    def first
       cells[0]
    end
  end
end

module ODDB
  class Atc_lessPlugin < Plugin
    Strip_For_Sax_Machine = '<?xml version="1.0" encoding="utf-8"?>'+"\n"
    def initialize(app=nil, archive=ARCHIVE_PATH)
      super app
      debug_msg "initialize update_atc_codes "
      @packungen_xlsx =  File.join archive, 'xls', 'Packungen-latest.xlsx'
      @swissindex_xml =  File.join archive, 'xml', 'XMLSwissindexPharma-DE-latest.xml'
      @update_time = 0 # minute
      @missing_registrations = []
      @missing_sequences = []
      @atc_code_was_nil  = []
      @atc_code_corrected = []
      @nr_correct_atc_codes = 0
      @obsolete = []
      @swissindex_to_atc_code = {}
      @no_such_atc_code_in_database = []
    end
    def debug_msg(msg)
      return
      if defined?(MiniTest) then $stdout.puts Time.now.to_s + ': ' + msg; $stdout.flush; return end
      if not defined?(@checkLog) or not @checkLog
        name = LogFile.filename('oddb/debug/', Time.now)
        FileUtils.makedirs(File.dirname(name))
        @checkLog = File.open(name, 'a+')
      end
      @checkLog.puts("#{Time.now}: #{msg}")
      @checkLog.flush
    end

    # method correct_code from gem oddb2xml lib/oddb2xml/extractor.rb
    def correct_code(pharmacode, length=7)
      if pharmacode.length != length # restore zero at the beginnig
        ("%0#{length}i" % pharmacode.to_i)
      else
        pharmacode
      end
    end
    # method parse_swissindex_xml from gem oddb2xml lib/oddb2xml/extractor.rb
    def parse_swissindex_xml # See als extractor.rb in oddb2xml
      debug_msg "update_atc_codes: parse_swissindex_xml #{@swissindex_xml}"
      data = {}
      result = PharmaEntry.parse(IO.read(@swissindex_xml).sub(Strip_For_Sax_Machine, ''), :lazy => true)
      items = result.PHARMA.ITEM
      items.each do |pac|
        if gtin = pac.GTIN
          no8 = gtin[4..11]
          atc_code = pac.ATC ? pac.ATC.to_s : ''
          # debug_msg  "update_atc_codes: parse_swissindex_xml gtin #{gtin} => #{no8} code #{atc_code}"
          @swissindex_to_atc_code[no8] = atc_code
        else
          debug_msg "update_atc_codes: parse_swissindex_xml skip item #{item} as not gtin given"
        end
      end
    end

    def update_atc_codes
      debug_msg "update_atc_codes: Starting"
      [ @packungen_xlsx, @swissindex_xml].each {
        |file|
        unless File.exists?(file)
          msg  = "Could not find #{File.expand_path(file)}"
          debug_msg(msg)
          $stdout.puts msg
          return "Could not find #{File.basename(file)}"
        end
      }
      start_time = Time.new
      idx = 0
      parse_swissindex_xml
      workbook = RubyXL::Parser.parse(@packungen_xlsx)
      saved_reg_seq = nil
      row_nr = 0
      workbook.worksheets[0].each do |row|
        row_nr += 1
        next unless row.cells[0] and row.cells[0].value and row.cells[0].value.to_i > 0
        iksnr               = "%05i" % row.cells[0].value.to_i
        seqnr               = "%02d" % row.cells[1].value.to_i
        atc_code_swissmedic = row.cells[5] ? row.cells[5].value : nil
        reg_seq = "#{iksnr}/#{seqnr}"
        next if saved_reg_seq.eql?(reg_seq)
        no8 = sprintf('%05d',row.cells[0].value.to_i) + sprintf('%03d',row.cells[10].value.to_i)
        atc_code_swissindex = @swissindex_to_atc_code[no8]
        good_atc_code = atc_code_swissmedic
        good_atc_code ||= atc_code_swissindex
        debug_msg "#{__FILE__}: #{__LINE__}: row #{row_nr} reg #{iksnr}/#{seqnr} no8 #{no8} atc_code swissmedic #{atc_code_swissmedic} swissindex #{atc_code_swissindex} good #{good_atc_code}"
        next unless good_atc_code
        saved_reg_seq = reg_seq.clone
        registration = @app.registration(iksnr)
        unless registration
          medical_type = row.cells[6] ? row.cells[6].value : ''
          next if medical_type and /Tierarzneimittel/i.match(medical_type)
          @missing_registrations << iksnr
          debug_msg "#{__FILE__}: #{__LINE__}: skipping non existent registration #{iksnr} #{medical_type}"
        else
          sequence = registration.sequence(seqnr)
          if sequence == nil
            @missing_sequences << saved_reg_seq
            debug_msg "#{__FILE__}: #{__LINE__}: skipping non existent sequence #{seqnr} for iksnr #{iksnr} atc is #{atc_code_swissmedic}"
          elsif sequence.atc_class == nil
            @atc_code_was_nil << saved_reg_seq
            debug_msg "#{__FILE__}: #{__LINE__}: update_atc_code iksnr #{iksnr} seqnr #{seqnr} sequence.atc_class is nil. setting it to #{good_atc_code}"
            idx += 1
            sequence.atc_class=@app.atc_class(good_atc_code)
            sequence.odba_isolated_store
          else
            atc_code_in_db = @app.atc_class(good_atc_code)
            unless atc_code_in_db
              @no_such_atc_code_in_database << "#{saved_reg_seq} ATC #{good_atc_code}"
              debug_msg "#{__FILE__}: #{__LINE__}: atc_code update iksnr #{iksnr}/#{seqnr}. No such ATC-code #{good_atc_code} in database"
              next
            end
            atc_code_sequence   = sequence.atc_class.code
            if good_atc_code == atc_code_sequence
              debug_msg "#{__FILE__}: #{__LINE__}: #{iksnr}/#{seqnr} good_atc_code #{good_atc_code} correct"
              @nr_correct_atc_codes += 1
            else
              @atc_code_corrected << "#{saved_reg_seq} #{atc_code_sequence} -> #{good_atc_code}"
              idx += 1
              debug_msg "#{__FILE__}: #{__LINE__}: atc_code update nr #{idx} for iksnr #{iksnr}/#{seqnr} #{atc_code_sequence} -> #{good_atc_code}"
              sequence.atc_class=@app.atc_class(good_atc_code)
              sequence.odba_isolated_store
            end
          end
        end
      end
      # debug_msg "#{__FILE__}: #{__LINE__}: Checking for obsolete sequences '00'"
      @app.registrations.values.each{
        |registration|
          nr_sequences = registration.sequences.size
          seq_00 = registration.sequence('00')
          # debug_msg "#{__FILE__}: #{__LINE__}: IKSNR #{registration.iksnr} testing for sequence '00' #{seq_00.class} (#{nr_sequences} sequences #{registration.sequences.keys})"
          next unless seq_00
          debug_msg "#{__FILE__}: #{__LINE__}: IKSNR #{registration.iksnr} has sequence '00' (#{nr_sequences} sequences )"
          if nr_sequences > 1
            registration.delete_sequence('00')
            @obsolete << registration.iksnr
            # debug_msg "#{__FILE__}: #{__LINE__}: IKSNR #{registration.iksnr} deleted obsolete sequence '00'"
          end
      }
      # debug_msg "#{__FILE__}: #{__LINE__}: Removed #{@obsolete} obsolete sequences '00'"
      end_time = Time.now - start_time
      @update_time = (end_time / 60.0).to_i
      debug_msg("update_atc_codes Done with #{@packungen_xlsx}")
      true
    end
    def report
      atcless = @app.atcless_sequences.collect{ |x| "#{x.iksnr} #{x.seqnr}" }
      join_string = "\n  "
      lines = [
        "ODDB::Atc_lessPlugin - Report #{@@today.strftime('%d.%m.%Y')}",
        "Total time to update: #{"%.2f" % @update_time} [m]",
        "Total number of sequences with a correct ATC-code: #{@nr_correct_atc_codes}",
        "Total Sequences without ATC-Class: #{atcless.size}",
        atcless,
      ]
      if @missing_registrations.empty? # no expiration date
        lines << "Swissmedic: All registrations present"
      else
        lines << "Skipped #{@missing_registrations.size} registrations#{join_string}#{@missing_registrations.join(join_string)}"
      end

      if @missing_sequences.empty? # no expiration date
        lines << "Swissmedic: All sequences present"
      else
        lines << "Skipped #{@missing_sequences.size} sequences#{join_string}#{@missing_sequences.join(join_string)}"
      end

      if @atc_code_was_nil.empty? # no expiration date
        lines << "No empty ATC-codes found"
      else
        lines << "Replaced #{@atc_code_was_nil.size} empty ATC-code in#{join_string}#{@atc_code_was_nil.join(join_string)}"
      end

      if @atc_code_corrected.empty? # no expiration date
        lines << "All found ATC-codes were correct"
      else
        lines << "Corrected #{@atc_code_corrected.size} ATC-code in sequences#{join_string}#{@atc_code_corrected.join(join_string)}"
      end

      if @no_such_atc_code_in_database.size == 0
        lines << "All ATC codes present in database"
      else
        lines << "#{@no_such_atc_code_in_database.size} ATC codes absent in database#{join_string}#{@no_such_atc_code_in_database.join(join_string)}"
      end

      if @obsolete.size == 0
        lines << "No obsolete sequence '00' found"
      else
        lines << "Deleted #{@obsolete.size} sequences '00' in registrations#{join_string}#{@obsolete.join(join_string)}"
      end
      lines.flatten.join("\n")
    end
  end
end
