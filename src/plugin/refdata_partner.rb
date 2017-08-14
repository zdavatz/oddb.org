#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'plugin/plugin'
require 'model/address'
require 'model/ba_type'
require 'util/oddbconfig'
require 'util/persistence'
require 'util/logfile'
require 'util/resilient_loop'
require 'open-uri'
require 'csv'
require 'mechanize'
require 'logger'
require 'cgi'
require 'savon'
require 'psych' if RUBY_VERSION.match(/^1\.9/)
require "yaml"
require 'ox'

module ODDB
  module Companies
    BetriebeURL         = 'https://www.medregbm.admin.ch/Betrieb/Search'
    RegExpBetriebDetail = /\/Betrieb\/Details\//

    def self.download_partners_xml
      xml = nil
      begin
        file2save = File.join(ODDB.config.data_dir, 'xml', 'refdata_partners.xml')
        FileUtils.rm_f(file2save, :verbose => false)
        @client = Savon.client(wsdl: "http://refdatabase.refdata.ch/Service/Partner.asmx?WSDL")
        response = @client.call(:download)
        if response.success? && (xml = response.to_xml)
          FileUtils.makedirs(File.dirname(file2save))
          File.open(file2save, 'w+') { |file| file.write xml }
          system("xmllint --format --output #{file2save.sub('.xml', '_pretty.xml')} #{file2save}")
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
      agent.user_agent = 'Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101 Firefox/31.0 Iceweasel/31.1.0'
      agent.redirect_ok         = :all
      agent.follow_meta_refresh = true
      agent.follow_meta_refresh = :everwhere
      agent.redirection_limit   = 55
      agent.follow_meta_refresh = true
      agent.ignore_bad_chunking = true
      agent
    end
    DebugImport         = defined?(MiniTest)
    Companies_XML      = File.expand_path(File.join(__FILE__, '../../../data/xls/partners_latest.xml'))
    Companies_curr      = File.expand_path(File.join(__FILE__, "../../../data/xls/partners_#{Time.now.strftime('%Y.%m.%d')}.xml"))
    # MedRegURL     = 'http://www.medregom.admin.ch/'
# role_types are => ["Pharm", "Indus", "Hosp", "DruSto", "SerFirm", "DoctMed", "PubHea", "Whole", "Pharmst", "Inst", "HeaIns", "IntOrg", "HeaEmpl", "NursHom", "ONursOrg", "SWFirm", "EmergServ", "Assoc", "NonHealthCare", "HeaTec", "AccIns", "HeaProd", "SpecPra", "Drugg", "GrpPra", "Dent", "Veter", "Nurse", "Lab", "Chiro", "HeaProv", "Physio", "LabLeader", "Midw", "Psycho", "Naturopath", "NutrAdv", "SocSec", "Spitex", "DentGrpPra", "CompTherapist", "VetGrpPra", "PrivPra", "Ergo", "MedPracAss", "DiabAdv", "SpeeTher", "PharmAss", "MedSecr", "EmergCent"]

    BaTypes_2_columns = {
      'ba_cantonal_authority' => 'x',
      'ba_doctor' => 'x',
      'ba_health' => 'x',
      'ba_hospital' => 'x',
      'ba_hospital_pharmacy' => 'x',
      'ba_info' => 'x',
      'ba_insurance' => 'x',
      'ba_pharma' => 'Pharmst',
      'ba_public_pharmacy' => 'PubHea',
      'ba_research_institute' => 'x',
    }
    CompanyInfo = Struct.new("CompanyInfo",
                            :gln,
                            :exam,
                            :address,
                            :name_1,
                            :name_2,
                            :addresses,
                            :plz,
                            :canton_giving_permit,
                            :country,
                            :company_type,
                            :drug_permit,
                           )
    class RefdataPartnerPlugin < Plugin
      RECIPIENTS = []
      def log(msg)
        $stdout.puts    "#{Time.now}:  RefdataPartnerPlugin #{msg}" # unless defined?(Minitest)
        $stdout.flush
        LogFile.append('oddb/debug', " RefdataPartnerPlugin #{msg}", Time.now)
      end

      def save_for_log(msg)
        log(msg)
        withTimeStamp = "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}: #{msg}"
        @@logInfo << withTimeStamp
      end
      def initialize(app=nil, glns_to_import = [])
        @glns_to_import = glns_to_import.clone
        @glns_to_import.delete_if {|item| item.size == 0}
        @info_to_gln    = {}
        @@logInfo       = []
        super
        @partners_created = 0
        @partners_updated = 0
        @partners_skipped = 0
        @partners_inactive = 0
        @archive = File.join ARCHIVE_PATH, 'xls'
        @@all_partners    = []
        @agent = Companies.setup_default_agent
      end
      def update
        saved = @glns_to_import.clone
        needs_update, latest = get_latest_file
        return unless needs_update
        save_for_log "parse_xml #{latest} specified GLN ids #{saved.inspect}"
        parse_xml(latest)
        to_import = @glns_to_import.size > 0 ? @glns_to_import : @info_to_gln.keys
        to_import.each { |gln| get_detail_to_gln(gln) }

        return @partners_created, @partners_updated, @partners_inactive, @partners_skipped
      end
      def get_detail_to_gln(gln)
        r_loop = ResilientLoop.new(File.basename(__FILE__, '.rb'))
        nr_tries = 0
        success = false
        failure = 'Die Personensuche dauerte zu lange'
        while nr_tries < 3 && !success
          begin
            r_loop.try_run(gln, defined?(Minitest) ? 500 : 5 ) do
              log "Searching for company with GLN #{gln}. Skipped #{@partners_skipped}, created #{@partners_created} updated #{@partners_updated} of #{@glns_to_import.size}).#{nr_tries > 0 ? ' nr_tries is ' + nr_tries.to_s : ''}"
              page_1 = @agent.get(BetriebeURL)
              raise Search_failure if page_1.content.match(failure)
              hash = [
            ['Betriebsname', ''],
            ['Plz', ''],
            ['Ort', ''],
            ['GlnBetrieb', gln.to_s],
            ['BetriebsCodeId', '0'],
            ['KantonsCodeId', '0'],
              ]
              res_2 = @agent.post(BetriebeURL, hash)
              if res_2.link(:href => RegExpBetriebDetail)
                page_3 = res_2.link(:href => RegExpBetriebDetail).click
                raise Search_failure if page_3.content.match(failure)
                company = parse_details(page_3, gln)
                company['GLN'] = gln
                store_company(company, gln)
              elsif info = @info_to_gln[gln]
                # Probably a company
              else
                log "could not find gln #{gln}"
                @partners_skipped += 1
              end
              success = true
            end
          rescue Timeout => e
            nr_tries += max_retries  if defined?(MiniTest)
            log "rescue #{e} will retry #{max_retries - nr_tries} times"
            nr_tries += 1
            sleep defined?(MiniTest) ? 0.01 : 60
          end
          if (@partners_created + @partners_updated) % 100 == 99
            log "Start saving @app.companies.odba_store #{gln} after #{@partners_created} created #{@partners_updated} updated"
            @app.companies.odba_store
            log "Finished @app.companies.odba_store" if DebugImport
          end
        end
      end
      def parse_details(html, gln)
        left = html.at('div[class="colLeft"]').text
        right = html.at('div[class="colRight"]').text
        btm = html.at('div[class="twoColSpan"]').text
        infos = []
        infos = left.split(/\r\n\s*/)
        unless infos[2].eql?(gln.to_s)
          log "Mismatch between searched gln #{gln} and details #{infos[2]}"
          return nil
        end
        company = Hash.new
        company[:name] =  infos[4]
        idx_plz     = infos.index("PLZ \\ Ort")
        idx_canton  = infos.index('Bewilligungskanton')
        address = infos[6..idx_plz-1].join(' ')
        company[:plz] = infos[idx_plz+1]
        company[:location] = infos[idx_plz+2]
        idx_typ = infos.index('Betriebstyp')
        ba_type = infos[idx_typ+1]
        company[:address] = address
        company[:ba_type] = ba_type
        company[:narcotics] = btm.split(/\r\n\s*/)[-1]
        update_address(company)
        log company
        company
      end
      def get_latest_file
        latest = Companies_XML
        target = Companies_curr
        needs_update = true
        save_for_log "get_latest_file target #{target} #{File.exist?(target)} and #{latest} #{File.exist?(latest)}"
        if File.exist?(target) and not File.exist?(latest)
          FileUtils.cp(target, latest)
          return needs_update,latest
        end
        download = Companies.download_partners_xml
        if (!File.exist?(latest) || download.size != File.size(latest))
          File.open(latest, 'w+') { |f| f.write download }
          File.open(target, 'w+') { |f| f.write download }
          save_for_log "saved get_latest_file (#{download.size} bytes) as #{target} and #{latest}"
        else
          save_for_log "latest_file #{target} #{download.size} bytes is uptodate"
          needs_update = false
        end
        return needs_update,latest
      end
      def report
        report = "Update of pharmacies and pharma industry partners\n\n"
        report << "Number of partners: " << @app.companies.size.to_s << "\n"
        report << "New partners: "       << @partners_created.to_s << "\n"
        report << "Updated partners: "   << @partners_updated.to_s << "\n"
        report << "Inactive partners: "  << @partners_inactive.to_s << "\n"
        report
      end
      def update_address(data)
        addr = Address2.new
        addr.name    =  data[:name  ]
        addr.address =  data[:address]
        # addr.additional_lines = [data[:address] ]
        addr.location = [data[:plz], data[:location]].compact.join(' ')
        if(fon = data[:phone])
          addr.fon = [fon]
        end
        if(fax = data[:fax])
          addr.fax = [fax]
        end
        data[:addresses] = [addr]
      end
      def store_company(data, gln)
        pointer = nil
        if(company = @app.company_by_gln(gln))
          pointer = company.pointer
          action = 'update'
        else
          company = @app.create_company
          pointer = company.pointer
          action = 'create'
        end
        ba_type = nil
        case  data[:ba_type]
          when /kantonale Beh/i
            ba_type = ODDB::BA_type::BA_cantonal_authority
          when /ffentliche Apotheke/i
            ba_type = ODDB::BA_type::BA_public_pharmacy
          when /Spitalapotheke/i
            ba_type = ODDB::BA_type::BA_hospital_pharmacy
          when /wissenschaftliches Institut/i
            ba_type = ODDB::BA_type::BA_research_institute
          when BA_type::BA_pharma
            ba_type = BA_type::BA_pharma
          else
            ba_type = 'unknown'
        end
        data[:business_area]        = ba_type
        changes = {}
        [:name, :business_area, :narcotics, :addresses].each do |field|
            has_changes = eval("company.#{field.to_s} != data['#{field}']")
            orig  =  eval("company.#{field.to_s}")
            changed = eval("data[:#{field}]")
            if (orig <=> changed) != 0
              changes[field] ="#{orig} => #{changed}"
            end
        end
        return if changes.size == 0
        action == 'update' ? ( @partners_updated += 1)  : (@partners_created += 1)
        company.ean13         = gln
        company.name          = data[:name]
        company.business_area = ba_type.to_s
        company.narcotics     = data[:narcotics]
        company.addresses     = data[:addresses]
        company.odba_store
        @@all_partners << data
        @app.companies.odba_store
        log "store_company #{action} #{gln} oid #{company.oid} in database. pointer #{pointer.inspect} #{changes}"
        company_copy = @app.company_by_gln(gln)
      end
      def parse_xml(path)
        log "parsing #{path} #{File.size(path)} bytes"
        # puts  table = doc.locate('soap:Envelope/soap:Body').first.name
        doc = Ox.parse(IO.read(path))
        items = doc.locate('soap:Envelope/soap:Body/PARTNER').first.nodes
        @info_to_gln = {}
        items.each do |item|
          next if item.is_a?(Ox::Comment)
          next unless item.name.eql?('ITEM')
          inactive = false
          hash = {}
          item.nodes.each do |elem|
            begin
              hash[elem.name] = elem.text
              inactive ||= elem.text.eql?('I') if elem.name.eql?('STATUS')

              if elem.name.eql?('ROLE')
                type = elem.nodes.find{|x| x.name.eql?('TYPE')}
                inactive ||= !(type.text.eql?('Pharm') || type.text.eql?('Indus'))
                if inactive
                  gln = hash['GLN']
                  if company = @app.company_by_gln(gln)
                    # log "inactive company with gln #{gln}"
                    # @app.delete_company(company.oid)
                    @partners_inactive += 1
                  end
                elsif type.text.eql?('Indus')
                  street  = (f1 = elem.locate('STREET').first) && f1.text
                  strno   = (f2 = elem.locate('STRNO').first) && f2.text
                  zip     = (f3 = elem.locate('ZIP').first) && f3.text
                  city    = (f4 = elem.locate('CITY').first) && f4.text
                  hash[:plz] = zip
                  if street
                    if strno
                      hash[:address] = street + ' ' + strno.to_s
                    else
                      hash[:address] = street
                    end
                  else
                    hash[:address] = nil
                  end
                  hash[:location] = city
                  hash[:name] = hash['DESCR1']
                  hash[:ba_type] = BA_type::BA_pharma
                  update_address(hash)
                  company = store_company(hash, hash['GLN'])
                end
              end
            end
          end
          if inactive
            @partners_skipped += 1
          else
            @info_to_gln[hash['GLN']] = hash
          end
        end
        log "read #{@info_to_gln.size} @info_to_gln"
      end
      def RefdataPartnerPlugin.all_partners
        @@all_partners.compact
      end
    end
  end
end
