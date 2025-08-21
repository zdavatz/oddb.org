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

module ODDB
  module Companies
    BetriebeURL = "https://www.medregbm.admin.ch/Betrieb/Search"
    RegExpBetriebDetail = /\/Betrieb\/Details\//

    def self.company_address_matches(new_addr, old_addr)
      return false until new_addr && old_addr
      do_match = true
      [:address, :location].each do |field|
        do_match = false unless eval("old_addr.#{field}.eql?(new_addr.#{field})")
      end
      do_match
    end

    def self.download_partners_xml
      xml = nil
      begin
        file2save = File.join(ODDB::WORK_DIR, "xml", "refdata_jur.xml")
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
      <PTYPE xmlns="http://refdatabase.refdata.ch/Partner_in">ALL</PTYPE>
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
    Companies_XML = File.join(ODDB::WORK_DIR, "xml/refdata_jur_latest.xml")
    Companies_curr = File.join(ODDB::WORK_DIR, "xml/refdata_jur_#{Time.now.strftime("%Y.%m.%d")}.xml")
    # MedRegURL     = 'http://www.medregom.admin.ch/'
    # role_types are => ["Pharm", "Indus", "Hosp", "DruSto", "SerFirm", "DoctMed", "PubHea", "Whole", "Pharmst", "Inst", "HeaIns", "IntOrg", "HeaEmpl", "NursHom", "ONursOrg", "SWFirm", "EmergServ", "Assoc", "NonHealthCare", "HeaTec", "AccIns", "HeaProd", "SpecPra", "Drugg", "GrpPra", "Dent", "Veter", "Nurse", "Lab", "Chiro", "HeaProv", "Physio", "LabLeader", "Midw", "Psycho", "Naturopath", "NutrAdv", "SocSec", "Spitex", "DentGrpPra", "CompTherapist", "VetGrpPra", "PrivPra", "Ergo", "MedPracAss", "DiabAdv", "SpeeTher", "PharmAss", "MedSecr", "EmergCent"]

    class RefdataJurPlugin < Plugin
      RECIPIENTS = []
      def log(msg)
        LogFile.append("oddb/debug", " RefdataJurPlugin #{msg}", Time.now)
      end

      def save_for_log(msg)
        log(msg)
        withTimeStamp = "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}: #{msg}"
        @@logInfo << withTimeStamp
      end

      def initialize(app = nil, glns_to_import = [])
        @glns_to_import = glns_to_import.clone
        @glns_to_import ||= []
        @glns_to_import.delete_if { |item| item.size == 0 }
        @info_to_gln = {}
        @@logInfo = []
        super
        @partners_created = {}
        @partners_updated = {}
        @partners_skipped = {}
        @partners_inactive = {}
        @archive = File.join ODDB::WORK_DIR, "xls"
        @@all_partners = []
        @agent = Companies.setup_default_agent
      end

      def update(with_details = false)
        @with_details = with_details
        saved = @glns_to_import.clone
        needs_update, latest = get_latest_file
        return unless needs_update
        save_for_log "parse_xml #{latest} specified GLN ids #{saved.inspect}"
        parse_xml(latest)
        (@glns_to_import.size > 0) ? @glns_to_import : @info_to_gln.keys
        [@partners_created, @partners_updated, @partners_inactive, @partners_skipped]
      end

      def get_detail_to_gln(gln)
        r_loop = ResilientLoop.new(File.basename(__FILE__, ".rb"))
        nr_tries = 0
        hash = [
          ["Betriebsname", ""],
          ["Plz", ""],
          ["Ort", ""],
          ["GlnBetrieb", gln.to_s],
          ["BetriebsCodeId", "0"],
          ["KantonsCodeId", "0"]
        ]
        success = false
        failure = "Die Personensuche dauerte zu lange"
        while nr_tries < 3 && !success
          begin
            r_loop.try_run(gln, defined?(Minitest) ? 500 : 5) do
              # log "Searching for company with GLN #{gln}. Skipped #{@partners_skipped}, created #{@partners_created} updated #{@partners_updated} of #{@glns_to_import.size}).#{nr_tries > 0 ? ' nr_tries is ' + nr_tries.to_s : ''}"
              page_1 = @agent.get(BetriebeURL)
              raise Search_failure if page_1.content.match(failure)
              res_2 = @agent.post(BetriebeURL, hash)
              if res_2.link(href: RegExpBetriebDetail)
                page_3 = res_2.link(href: RegExpBetriebDetail).click
                raise Search_failure if page_3.content.match(failure)
                return parse_details(page_3, gln)
              elsif @info_to_gln[gln]
                # Probably a company
              else
                log "could not find gln #{gln}"
                @partners_skipped[gln.to_i] = gln.to_i
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
        {}
      end

      def parse_details(html, gln)
        left = html.at('div[class="colLeft"]').text
        html.at('div[class="colRight"]').text
        btm = html.at('div[class="twoColSpan"]').text
        infos = left.split(/\r\n\s*/)
        unless infos[2].eql?(gln.to_s)
          log "Mismatch between searched gln #{gln} and details #{infos[2]}"
          return nil
        end
        company = {}
        company[:name] = infos[4]
        idx_plz = infos.index("PLZ \\ Ort")
        infos.index("Bewilligungskanton")
        address = infos[6..idx_plz - 1].join(" ")
        company[:plz] = infos[idx_plz + 1]
        company[:location] = infos[idx_plz + 2]
        idx_typ = infos.index("Betriebstyp")
        ba_type = infos[idx_typ + 1]
        company[:address] = address
        company[:ba_type] = ba_type
        company[:narcotics] = btm.split(/\r\n\s*/)[-1]
        update_address(company)
        company
      end

      def get_latest_file
        latest = Companies_XML
        target = Companies_curr
        needs_update = true
        save_for_log "get_latest_file target #{target} #{File.exist?(target)} and #{latest} #{File.exist?(latest)}"
        if File.exist?(target) and !File.exist?(latest)
          FileUtils.cp(target, latest)
          return needs_update, latest
        end
        download = Companies.download_partners_xml
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
        return [] if (@partners_created.size + @partners_updated.size) == 0
        report = "Update of hospitals, pharmacies and pharma industry partners\n\n"
        report << "Number of partners: " << @app.companies.size.to_s << "\n"
        report << "Updated partners: " << @partners_updated.size.to_s << "\n"
        report << "Inactive partners: " << @partners_inactive.size.to_s << "\n"
        report << "Details of new partners: " << @partners_created.size.to_s << "\n"
        @partners_created.each { |gln, name| report << "#{gln}: #{name}\n" }
        report << "Details of updated partners: " << @partners_updated.size.to_s << "\n"
        @partners_updated.each { |gln, name| report << "#{gln}: #{name}\n" }
        report
      end

      def update_address(data)
        addr = Address2.new
        addr.name = data[:name]
        addr.address = data[:address]
        # addr.additional_lines = [data[:address] ]
        addr.location = [data[:plz], data[:location]].compact.join(" ")
        if (fon = data[:phone])
          addr.fon = [fon]
        end
        if (fax = data[:fax])
          addr.fax = [fax]
        end
        data[:addresses] = [addr]
      end

      def store_company(data, gln, ba_type)
        if ba_type == BA_type::BA_hospital
          if (company = @app.hospital_by_gln(gln))
            action = "update"
          else
            company = @app.create_hospital(gln)
            action = "create"
          end
        elsif (company = @app.company_by_gln(gln))
          action = "update"
        else
          company = @app.create_company
          company.ean13 = gln
          company.business_area = ba_type.to_sym
          @app.companies[gln] = company
          action = "create"
        end
        pointer = company.pointer
        data[:business_area] = ba_type
        changes = {}
        [:name, :business_area, :narcotics].each do |field|
          next if field.eql?(:narcotics) && !@with_details
          next unless company.respond_to?(field.to_sym) # business_area is not defined for hospitals
          eval("company.#{field} != data['#{field}']")
          orig = eval("company.#{field}").to_s.encode("utf-8", invalid: :replace, undef: :replace, replace: "?")
          changed = eval("data[:#{field}]").to_s.encode("utf-8", invalid: :replace, undef: :replace, replace: "?")
          if (orig.to_s <=> changed.to_s) != 0
            changes[field] = "#{orig} => #{changed}"
          end
        end
        update_address(data)
        new_addr = data[:addresses].first
        if new_addr
          if company.addresses.size == 0
            changes["addresses"] = "no old address"
            company.addresses << new_addr
          else
            found_address = false
            company.addresses.each do |addr|
              found_address = true if ODDB::Companies.company_address_matches(addr, new_addr)
            end
            unless found_address
              changes["addresses"] = new_addr.diff(company.addresses.first)
              company.addresses[0].address = new_addr.address
              company.addresses[0].location = new_addr.location
            end
          end
        else
          changes["addresses"] = "no new address"
        end
        return if changes.size == 0
        action.eql?("update") ? (@partners_updated[gln] = changes) : (@partners_created[gln] = "#{ba_type} #{data[:name]}")
        if ba_type == BA_type::BA_pharma || ba_type == BA_type::BA_public_pharmacy
          company.ean13 = gln
          company.business_area = ba_type.to_s
        end
        company.name = data[:name]
        company.narcotics = data[:narcotics] if @with_details
        startTime = Time.now
        company.odba_store
        endTime = Time.now
        log "company.odba_store took #{endTime - startTime} seconds" if (endTime - startTime).to_i > 1
        @@all_partners << company
        log "store_company #{action} #{gln} oid #{company.oid} #{ba_type} in database. pointer #{pointer.inspect} #{changes}"
        company
      end

      def parse_xml(path)
        log "parse_xml #{path} #{File.size(path)} bytes"
        xml = IO.read(path)
        if defined?(Minitest) && xml.size > 100 * 1024
          $stdout.puts "File #{path} way too big #{File.size(path)}"
          # require 'debug'; binding.break
        end
        items = Ox.load(xml, mode: :hash_no_attrs)[:"soap:Envelope"][:"soap:Body"][:PARTNER][:ITEM]
        @info_to_gln = {}
        items.each_with_index do |item, index|
          log "At item #{index} of #{items.size}" if (index % 20000) == 0
          unless item[:ROLE]
            log "At item #{index}: No ROLE defined for #{item.inspect}"
            next
          end
          role = item[:ROLE].is_a?(Hash) ? item[:ROLE] : item[:ROLE].values.first
          type = role[:TYPE]
          next unless type.eql?("Pharm") || type.eql?("Indus") || type.eql?("Hosp")
          gln = item[:GLN].to_i
          next if @glns_to_import.size > 0 && !@glns_to_import.index(gln)
          hash = {}
          item.each { |key, value| hash[key.to_s.downcase.to_sym] = value if value.is_a?(String) }
          inactive = !item[:STATUS].eql?("A")
          if inactive
            if company = @app.company_by_gln(gln)
              @partners_inactive[gln] = company.name
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
            hash[:name] = item[:DESCR1] || item[:DESCR2]
            ba_type = nil
            case type
            when /kantonale Beh/i
              ba_type = ODDB::BA_type::BA_cantonal_authority
            when /^Pharm$|ffentliche Apotheke/i
              ba_type = ODDB::BA_type::BA_public_pharmacy
            when /Spitalapotheke/i
              ba_type = ODDB::BA_type::BA_hospital_pharmacy
            when /wissenschaftliches Institut/i
              ba_type = ODDB::BA_type::BA_research_institute
            when /Indus$|BA_type::BA_pharma/
              ba_type = BA_type::BA_pharma
            when /^Hosp$|BA_type::BA_hospital/
              ba_type = BA_type::BA_hospital
              descr = item[:DESCR2]
              if comp = @app.company_by_gln(gln)
                # log("#{gln}: Overriding ba_type #{ba_type} from database #{comp.business_area} descr2 #{descr}")
                ba_type = comp.business_area
              elsif descr
                descr.upcase!
                if descr.eql?("APOTHEKE") ||
                    descr.eql?("PHARMACIE") ||
                    descr.eql?("FARMACIA")
                  ba_type = BA_type::BA_hospital_pharmacy
                end
              end
            else
              ba_type = "unknown"
              next
            end
            hash[:ba_type] = ba_type
            if /ba.*pharmacy/.match(ba_type) && @with_details
              details = get_detail_to_gln(gln)
              hash.merge!(details)
            end
            store_company(hash, gln, ba_type)
          end
          if inactive
            @partners_skipped [gln.to_i] = gln.to_i
          else
            @info_to_gln[gln] = hash
          end
        end
        log "read #{@info_to_gln.size} @info_to_gln"
      ensure
        store_companies_and_hospitals
      end

      def self.all_partners
        @@all_partners.compact
      end

      private

      def store_companies_and_hospitals
        log "Storing hospitals and companies. This will take a few minutes"
        startTime = Time.now
        @app.companies.odba_store
        @app.hospitals.odba_store
        endTime = Time.now
        log "Took #{(endTime - startTime).to_i} seconds to store companies and pharmacies" if (endTime - startTime).to_i > 1
      end
    end
  end
end
