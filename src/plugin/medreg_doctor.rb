#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'plugin/plugin'
require 'model/address'
require 'util/oddbconfig'
require 'util/persistence'
require 'util/logfile'
require 'util/resilient_loop'
require 'logger'
require 'psych' if RUBY_VERSION.match(/^1\.9/)
require "yaml"
require 'timeout'

Medreg = ODDB # medreg_doctor.yaml has a different module name

module ODDB
  module Doctors
    class MedregDoctorPlugin < Plugin
      RECIPIENTS = []
      def log(msg)
        # $stdout.puts "#{Time.now}:  MedregDoctorPlugin #{msg}" # unless defined?(MiniTest)
        $stdout.flush
        LogFile.append('oddb/debug', " MedregDoctorPlugin #{msg}", Time.now)
      end

      def save_for_log(msg)
        log(msg)
        withTimeStamp = "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}: #{msg}" unless defined?(MiniTest)
        @@logInfo << withTimeStamp
      end
      def initialize(app=nil)
        @latest_file_name = File.join ARCHIVE_PATH, "medreg_doctors.yaml"
        @info_to_gln    = {}
        @@logInfo       = []
        super
        @doctors_created = 0
        @doctors_updated = 0
        @doctors_unchanged = 0
        @@all_doctors    = {}
        @to_add          = {}
      end
      def update_item(gln, item)
        action = nil
        pointer = nil
        doc_hash = {}
        doctor = nil
        if (doctor = @app.doctor_by_gln(gln))
          pointer = doctor.pointer
          @doctors_updated += 1
          action = 'update'
        else
          @doctors_created += 1
          ptr     = Persistence::Pointer.new(:doctor)
          pointer = ptr.creator
          action = 'create'
        end
        extract = [
          :ean13,
          :email,
          :firstname,
          :language,
          :name,
          :praxis,
          :salutation,
          :specialities,
          :capabilities,
          :title,
          :addresses,
          :may_dispense_narcotics,
          :may_sell_drugs,
          :remark_sell_drugs,
        ]
        doc_hash = {}
        extract.each { |key|
          must_change = true
          value = item[key]
          if value
            case key
            when :praxis
              value = (value == 'Ja')
            when :specialities, :capabilities
              if(value.is_a?(String))
                value = [value]
              elsif(value.is_a?(Array))
                value = value
              end
            end
          end
          if doctor
            cmd = "@value_in_db = doctor.#{key.to_s}"
            eval(cmd)
            must_change = (value != @value_in_db)
          end
          doc_hash.store(key, value) if value and must_change
        }
        if doc_hash.size == 0
          @doctors_unchanged  += 1
          @doctors_updated    -= 1
        end
        log "store_doctor updated #{gln} oid #{doctor ? doctor.oid : 'nil'}  #{action} in database. pointer #{pointer.inspect} doc_hash #{doc_hash}"
        return @app.update(pointer, doc_hash)
        doc_copy = @app.doctor_by_gln(gln)
        return unless doc_copy
        # I don't understand exactly why updating the capabilities and specialities fails
        # but this workaround works
        doc_copy.capabilities = hash[:capabilities]
        doc_copy.specialities = hash[:specialities]
        doc_copy.odba_isolated_store
      end
      def update
        @latest = get_latest_file
        return unless @latest
        @to_add = YAML.load_file(@latest )
        save_for_log "#{@latest } has #{@to_add.size} items to add"
        @to_add.each{ |key, item| update_item(key.to_i, item)  }
        @app.doctors.odba_store
        FileUtils.mv(@latest , @latest.sub('.yaml', ".imported_#{Date.today.strftime('%Y%M%d')}"), { :verbose => false })
        return @doctors_created, @doctors_updated, @doctors_unchanged
      end
      def parse_details(doc, gln, info)
        unless doc.xpath("//tr") and doc.xpath("//tr").size > 3
          log "ERROR: Could not find a table with info for #{gln}"
          return nil
        end
        doc_hash = Hash.new
        doc_hash[:ean13]                  = gln.to_s.clone
        doc_hash[:name]                   = info.family_name
        doc_hash[:firstname]              = info.first_name
        doc_hash[:may_dispense_narcotics] = (info.may_dispense_narcotics && info.may_dispense_narcotics.match(/ja/i)) ? true : false
        doc_hash[:may_sell_drugs]         = (info.may_sell_drugs && info.may_sell_drugs.match(/ja/i)) ? true : false
        doc_hash[:remark_sell_drugs]      = info.remark_sell_drugs
        idx_beruf  = nil; 0.upto(doc.xpath("//tr").size) { |j| if doc.xpath("//tr")[j].text.match(/^\s*Beruf\r\n/)               then idx_beruf  = j; break; end }
        idx_titel  = nil; 0.upto(doc.xpath("//tr").size) { |j| if doc.xpath("//tr")[j].text.match(/^\s*Weiterbildungstitel/)     then idx_titel  = j; break; end }
        idx_privat = nil; 0.upto(doc.xpath("//tr").size) { |j| if doc.xpath("//tr")[j].text.match(/^\s*Weitere Qualifikationen/) then idx_privat = j; break; end }
        # doc_hash[:exam] =  doc.xpath("//tr")[idx_beruf+1].text.strip.split(/\r\n|\n/)[1].to_i
        # Jahr des Staatsexamen wird nicht angezeigt!!
        specialities = []
        (idx_titel+1).upto(idx_privat-1).each{
          |j|
            line = doc.xpath("//tr")[j].text ;
            unless line.match(/Keine Angaben vorhanden/)
              line = line.gsub("\r\n", '')
              specialities << string_to_qualification(line, gln)
            end
          }
        doc_hash[:specialities] = specialities
        capabilities = []
        (idx_privat+1).upto(99).each{
          |j|
            next unless doc.xpath("//tr")[j]
            line = doc.xpath("//tr")[j].text ;
            unless line.match(/Keine Angaben vorhanden/)
              capabilities << string_to_qualification(line, gln)
            end
          }
        doc_hash[:capabilities] = capabilities
        addresses = get_detail_info(info, doc)
        doc_hash[:addresses] = addresses
        doc_hash
      end
      def get_latest_file
        file = @latest_file_name
        save_for_log "get_latest_file #{file } #{File.exist?(file )}"
        return file if File.exist?(file )
        false
      end
      def report
        if @latest
          report = "Doctors update from #{@latest_file_name} \n\n"
          report << "Number of doctors in database: " << @app.doctors.size.to_s << "\n"
          report << "Number of doctors in import: " << @to_add.size.to_s << "\n"
          report << "New doctors: " << @doctors_created.to_s << "\n"
          report << "Updated doctors: " << @doctors_updated.to_s << "\n"
          report << "Unchanged doctors: " << @doctors_unchanged.to_s << "\n"
        else
          report = "Skipped import as no latest file #{@latest_file_name} found\n"
        end
        report
      end
    end
  end
end
