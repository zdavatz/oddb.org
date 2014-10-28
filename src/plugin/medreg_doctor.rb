#!/usr/bin/env ruby
# encoding: utf-8
# Doctors -- oddb -- 21.09.2004 -- jlang@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'plugin/plugin'
require 'model/address'
require 'util/oddbconfig'
require 'util/persistence'
require 'util/logfile'
require 'util/resilient_loop'
require 'rubyXL'
require 'mechanize'
require 'logger'
require 'cgi'
require 'psych' if RUBY_VERSION.match(/^1\.9/)
require "yaml"
require 'timeout'

module ODDB
  module Doctors
    Mechanize_Log         = File.join(ODDB::LogFile::LOG_ROOT, File.basename(__FILE__).sub('.rb', '.log'))
    Personen_XLSX         = File.expand_path(File.join(__FILE__, '../../../data/xls/Personen_latest.xlsx'))
    Personen_YAML         = File.expand_path(File.join(__FILE__, "../../../data/txt/doctors_#{Time.now.strftime('%Y.%m.%d')}.yaml"))
    MedRegOmURL           = 'http://www.medregom.admin.ch/'
    MedRegPerson_XLS_URL  = "https://www.medregbm.admin.ch/Publikation/CreateExcelListMedizinalPersons"
    DoctorInfo = Struct.new("DoctorInfo",
                            :gln,
                            :exam,
                            :address,
                            :family_name,
                            :first_name,
                            :addresses,
                            :authority,
                            :diploma,
                            :may_dispense_narcotics,
                            :may_sell_drugs,
                            :remark_sell_drugs,
                           )
#    GLN Person  Name  Vorname PLZ Ort Bewilligungskanton  Land  Diplom  BTM Berechtigung  Bewilligung Selbstdispensation  Bemerkung Selbstdispensation
    COL = {
      :gln                    => 0, # A
      :family_name            => 1, # B
      :first_name             => 2, # C
      :zip_code               => 3, # D
      :place                  => 4, # E
      :authority              => 5, # F
      :country                => 6, # G
      :diploma                => 7, # H
      :may_dispense_narcotics => 8, # I
      :may_sell_drugs         => 9, # J
      :remark_sell_drugs      => 10, # K
    }
    class MedregDoctorPlugin < Plugin
      RECIPIENTS = []
      def log(msg)
        $stdout.puts "#{Time.now}:  MedregDoctorPlugin #{msg}" unless defined?(MiniTest); $stdout.flush
        LogFile.append('oddb/debug', " MedregDoctorPlugin #{msg}", Time.now)
      end

      def save_for_log(msg)
        LogFile.append('oddb/debug', " MedregDoctorPlugin #{msg}", Time.now)
        withTimeStamp = "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}: #{msg}" unless defined?(MiniTest)
        # $stderr.puts withTimeStamp
        @@logInfo << withTimeStamp
      end
      def initialize(app=nil, glns_to_import = [])
        @glns_to_import = glns_to_import.clone
        @glns_to_import.delete_if {|item| item.size == 0}
        @info_to_gln    = {}
        @@logInfo       = []
        FileUtils.rm_f(Personen_YAML) if File.exists?(Personen_YAML)
        @yaml_file      = File.open(Personen_YAML, 'w+')
        super
        @doctors_created = 0
        @doctors_updated = 0
        @doctors_skipped = 0
        @doctors_deleted = 0
        @archive = File.join ARCHIVE_PATH, 'xls'
        @@all_doctors    = {}
        setup_default_agent unless setup_default_agent
      end
      def update
        saved = @glns_to_import.clone
        needs_update,latest = get_latest_file
        return unless needs_update
        save_for_log "parse_xls #{latest} specified GLN glns #{saved.inspect}"
        parse_xls(latest)
        @info_to_gln.keys
        get_detail_to_glns(saved.size > 0 ? saved : @glns_to_import)
        return @doctors_created, @doctors_updated, @doctors_deleted, @doctors_skipped
      ensure
        File.open(Personen_YAML, 'w+') {|f| f.write(@@all_doctors.to_yaml) }       
        save_for_log "Saved #{@@all_doctors.size} doctors in #{Personen_YAML}"
      end

      def setup_default_agent
        unless @agent
          @agent = Mechanize.new
          @agent.user_agent = 'Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101 Firefox/31.0 Iceweasel/31.1.0'
          @agent.redirect_ok         = :all
          @agent.follow_meta_refresh_self = true
          @agent.follow_meta_refresh = :everwhere
          @agent.redirection_limit   = 55
          @agent.follow_meta_refresh = true
          @agent.ignore_bad_chunking = true
          @agent.log = Logger.new    Mechanize_Log
        end
        @agent
      end
      def get_detail_to_glns(glns)
        log "get_detail_to_glns #{glns.size}. first 10 are #{glns[0..9]}"
        idx = 0
        r_loop = ResilientLoop.new(File.basename(__FILE__, '.rb'))
        glns.each { |gln|
          next if r_loop.must_skip?(gln)
          r_loop.try_run(gln) do
            if @@all_doctors[gln.to_s] 
              log "ERROR: Skip search GLN #{gln} (#{idx}/#{glns.size}) as already found"
              next
            end
            idx += 1
            log "Searching for company with GLN #{gln} (#{idx}/#{glns.size})"
            info = @info_to_gln[gln.to_s]
            url = MedRegOmURL +  "de/Suche/Detail/?gln=#{gln}&vorname=#{info[:first_name].gsub(/ /, '+')}&name=#{info[:family_name].gsub(/ /, '+')}"
            page_1 = @agent.get(url)
            data_2 = [
              ['Name', info[:family_name]],
              ['Vorname', info[:first_name]],
              ['Gln', gln.to_s],
              ['AutomatischeSuche', 'True'],
              ]
            page_2 = @agent.post(MedRegOmURL + 'Suche/GetSearchCount', data_2)

            data_3 = [
              ['currentpage', '1'],
              ['pagesize', '10'],
              ['sortfield', ''],
              ['sortorder', 'Ascending'],
              ['pageraction', ''],
              ['filter', ''],
              ]
            page_3 = @agent.post(MedRegOmURL + 'Suche/GetSearchData', data_3)
            data_4 = [
              ['Name', info[:family_name]],
              ['Vorname', info[:first_name]],
              ['Gln', gln.to_s],
              ['AutomatischeSuche', 'True'],
              ['currentpage', '1'],
              ['pagesize', '10'],
              ['sortfield', ''],
              ['sortorder', 'Ascending'],
              ['pageraction', ''],
              ['filter', ''],
              ]
            page_4 = @agent.post(MedRegOmURL + 'Suche/GetSearchData', data_4)
            regExp = /id"\:(\d\d+)/i
            unless page_4.body.match(regExp)
              File.open(File.join(ODDB::LogFile::LOG_ROOT, 'page_4.body'), 'w+') { |f| f.write page_4.body }
              log "ERROR: Could not find an gln #{gln}"
              next
            end
            medregId = page_4.body.match(regExp)[1]
            page_5 = @agent.get(MedRegOmURL + "de/Detail/Detail?pid=#{medregId}")
            File.open(File.join(ODDB::LogFile::LOG_ROOT, 'page_5.html'), 'w+') { |f| f.write page_5.content }
            doc = Nokogiri::HTML(page_5.content)
            unless doc.xpath("//tr") and doc.xpath("//tr").size > 3
              log "ERROR: Could not find a table with info for #{gln}"
              next
            end
            doctor = Hash.new
            doctor[:ean13] =  gln.to_s.clone
            doctor[:name] =  info.family_name
            doctor[:firstname] =  info.first_name
            idx_beruf  = nil; 0.upto(doc.xpath("//tr").size) { |j| if doc.xpath("//tr")[j].text.match(/^\s*Beruf\r\n/)               then idx_beruf  = j; break; end }
            idx_titel  = nil; 0.upto(doc.xpath("//tr").size) { |j| if doc.xpath("//tr")[j].text.match(/^\s*Weiterbildungstitel/)     then idx_titel  = j; break; end }
            idx_privat = nil; 0.upto(doc.xpath("//tr").size) { |j| if doc.xpath("//tr")[j].text.match(/^\s*Weitere Qualifikationen/) then idx_privat = j; break; end }
            doctor[:exam] =  doc.xpath("//tr")[idx_beruf+1].text.split("\r\n")[1].gsub(/\s/,'')
            specialities = []
            (idx_titel+1).upto(idx_privat-1).each{
              |j|
                line = doc.xpath("//tr")[j].text ; 
                unless line.match(/Keine Angaben vorhanden/)
                  specialities << line.match(/(.*)\s+(\d+)\s+(\w+)/)[1..3].join(',').gsub("\r","")
                end
              }
            doctor[:specialities] = specialities
            addresses = get_detail_info(info, doc)
            next if addresses.size == 0
            doctor[:addresses] = addresses
            log doctor
            store_doctor(doctor)
            @@all_doctors[gln.to_s] = doctor
          end
        }
        r_loop.finished
      end
      def get_detail_info(info, doc)
        text = doc.xpath('//div').text
        m = text.match(/Nationalität:\s*([Ö\w+])[^:]+:\s+(\d+)/) # Special case Österreich
        unless m and m[2] == info[:gln].to_s
          File.open(File.join(ODDB::LogFile::LOG_ROOT, 'doc_div.txt'), 'w+') { |f| f.write text }
          log "ERROR: Id in text does not match #{info[:gln]} match was #{m.inspect}"
          return []
        end
        addresses = []
        nrAdresses = doc.xpath('//ol/li/div').size
        0.upto(nrAdresses-1).each {
          |idx|
          lines = []
          doc.xpath('//ol/li/div')[idx].children.each{ |x| lines << x.text }
          address = Hash.new
          address[:lines] = []
          address[:canton] = info.authority
          lines[1].sub!(/^[A-Z]\. /, '')
          lines[1..-1].each { |line|
                    if /^Telefon: /.match(line)
                      address[:fon] = line.split('Telefon: ')[1]
                      next
                    elsif /^Fax: /.match(line)
                      address[:fax] = line.split('Fax: ')[1]
                      next
                    else
                      address[:lines] << line if line.length > 0
                    end
                      }
          addresses << address                                 
        }
        addresses
      end
      def get_latest_file       
        agent = Mechanize.new
        latest = File.join @archive, "doctors_latest.xlsx"
        target = File.join @archive, Time.now.strftime("doctors_%Y.%m.%d.xlsx")
        needs_update = true
        if File.exist?(target) and not File.exist?(latest)
          FileUtils.cp(target, latest, {:verbose => true})
          return needs_update,latest
        end
        file = agent.get(MedRegPerson_XLS_URL)
        download = file.body
        if(!File.exist?(latest) or download.size != File.size(latest))
          File.open(latest, 'w+') { |f| f.write download }
          File.open(target, 'w+') { |f| f.write download }
          save_for_log "saved get_latest_file (#{file.body.size} bytes) as #{target} and #{latest}"
        else
          save_for_log "latest_file #{target} #{file.body.size} bytes is uptodate"
          needs_update = false
        end
        return needs_update,latest
      end
      def report
        report = "Doctors update \n\n"
        report << "Number of doctors: " << @app.doctors.size.to_s << "\n"
        report << "New doctors: "       << @doctors_created.to_s << "\n"
        report << "Updated doctors: "   << @doctors_updated.to_s << "\n"
        report << "Deleted doctors: "   << @doctors_deleted.to_s << "\n"
        report
      end
      def store_doctor(hash)
        action = nil
        pointer = nil
        if(doc = @app.doctor_by_gln(hash[:ean13]))
          pointer = doc.pointer
          @doctors_updated += 1
          action = 'update'
        else
          @doctors_created += 1
          ptr = Persistence::Pointer.new(:doctor)
          pointer = ptr.creator
          action = 'create'
        end
        extract = [
          :ean13,
          :exam,
          :email,
          :firstname,
          :language,
          :name,
          :praxis,
          :salutation,
          :specialities,
          :title,
        ]
        doc_hash = {}
        extract.each { |key|
          if(value = hash[key])
            case key
            when :praxis
              value = (value == 'Ja')
            when :specialities
              if(value.is_a?(String))
                value = [value]
              elsif(value.is_a?(Array))
                value = value
              end
            end
            doc_hash.store(key, value)
          end
         
        }
        @app.update(pointer, doc_hash)
        log "store_doctor #{hash[:ean13]} #{action} in database"
      end
      def parse_xls(path)
        log "parsing #{path}"
        workbook = RubyXL::Parser.parse(path)
        positions = []
        rows = 0
        workbook[0].each do |row|
          next unless row and row[COL[:gln]]
          rows += 1
          if rows > 1
            info = DoctorInfo.new
            [:gln, :family_name, :first_name, :authority, :diploma, :may_dispense_narcotics, :may_sell_drugs,:remark_sell_drugs].each {
              |field|
              cmd = "info.#{field} = row[COL[#{field.inspect}]] ? row[COL[#{field.inspect}]].value : nil"
              eval(cmd)
            }
            @info_to_gln[row[COL[:gln]].value] = info
          end
        end
        @glns_to_import = @info_to_gln.keys.sort.uniq
      end
    end
  end
end
