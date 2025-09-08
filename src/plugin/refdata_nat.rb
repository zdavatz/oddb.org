#!/usr/bin/env ruby
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "plugin/plugin"
require "model/address"
require "model/ba_type"
require "util/oddbconfig"
require "util/persistence"
require "util/logfile"
require "util/resilient_loop"
require "open-uri"
require "csv"
require "mechanize"
require "logger"
require "cgi"
require "savon"
require "psych" if RUBY_VERSION.match?(/^1\.9/)
require "yaml"
require "ox"
require "plugin/refdata_jur"

module ODDB
  module Doctors
    PersonenURL = "https://www.medreg.admin.ch/MedReg/PersonenSuche.aspx"
    RegExpPersonDetail = /\/Personen\/Details\//

    def self.download_doctors_xml
      xml = nil
      begin
        file2save = File.join(ODDB::WORK_DIR, "xml", "refdata_nat.xml")
        FileUtils.rm_f(file2save, verbose: false)
        @client = Savon.client(wsdl: "https://refdatabase.refdata.ch/Service/Partner.asmx?WSDL")
        # TYPE Search Type
        # PTYPE Partner Type, JUR or NAT
        # Search Term dependant of the search type: DATE -> mutationDate (dd.MM.yyyy), GLN -> Gln, NAME -> Name
        # TERM
        soap = %(<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <DownloadPartnerInput xmlns="http://refdatabase.refdata.ch/">
      <TYPE xmlns="http://refdatabase.refdata.ch/Partner_in">ALL</TYPE>
      <PTYPE xmlns="http://refdatabase.refdata.ch/Partner_in">NAT</PTYPE>
    </DownloadPartnerInput>
  </soap:Body>
</soap:Envelope>)
        response = @client.call(:download, xml: soap)

        if response.success? && (xml = response.to_xml)
          FileUtils.makedirs(File.dirname(file2save))
          File.write(file2save, xml)
          system("xmllint --format --output #{file2save.sub(".xml", "_pretty.xml")} #{file2save}")
        else
          raise Timeout::Error
        end
      rescue Timeout::Error, Errno::ETIMEDOUT
        retrievable? ? retry : raise
      end
      xml
    end

    def self.setup_default_agent
      agent = Mechanize.new
      agent.user_agent = "Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101 Firefox/31.0 Iceweasel/31.1.0"
      agent.redirect_ok = :all
      agent.follow_meta_refresh = true
      agent.follow_meta_refresh = :everwhere
      agent.redirection_limit = 55
      agent.follow_meta_refresh = true
      agent.ignore_bad_chunking = true
      agent
    end
    DebugImport = defined?(Minitest)
    Doctors_XML = File.join(ODDB::WORK_DIR, "xml/refdata_nat_latest.xml")
    Doctors_curr = File.join(ODDB::WORK_DIR, "xml/refdata_nat_#{Time.now.strftime("%Y.%m.%d")}.xml")
    # MedRegURL     = 'http://www.medregom.admin.ch/'
    # role_types are => ["Pharm", "Indus", "Hosp", "DruSto", "SerFirm", "DoctMed", "PubHea", "Whole", "Pharmst", "Inst", "HeaIns", "IntOrg", "HeaEmpl", "NursHom", "ONursOrg", "SWFirm", "EmergServ", "Assoc", "NonHealthCare", "HeaTec", "AccIns", "HeaProd", "SpecPra", "Drugg", "GrpPra", "Dent", "Veter", "Nurse", "Lab", "Chiro", "HeaProv", "Physio", "LabLeader", "Midw", "Psycho", "Naturopath", "NutrAdv", "SocSec", "Spitex", "DentGrpPra", "CompTherapist", "VetGrpPra", "PrivPra", "Ergo", "MedPracAss", "DiabAdv", "SpeeTher", "PharmAss", "MedSecr", "EmergCent"]

    class RefdataNatPlugin < Plugin
      RECIPIENTS = []
      def log(msg)
        $stdout.puts "#{Time.now}:  RefdataNatPlugin #{msg}" # unless defined?(Minitest)
        $stdout.flush
        LogFile.append("oddb/debug", " RefdataNatPlugin #{msg}", Time.now)
      end

      def save_for_log(msg)
        log(msg)
        withTimeStamp = "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}: #{msg}"
        @@logInfo << withTimeStamp
      end

      def initialize(app = nil, glns_to_import = [])
        @glns_to_import = glns_to_import.clone
        @glns_to_import.delete_if { |item| item.size == 0 }
        @info_to_gln = {}
        @@logInfo = []
        super
        @doctors_created = {}
        @doctors_updated = {}
        @doctors_skipped = {}
        @doctors_inactive = {}
        @archive = File.join ODDB::WORK_DIR, "xls"
        @@all_doctors = []
        @agent = Doctors.setup_default_agent
      end

      def update(with_details = false)
        @with_details = with_details
        saved = @glns_to_import.clone
        needs_update, latest = get_latest_file
        return unless needs_update
        save_for_log "parse_xml #{latest} specified GLN ids #{saved.inspect}"
        parse_xml(latest)
        (@glns_to_import.size > 0) ? @glns_to_import : @info_to_gln.keys
        [@doctors_created, @doctors_updated, @doctors_inactive, @doctors_skipped]
      end

      def get_detail_to_gln(gln)
        r_loop = ResilientLoop.new(File.basename(__FILE__, ".rb"))
        nr_tries = 0
        success = false
        failure = "Die Personensuche dauerte zu lange"
        while nr_tries < 3 && !success
          begin
            r_loop.try_run(gln, defined?(Minitest) ? 500 : 5) do
              # log "Searching for doctor with GLN #{gln}. Skipped #{@doctors_skipped}, created #{@doctors_created} updated #{@doctors_updated} of #{@glns_to_import.size}).#{nr_tries > 0 ? ' nr_tries is ' + nr_tries.to_s : ''}"
              page_1 = @agent.get(PersonenURL)
              raise Search_failure if page_1.content.match(failure)
              hash = [
                ["Personsname", ""],
                ["Plz", ""],
                ["Ort", ""],
                ["GlnPerson", gln.to_s],
                ["PersonsCodeId", "0"],
                ["KantonsCodeId", "0"]
              ]
              res_2 = @agent.post(PersonenURL, hash)
              if res_2.link(href: RegExpPersonDetail)
                page_3 = res_2.link(href: RegExpPersonDetail).click
                raise Search_failure if page_3.content.match(failure)
                doctor = parse_details(page_3, gln)
                doctor["GLN"] = gln
                store_doctor(doctor, gln)
              elsif @info_to_gln[gln]
                # Probably a doctor
              else
                log "could not find gln #{gln}"
                @doctors_skipped[gln] = gln
              end
              success = true
            end
          rescue Timeout => e
            nr_tries += max_retries if defined?(Minitest)
            log "rescue #{e} will retry #{max_retries - nr_tries} times"
            nr_tries += 1
            sleep defined?(Minitest) ? 0.01 : 60
          end
        end
      end

      def parse_details(html, gln)
        left = html.at('div[class="colLeft"]').text
        html.at('div[class="colRight"]').text
        html.at('div[class="twoColSpan"]').text
        infos = left.split(/\r\n\s*/)
        unless infos[2].eql?(gln.to_s)
          log "Mismatch between searched gln #{gln} and details #{infos[2]}"
          return nil
        end
        doctor = {}
        doctor[:name] = infos[4]
        idx_plz = infos.index("PLZ \\ Ort")
        infos.index("Bewilligungskanton")
        ODDB::Address2.new
        address = infos[6..idx_plz - 1].join(" ")
        doctor[:plz] = infos[idx_plz + 1]
        doctor[:location] = infos[idx_plz + 2]
        idx_typ = infos.index("Personstyp")
        ba_type = infos[idx_typ + 1]
        doctor[:address] = address
        doctor[:ba_type] = ba_type
        update_address(doctor)
        log doctor
        doctor
      end

      def get_latest_file
        latest = Doctors_XML
        target = Doctors_curr
        needs_update = true
        save_for_log "get_latest_file target #{target} #{File.exist?(target)} and #{latest} #{File.exist?(latest)}"
        if File.exist?(target) and !File.exist?(latest)
          FileUtils.cp(target, latest)
          return needs_update, latest
        end
        download = Doctors.download_doctors_xml
        if !File.exist?(latest) || download.size != File.size(latest)
          File.write(latest, download)
          File.write(target, download)
          save_for_log "saved get_latest_file (#{download.size} bytes) as #{target} and #{latest}"
        else
          save_for_log "latest_file #{target} #{download.size} bytes is uptodate"
          needs_update = false
        end
        [needs_update, latest]
      end

      def report
        return [] if (@doctors_created.size + @doctors_updated.size) == 0
        report = "Update of doctors\n\n"
        report << "Number of doctors: " << @app.doctors.size.to_s << "\n"
        report << "Number of new doctors: " << @doctors_created.size.to_s << "\n"
        report << "Number of updated doctors: " << @doctors_updated.size.to_s << "\n"
        report << "Number of inactive doctors: " << @doctors_inactive.size.to_s << "\n"
        report << "\nDetails of new doctors are: " << @doctors_created.size.to_s << "\n"
        @doctors_created.each { |gln, name| report << "#{gln}: #{name}\n" }
        report << "\nDetails of updated doctors are: " << @doctors_updated.size.to_s << "\n"
        @doctors_updated.each { |gln, name| report << "#{gln}: #{name}\n" }
        report
      end

      def update_address(data)
        addr = Address2.new
        addr.name = [data[:firstname], data[:name]].join(" ")
        addr.address = data[:address]
        # addr.additional_lines = [data[:address] ]
        addr.location = [data[:plz], data[:location]].compact.join(" ")
        if (fon = data[:phone])
          addr.fon = [fon]
        end
        if (fax = data[:fax])
          addr.fax = [fax]
        end
        data[:addresses] = [addr] if data[:address] || !addr.location.empty?
      end

      def store_doctor(data, gln)
        pointer = nil
        if (doctor = @app.doctor_by_gln(gln))
          pointer = doctor.pointer
          action = "update"
        else
          doctor = @app.create_doctor
          pointer = doctor.pointer
          action = "create"
        end
        changes = {}
        [:name, :firstname, :language].each do |field|
          eval("doctor.#{field} != data['#{field}']")
          orig = eval("doctor.#{field}").to_s.encode("utf-8", invalid: :replace, undef: :replace, replace: "")
          changed = eval("data[:#{field}]").to_s.encode("utf-8", invalid: :replace, undef: :replace, replace: "")
          if (orig <=> changed) != 0
            begin
              changes[field] = changed
            rescue => error
              changes[field] = "Error #{error} in field #{field}"
            end
          end
        end
        found_plz = false
        new_addr = data[:addresses]
        if new_addr && new_addr = data[:addresses].first
          if doctor.addresses.size == 0
            changes["addresses"] = "no old address"
            doctor.addresses << new_addr
          else
            found_address = false
            doctor.addresses.each do |addr|
              found_address = true if ODDB::Companies.company_address_matches(addr, new_addr)
              found_plz = true if addr.plz == new_addr.plz
            end
            unless found_address
              changes["addresses"] = new_addr.diff(doctor.addresses.first)
              doctor.addresses[0].name = new_addr.name
              doctor.addresses[0].address = new_addr.address
              doctor.addresses[0].location = new_addr.location
            end
          end
        elsif @with_details
          changes["addresses"] = "no new address"
        end
        return if changes.size == 0
        doctor.ean13 = gln
        doctor.name = data[:name]
        doctor.firstname = data[:firstname]
        doctor.language = data[:language]
        (action == "update") ? (@doctors_updated[gln] = doctor.fullname + ": " + changes.to_s) : (@doctors_created[gln.to_i] = doctor.fullname)
        if new_addr
          doctor.addresses.delete_if { |addr| addr.plz != new_addr.plz } unless found_plz
          doctor.addresses.push(new_addr) unless doctor.addresses.first
          doctor.addresses.first.name = new_addr.name
          doctor.addresses.first.address = new_addr.address
          doctor.addresses.first.location = new_addr.location
        end
        doctor.odba_store
        @@all_doctors << doctor
        log "store_doctor #{action} #{gln} oid #{doctor.oid} in database. pointer #{pointer.inspect} #{changes}"
        doctor
      end

      def parse_xml(path)
        log "parsing #{path} #{File.size(path)} bytes"
        xml = IO.read(path)
        if defined?(Minitest) && xml.size > 100 * 1024
          $stdout.puts "File #{path} way too big #{File.size(path)}"
          # require 'debug'; binding.break
        end
        items = Ox.load(xml, mode: :hash_no_attrs)[:"soap:Envelope"][:"soap:Body"][:PARTNER][:ITEM]
        @info_to_gln = {}
        items.each_with_index do |item, index|
          log "At item #{index} of #{items.size}" if (index % 10000) == 0
          role = item[:ROLE].is_a?(Hash) ? item[:ROLE] : item[:ROLE].values.first
          type = role[:TYPE]
          next unless type.eql?("DoctMed")
          gln = item[:GLN].to_i
          next if @glns_to_import.size > 0 && !@glns_to_import.index(gln)
          hash = {}
          item.each { |key, value| hash[key.to_s.downcase.to_sym] = value if value.is_a?(String) }
          inactive = !item[:STATUS].eql?("A")
          if inactive
            if @app.doctor_by_gln(gln)
              @doctors_inactive[gln] = @app.doctor_by_gln(gln).fullname
            end
          else
            street = role[:STREET]
            strno = role[:STRNO]
            zip = role[:ZIP]
            city = role[:CITY]
            hash[:plz] = zip
            hash[:address] = if street
              if strno
                street + " " + strno.to_s
              else
                street
              end
            end
            hash[:location] = city
            hash[:name] = item[:DESCR1]
            hash[:firstname] = item[:DESCR2]
            case item[:LANG].upcase
            when /^D/
              hash[:language] = "deutsch"
            when /^I/
              hash[:language] = "italienisch"
            when /^F/
              hash[:language] = "französisch"
            end
            update_address(hash)
            if @with_details
              details = get_detail_to_gln(gln)
              hash.merge!(details)
            end
            store_doctor(hash, gln)
          end
          if inactive
            @doctors_skipped [gln] = gln
          else
            @info_to_gln[gln] = hash
          end
        end
        log "read #{@info_to_gln.size} @info_to_gln"
      ensure
        store_all_doctors
      end

      def self.all_doctors
        @@all_doctors.compact
      end

      private

      def store_all_doctors
        startTime = Time.now
        log "Start saving @app.doctors.odba_store after #{@doctors_created.size} created #{@doctors_updated.size} updated. This will take some minutes"
        @app.doctors.odba_store
        endTime = Time.now
        diffSeconds = (endTime - startTime).to_i
        log "Finished @app.Doctors.odba_store took #{diffSeconds} seconds" if diffSeconds > 1
      end
    end
  end
end
