#!/usr/bin/env ruby
# encoding: utf-8

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
    DebugImport           = false
    Personen_Candidates   = File.expand_path(File.join(__FILE__, '../../../data/xls/Personen_20*.xlsx'))
    Personen_YAML         = File.expand_path(File.join(__FILE__, "../../../data/txt/doctors_#{Time.now.strftime('%Y.%m.%d-%H%M')}.yaml"))
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
        $stdout.puts "#{Time.now}:  MedregDoctorPlugin #{msg}" # unless defined?(MiniTest)
        $stdout.flush
        LogFile.append('oddb/debug', " MedregDoctorPlugin #{msg}", Time.now)
      end

      def save_for_log(msg)
        log(msg)
        withTimeStamp = "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}: #{msg}" unless defined?(MiniTest)
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
        @skip_to_doctor  = nil
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
        @agent = Mechanize.new
        @agent.user_agent = 'Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101 Firefox/31.0 Iceweasel/31.1.0'
        @agent.redirect_ok         = :all
        @agent.follow_meta_refresh_self = true
        @agent.follow_meta_refresh = :everwhere
        @agent.redirection_limit   = 55
        @agent.follow_meta_refresh = true
        @agent.ignore_bad_chunking = true
        @agent.log = Logger.new    Mechanize_Log
        @agent
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
        doc_hash[:exam] =  doc.xpath("//tr")[idx_beruf+1].text.strip.split(/\r\n|\n/)[1].to_i
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

      def get_one_doctor(r_loop, gln)
        maxSeconds = defined?(Minitest) ? 3600 : 120
        r_loop.try_run(gln, maxSeconds) do # increase timeout from default of 10 seconds. Measured 46 seconds for the first gln
          if @@all_doctors[gln.to_s]
            log "ERROR: Skip search GLN #{gln} as already found"
            next
          end
          info = @info_to_gln[gln.to_s]
          unless info
            log "ERROR: could not find info for GLN #{gln}"
            # require 'pry'; binding.pry
            next
          end
          url = MedRegOmURL +  "de/Suche/Detail/?gln=#{gln}&vorname=#{info.first_name.gsub(/ /, '+')}&name=#{info.family_name.gsub(/ /, '+')}"
          page_1 = @agent.get(url)
          data_2 = [
            ['Name', info.family_name],
            ['Vorname', info.first_name],
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
            ['Name', info.family_name],
            ['Vorname', info.first_name],
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
          File.open(File.join(ODDB::LogFile::LOG_ROOT, "#{gln}.html"), 'w+') { |f| f.write page_5.content } if DebugImport
          doc_hash = parse_details( Nokogiri::HTML(page_5.content), gln, info)
          store_doctor(doc_hash)
          @@all_doctors[gln.to_s] = doc_hash
        end
      end
      def get_detail_to_glns(glns)
        max_retries = 100
        @idx = 0
        r_loop = ResilientLoop.new(File.basename(__FILE__, '.rb'))
        @skip_to_doctor ||= r_loop.state_id
        log "get_detail_to_glns #{glns.size}. first 10 are #{glns[0..9]} state_id is #{r_loop.state_id.inspect}" if DebugImport
        glns.each { |gln|
          if r_loop.must_skip?(gln.to_s)
            log "Skipping #{gln.inspect}. Waiting for #{r_loop.state_id.inspect}" if DebugImport
            @doctors_skipped += 1
            next
          end
          @idx += 1
          nr_tries = 0
          while nr_tries < max_retries
            begin
              log "Searching for doctor with GLN #{gln}. Skipped #{@doctors_skipped}, created #{@doctors_created} updated #{@doctors_updated} of #{glns.size}).#{nr_tries > 0 ? ' nr_tries is ' + nr_tries.to_s : ''}"
              get_one_doctor(r_loop, gln)
              break
            rescue Mechanize::ResponseCodeError, Timeout::Error => e
                  raise e if defined?(MiniTest)
              nr_tries += 1
              log "rescue Mechanize::ResponseCodeError #{gln.inspect}. nr_tries #{nr_tries}"
              sleep(10 * 60) # wait 10 minutes till medreg server is back again
            rescue StandardError => e
                  raise e if defined?(MiniTest)
              nr_tries += 1
              log "rescue Mechanize::ResponseCodeError #{gln.inspect}. nr_tries #{nr_tries} error was e #{e}"
              sleep(10 * 60) # wait 10 minutes till medreg server is back again
            end
          end
          raise "Max retries #{nr_tries} for #{gln.to_s} reached. Aborting import" if nr_tries == max_retries
          if (@doctors_created + @doctors_updated) % 100 == 99
            log "Start saving @app.doctors.odba_store #{gln} after #{@doctors_created} created #{@doctors_updated} updated"
            @app.doctors.odba_store
            log "Finished @app.doctors.odba_store"
          end
        }
        r_loop.finished
      ensure
        log "Start saving @app.doctors.odba_store"
        @app.doctors.odba_store
        log "Finished @app.doctors.odba_store"
      end
      def get_detail_info(info, doc)
        text = doc.xpath('//div').text
        m = text.match(/Nationalität:\s*([Ö\w+])[^:]+:\s+(\d+)/) # Special case Österreich
        unless m and m[2] == info.gln.to_s
          File.open(File.join(ODDB::LogFile::LOG_ROOT, 'doc_div.txt'), 'w+') { |f| f.write text }
          log "ERROR: Id in text does not match #{info.gln  } match was #{m.inspect}"
          return []
        end
        addresses = []
        nrAdresses = doc.xpath('//ol/li/div').size
        0.upto(nrAdresses-1).each {
          |idx|
          lines = []
          doc.xpath('//ol/li/div')[idx].children.each{ |x| lines << x.text }
          address = Address2.new
          address.fon = []
          address.fax = []
          address.type = 'at_praxis'
          address.additional_lines = []
          address.canton = info.authority
          address.name = lines[0]
          lines[1].sub!(/^[A-Z]\. /, '')
          lines[1..-1].each { |line|
                    if /^Telefon: /.match(line)
                      address.fon << line.split('Telefon: ')[1].gsub(/\-/, ' ')
                      next
                    elsif /^Fax: /.match(line)
                      address.fax << line.split('Fax: ')[1].gsub(/\-/, ' ')
                      next
                    else
                      next if line.length == 0
                      if m = line.match(/(|\w\w[-\. ])(\d{4})\s+(\S+)/)
                        address.location = line
                      else
                        address.additional_lines << line
                      end
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
        save_for_log "get_latest_file target #{target} #{File.exist?(target)} and #{latest} #{File.exist?(latest)} from URL #{MedRegPerson_XLS_URL}"
        if File.exist?(target) and not File.exist?(latest)
          FileUtils.cp(target, latest, {:verbose => true})
          return needs_update,latest
        end
        @download = nil
        begin
          file = agent.get(MedRegPerson_XLS_URL)
          @download = file.body
        rescue Net::HTTP::Persistent::Error, Timeout::Error => e
          log "Catched error #{e}"
          search_name = File.join @archive, Time.now.strftime("doctors_%Y*.xlsx")
          candidates = Dir.glob(search_name)
          if candidates.size == 0
            save_for_log "getting file from MedRegPerson_XLS_URL failed. Could not find any prior downloads via #{search_name}"
            raise e
          end
          best = candidates.max_by {|f| File.mtime(f)}
          save_for_log "getting file from MedRegPerson_XLS_URL failed. Using #{best} #{File.mtime(best)} #{File.size(best)} bytes"
          @download = IO.read(best)
        end
        if(!File.exist?(latest) or @download.size != File.size(latest))
          File.open(latest, 'w+') { |f| f.write @download }
          File.open(target, 'w+') { |f| f.write @download }
          save_for_log "saved get_latest_file (#{@download ? @download.size : '0'} bytes) as #{target} and #{latest}"
        else
          save_for_log "latest_file #{target} #{File.size(target)} bytes is uptodate"
          needs_update = false
        end
        @download = nil # release it
        return needs_update,latest
      end
      def report
        report = "Doctors update \n\n"
        report << "Number of doctors: " << @app.doctors.size.to_s << "\n"
        report << "Skipped doctors: #{@doctors_skipped}#{@skip_to_doctor ? '. Waited for ' + @skip_to_doctor.to_s : ''}" << "\n"
        report << "New doctors: "       << @doctors_created.to_s << "\n"
        report << "Updated doctors: "   << @doctors_updated.to_s << "\n"
        report << "Deleted doctors: "   << @doctors_deleted.to_s << "\n"
        report
      end
      def store_doctor(hash)
        return unless hash
        action = nil
        pointer = nil
        if(doctor = @app.doctor_by_gln(hash[:ean13]))
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
          :exam,
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
          if(value = hash[key])
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
            doc_hash.store(key, value)
          end

        }
        @app.update(pointer, doc_hash)
        doc_copy = @app.doctor_by_gln(hash[:ean13])
        return unless doc_copy
        # doc_copy.exam = hash[:exam]
        # I don't understand exactly why updating the capabilities and specialities fails
        # but this workaround works
        doc_copy.capabilities = hash[:capabilities]
        doc_copy.specialities = hash[:specialities]
        doc_copy.odba_isolated_store

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

      # just for debugging when running unit tests
      def MedregDoctorPlugin.all_doctors
        @@all_doctors
      end
  private
      Match_qualification_with_austria = /(.*)\s+(\d+)\s+([Ö\w]+)/
      def string_to_qualification(line, gln)
        return nil if line.match(/Weiterbildungstitel|Weitere Qualifikationen|Beruf.*Jahr.*Land/im)
        m = line.match(Match_qualification_with_austria)
        if m
          infos = m[1..3].join(',').gsub("\r","").gsub(/\s\s+/, ' ').strip.split(/ ,|,/)
          # infos[1] = infos[1].to_i # transform year into an integer
          return infos.join(', ')
        else
          log "PROBLEM: could not find speciality for GLN #{gln} in line '#{line}'"
        end
        nil
      end
    end
  end
end
