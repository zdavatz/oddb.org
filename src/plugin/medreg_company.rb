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
require 'rubyXL'
require 'mechanize'
require 'logger'
require 'cgi'
require 'watir'
require 'psych' if RUBY_VERSION.match(/^1\.9/)
require "yaml"

module ODDB
  module Companies
    DebugImport         = defined?(MiniTest)
    BetriebeURL         = 'https://www.medregbm.admin.ch/Betrieb/Search'
    BetriebeXLS_URL     = "https://www.medregbm.admin.ch/Publikation/CreateExcelListBetriebs"
    RegExpBetriebDetail = /\/Betrieb\/Details\//
    Companies_XLSX      = File.expand_path(File.join(__FILE__, '../../../data/xls/companies_latest.xlsx'))
    Companies_curr      = File.expand_path(File.join(__FILE__, "../../../data/xls/companies_#{Time.now.strftime('%Y.%m.%d')}.xlsx"))
    Companies_YAML      = File.expand_path(File.join(__FILE__, "../../../data/txt/companies_#{Time.now.strftime('%Y.%m.%d')}.yaml"))
    # MedRegURL     = 'http://www.medregom.admin.ch/'
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
#    GLN Person  Name  Vorname PLZ Ort Bewilligungskanton  Land  Diplom  BTM Berechtigung  Bewilligung Selbstdispensation  Bemerkung Selbstdispensation

    COL = {
      :gln                  => 0, # A
      :name_1               => 1, # B
      :name_2               => 2, # C
      :street               => 3, # D
      :street_number        => 4, # E
      :plz                  => 5, # F
      :locality             => 6, # G
      :canton_giving_permit => 7, # H
      :country              => 8, # I
      :company_type         => 9, # J
      :drug_permit          => 10, # K
    }
    class MedregCompanyPlugin < Plugin
      RECIPIENTS = []
      def log(msg)
        $stdout.puts    "#{Time.now}:  MedregCompanyPlugin #{msg}" # unless defined?(Minitest)
        $stdout.flush
        LogFile.append('oddb/debug', " MedregCompanyPlugin #{msg}", Time.now)
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
        FileUtils.rm_f(Companies_YAML) if File.exists?(Companies_YAML)
        @yaml_file      = File.open(Companies_YAML, 'w+')
        super
        @companies_created = 0
        @companies_updated = 0
        @companies_skipped = 0
        @companies_deleted = 0
        @archive = File.join ARCHIVE_PATH, 'xls'
        @@all_companies    = []
        setup_default_agent
      end
      def update
        saved = @glns_to_import.clone
        needs_update, latest = get_latest_file
        return unless needs_update
        save_for_log "parse_xls #{latest} specified GLN ids #{saved.inspect}"
        parse_xls(latest)
        @info_to_gln.keys
        get_detail_to_glns(saved.size > 0 ? saved : @glns_to_import)
        return @companies_created, @companies_updated, @companies_deleted, @companies_skipped
      ensure
        File.open(Companies_YAML, 'w+') {|f| f.write(@@all_companies.to_yaml) }
        save_for_log "Saved #{@@all_companies.size} companies in #{Companies_YAML}"
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
        @agent
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
        company[:ean13] =  gln.to_s.clone
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
      Search_failure = 'search_took_to_long'
      def get_detail_to_glns(glns)
        r_loop = ResilientLoop.new(File.basename(__FILE__, '.rb'))
        failure = 'Die Personensuche dauerte zu lange'
        idx = 0
        max_retries = 60
        log "get_detail_to_glns for #{glns.size} glns. first 10 are #{glns[0..9]} state_id is #{r_loop.state_id.inspect}" if DebugImport
        glns.each { |gln|
          idx += 1
          if r_loop.must_skip?(gln)
            log "Skipping #{gln}. Waiting for #{r_loop.state_id.inspect}" if DebugImport
            next
          end
          nr_tries = 0
          success = false
          while nr_tries < max_retries  and not success
            begin
              r_loop.try_run(gln, defined?(Minitest) ? 500 : 5 ) do
                log "Searching for company with GLN #{gln}. Skipped #{@companies_skipped}, created #{@companies_created} updated #{@companies_updated} of #{glns.size}).#{nr_tries > 0 ? ' nr_tries is ' + nr_tries.to_s : ''}"
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
                  store_company(company)
                  @@all_companies << company
                else
                  log "could not find gln #{gln}"
                  @companies_skipped += 1
                end
                success = true
              end
            rescue Timeout => e
              nr_tries += max_retries  if defined?(MiniTest)
              log "rescue #{e} will retry #{max_retries - nr_tries} times"
              nr_tries += 1
              sleep defined?(MiniTest) ? 0.01 : 60
            end
            if (@companies_created + @companies_updated) % 100 == 99
              log "Start saving @app.companies.odba_store #{gln} after #{@companies_created} created #{@companies_updated} updated"
              @app.companies.odba_store
              log "Finished @app.companies.odba_store" if DebugImport
            end
          end
        }
        r_loop.finished
      ensure
        log "Start saving @app.companies.odba_store"
        @app.companies.odba_store
        log "Finished @app.companies.odba_store"
      end
      def get_latest_file
        agent = Mechanize.new
        latest = Companies_XLSX
        target = Companies_curr
        needs_update = true
        save_for_log "get_latest_file target #{target} #{File.exist?(target)} and #{latest} #{File.exist?(latest)}"
        if File.exist?(target) and not File.exist?(latest)
          FileUtils.cp(target, latest, {:verbose => true})
          return needs_update,latest
        end
        file = agent.get(BetriebeXLS_URL)
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
        report = "Companies update \n\n"
        report << "Number of companies: " << @app.companies.size.to_s << "\n"
        report << "New companies: "       << @companies_created.to_s << "\n"
        report << "Updated companies: "   << @companies_updated.to_s << "\n"
        report << "Deleted companies: "   << @companies_deleted.to_s << "\n"
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
      def store_company(data)
        pointer = nil
        if(company = @app.company_by_gln(data[:ean13]))
          pointer = company.pointer
          @companies_updated += 1
          action = 'update'
        else
          @companies_created += 1
          company = @app.create_company
          pointer = company.pointer
          log "  created #{company} #{company.pointer}"
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
          else
            ba_type = 'unknown'
        end
        company.ean13         = data[:ean13]
        company.name          = data[:name]
        company.business_area = ba_type
        company.narcotics     = data[:narcotics]
        company.addresses     = data[:addresses]
        company.odba_store
        @app.companies.odba_store
        log "store_company updated #{data[:ean13]} oid #{company.oid}  #{action} in database. pointer #{pointer.inspect} ba_type #{ba_type}. Have now #{@app.companies.size} companies."
        company_copy = @app.company_by_gln(data[:ean13])
      end
      def parse_xls(path)
        log "parsing #{path}"
        workbook = RubyXL::Parser.parse(path)
        positions = []
        rows = 0
        workbook[0].each do |row|
          next unless row and (row[COL[:gln]] or row[COL[:name_1]])
          rows += 1
          if rows > 1
            info = CompanyInfo.new
            [:gln, :name_1, :name_2, :plz, :canton_giving_permit, :country, :company_type,:drug_permit].each {
              |field|
              cmd = "info.#{field} = row[COL[#{field.inspect}]] ? row[COL[#{field.inspect}]].value : nil"
              eval(cmd)
            }
            @info_to_gln[ row[COL[:gln]] ? row[COL[:gln]].value : row[COL[:name_1]].value ] = info
          end
        end
        @glns_to_import = @info_to_gln.keys.sort.uniq
      end
      def MedregCompanyPlugin.all_companies
        @@all_companies
      end
    end
  end
end
