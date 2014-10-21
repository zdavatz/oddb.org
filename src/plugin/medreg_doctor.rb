#!/usr/bin/env ruby
# encoding: utf-8
# Doctors -- oddb -- 21.09.2004 -- jlang@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'plugin/plugin'
require 'model/address'
require 'util/oddbconfig'
require 'util/persistence'
require 'util/logfile'
require 'rubyXL'
require 'mechanize'
require 'logger'
require 'cgi'
require 'watir'
require 'psych' if RUBY_VERSION.match(/^1\.9/)
require "yaml"

module ODDB
  module Doctors
    Personen_XLSX = File.expand_path(File.join(__FILE__, '../../../data/xls/Personen_latest.xlsx'))
    Personen_YAML  = File.expand_path(File.join(__FILE__, "../../../data/txt/doctors_#{Time.now.strftime('%Y.%m.%d')}.yaml"))
    MedRegURL     = 'https://www.medreg.admin.ch/MedReg/PersonenSuche.aspx'
    # MedRegURL     = 'http://www.medregom.admin.ch/'
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
        $stdout.puts "#{Time.now}:  MedregDoctorPlugin #{msg}"; $stdout.flush
        LogFile.append('oddb/debug', " MedregDoctorPlugin #{msg}", Time.now)
      end

      def save_for_log(msg)
        LogFile.append('oddb/debug', " MedregDoctorPlugin #{msg}", Time.now)
        withTimeStamp = "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}: #{msg}"
        # $stderr.puts withTimeStamp
        @@logInfo << withTimeStamp
      end
      def initialize(app=nil, glns_to_import = [])
        @glns_to_import = glns_to_import
        @info_to_gln    = {}
        @@logInfo       = []
        FileUtils.rm_f(Personen_YAML) if File.exists?(Personen_YAML)
        @yaml_file      = File.open(Personen_YAML, 'w+')
        super
        @doctors_created = 0
        @doctors_skipped = 0
        @doctors_deleted = 0
        @archive = File.join ARCHIVE_PATH, 'xls'
        @@all_doctors    = []
        setup_default_browser
      end
      def update
        needs_update,latest = get_latest_file
        return unless needs_update
        save_for_log "parse_xls #{latest}"
        parse_xls(latest)
        @info_to_gln.keys
        get_detail_info
        return @doctors_created, @doctors_deleted, @doctors_skipped
      ensure
        File.open(Personen_YAML, 'w+') {|f| f.write(@@all_doctors.to_yaml) }        
      end
      def setup_default_browser
        unless @browser
          @browser = Watir::Browser.new(:chrome)
        end
        at_exit { @browser.close if @browser }
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
        end
        @agent
      end
          require 'pry'; 
      def get_detail_info
        if false # search via https://www.medreg.admin.ch/MedReg/Summary.aspx?IdPerson
          setup_default_agent
          # other idea would be to iteratate over all IdPerson
          # https://www.medreg.admin.ch/MedReg/Summary.aspx?IdPerson=20822
          @agent.log = Logger.new('tst.log')
          # https://www.medreg.admin.ch/MedReg/Summary.aspx?IdPerson=210
          personen = @agent.get('https://www.medreg.admin.ch/MedReg/PersonenSuche.aspx')
          ids = 200.upto(220).each { |id|
            info = @info_to_gln[id.to_s]
            $stderr.puts "get_detail_info for #{id} is  #{info}"
            url = "https://www.medreg.admin.ch/MedReg/Summary.aspx?IdPerson=#{id}"
            begin
              home = @agent.get(url)
            rescue => e
              next
            end
            File.open("tst_#{ids}.html", 'w+') { |f| f.write home.body }
            doc = Nokogiri::HTML(home.body)
          # FireXPath #ctl00_ContentPlaceHolder2_Label4 <span id="ctl00_ContentPlaceHolder2_Label4" class="InputLabel">Berufe (Diplome), Erteilungsland</span>
            diplome = doc.xpath("//table[@id='ctl00_ContentPlaceHolder2_gridviewDiplomDaten']").text
            diplome.split(/[,\r]/)
            stammdaten = doc.xpath("//table[@id='ctl00_ContentPlaceHolder2_GridView_Stammdaten']").text.gsub(/[\n\t]/,'').split(/\r/)
            log diplome.split(/[,\r]/)
            log stammdaten
          } 
        else
          regexp = /^Merkliste \n(.*)\nBundesamt für Gesundheit \(BAG\)\nRechtliche Grundlagen/m
          regexpAdressen = /^Adresse\(n\)\n(.*)\nBundesamt für Gesundheit \(BAG\)\nRechtliche Grundlagen/m
          setup_default_browser
          ids = @info_to_gln.keys
          $stderr.puts "ids to search are #{ids}"
          ids.each {
            |id|
              info = @info_to_gln[id.to_s]
              $stderr.puts "id to search is #{id} #{info}"
              # http://www.medregom.admin.ch/de/Suche/Detail/?gln=7601000813282&vorname=Dora+Carmela&name=ABANTO+PAYER
              url = "http://www.medregom.admin.ch/de/Suche/Detail/?gln=#{id}&vorname=#{info[:first_name].gsub(/ /, '+')}&name=#{info[:family_name].gsub(/ /, '+')}"
              @browser.goto(url)
      # => "Bundesverwaltung admin.ch\nEidgenössisches Departement des Innern EDI\nBundesamt für Gesundheit BAG\nStartseite\nDeutsch | Français | Italiano\nVersion: 1.4.2.36\nMedizinalberuferegister\nSuchen nach\nBeruf\nÄrztin/Arzt(0)\nChiropraktorin/Chiropraktor(0)\nZahnärztin/Zahnarzt(1)\nApothekerin/Apotheker(0)\nTierärztin/Tierarzt(0)\n  Name\nVorname\nStrasse\nPlz\nKanton\nAlle Kantone\nAargau\nAppenzell Ausserrhoden\nAppenzell Innerrhoden\nBasel-Land\nBasel-Stadt\nBern\nFreiburg\nGenf\nGlarus\nGraubünden\nJura\nLuzern\nNeuenburg\nNidwalden\nObwalden\nSchaffhausen\nSchwyz\nSolothurn\nSt. Gallen\nTessin\nThurgau\nUri\nWaadt\nWallis\nZug\nZürich\nGln\n        Weitere Sucheinschränkungen\nEgal \nSpezialisierung / Fachtitel\n\n\nWeiterbildungen\n\n\nTrefferliste\nMerkliste \nDora Carmela ABANTO PAYER\n\n\nABANTO PAYER, Dora Carmela (F)\n  Nationalität: Schweiz (CH)\nGLN: 7601000813282 \nBahnhofstrasse 41\n5000 Aarau\nKartendaten\nNutzungsbedingungen\nFehler bei Google Maps melden\nKarte\nZahnärztin/Zahnarzt\nBeruf Jahr Land\nZahnärztin/Zahnarzt 2004 Schweiz\nWeiterbildungstitel \nKeine Angaben vorhanden\nWeitere Qualifikationen (privatrechtliche Weiterbildung)\nKeine Angaben vorhanden\nBerufsausübungsbewilligung \nBewilligung erteilt für Kanton(e): Aargau  (2012) , Genf  (2004)\nDirektabgabe von Arzneimitteln gemäss kant. Bestimmungen (Selbstdispensation) \nkeine Selbstdispensation\nBezug von Betäubungsmitteln \nBerechtigung erteilt für Kanton(e): Aargau, Genf\nAdresse(n)\nBewilligungskanton: Aargau\nA. zahnarztzentrum.ch\nBahnhofstrasse 41\n5000 Aarau\nTelefon: 062 832 32 01\nFax: 062 832 32 01\nBewilligungskanton: Genf\nB. CABINET DENTAIRE VRBICA VESELIN\nAvenue du Bois-De-La-Chapelle 99\n1213 Onex\nTelefon: 022.793.29.60\nFax: 022.793.29.63\nBundesamt für Gesundheit (BAG)\nRechtliche Grundlagen"
              unless @browser.text.match(regexp)
                log "No Detail found"
                @doctors_skipped += 1
                next
              end
          infos = []
          nrWaits = 0
          while infos.size <= 1 && nrWaits < 10
            detail = @browser.text.match(regexp)[1].clone
            infos = detail.split("\n")
            log "#{Time.now}: Found #{infos.size} infos for #{info}"
            break if infos.size > 1
            sleep(1)
            nrWaits += 1
          end
          if infos.size <= 1 or infos.index("Die Suche ergab keine Treffer.")
            log "#{Time.now}: Unable to find #{id}  via #{info} and url #{url}"
            @doctors_skipped += 1
            next
          end
          binding.pry if infos.size == 10
          doctor = Hash.new
          doctor[:ean13] =  id.to_s.clone
          doctor[:name] =  infos[3].split(', ')[0].clone
          doctor[:firstname] =  infos[3].split(', ')[1].split(' (')[0].clone
          
          idx = infos.index('Beruf Jahr Land')
          doctor[:exam] =  infos[idx+1].split(' ')[1].clone
          idx = infos.index('Berufsausübungsbewilligung ')
          
          idx=infos.index('Weiterbildungstitel ')
          idx2=infos.index('Weitere Qualifikationen (privatrechtliche Weiterbildung)')
          specialities = infos[idx+1..idx2-1].join(", ")          
          doctor[:specialities] = specialities unless specialities.match(/Keine Angaben vorhanden/)
          # Selbstdispensation = infos.index("Direktabgabe von Arzneimitteln gemäss kant. Bestimmungen (Selbstdispensation) ") != nil
          # idx = infos.index("Bezug von Betäubungsmitteln ")
          # may_dispense_drugs = infos[idx+1].match(/Berechtigung erteilt für Kanton/) != nil
          # doctor[:email]
          # :language,
          # :praxis,
          # :title,
          # :salutation, # könnte via https://www.medreg.admin.ch/MedReg/Summary.aspx?IdPerson=4633 gefunden werden
          idx = infos.index("Adresse(n)")
          regexpAdressen = /^Adresse\(n\)\n(.*)\nBundesamt für Gesundheit \(BAG\)\nRechtliche Grundlagen/m
          addresses = get_addresses_from_medregob(@browser.text.match(regexpAdressen)[1])
                           
#          text = "Bewilligungskanton: Aargau\nA. zahnarztzentrum.ch\nBahnhofstrasse 41\n5000 Aarau\nTelefon: 062 832 32 01\nFax: 062 832 32 01\nBewilligungskanton: Genf\nB. CABINET DENTAIRE VRBICA VESELIN\nAvenue du Bois-De-La-Chapelle 99\n1213 Onex\nTelefon: 022.793.29.60\nFax: 022.793.29.63"
#          addresses = get_addresses_from_medregob(text)
          log addresses
          log doctor
          doctor[:addresses] = addresses
          store_doctor(doctor, nil)
          @@all_doctors << doctor
          }
        end
      end
      def get_addresses_from_medregob(addressText)
#        splitted = addressText.split('Bewilligungskanton: ')[1..-1]
        splitted = addressText.split(/Bewilligungskanton: |^[A-Z]\. /)[1..-1]
        addresses = []
        canton    = nil
                           splitted.each{ |a_adress|
                                          lines = a_adress.split("\n")
                                        if lines.size == 1
                                          canton = lines.first
                                          next
                                        end
                                        address = Hash.new
                                        address[:canton] = canton
                                        address[:lines] = []
                                        lines[1].sub!(/^[A-Z]\. /, '')
                                        lines[1..-1].each { |line|
                                                  if /^Telefon: /.match(line)
                                                   address[:fon] = line.split('Telefon: ')[1]
                                                   next
                                                  elsif /^Fax: /.match(line)
                                                   address[:fax] = line.split('Fax: ')[1]
                                                   next
                                                  else
                                                   address[:lines] << line
                                                  end
                                                   }
                                        addresses << address
                                        }
                           addresses
      end
      def get_latest_file        
        agent = Mechanize.new
        url = "https://www.medregbm.admin.ch/Publikation/CreateExcelListMedizinalPersons"
        latest = File.join @archive, "doctors_latest.xlsx"
        target = File.join @archive, Time.now.strftime("doctors_%Y.%m.%d.xlsx")
        file = agent.get(url)
        download = file.body
        needs_update = true
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
        report << "New doctors: " << @doctors_created.to_s << "\n"
        report << "Deleted doctors: " << @doctors_deleted.to_s << "\n"
        report
      end
      def merge_addresses(addrs)
        merged = []
        addrs.each { |addr|
          if(equal = merged.select { |other|
            addr[:lines] == other[:lines]
          }.first)
            merge_address(equal, addr, :fon)
            merge_address(equal, addr, :fax)
          else
            merge_address(addr, addr, :fax)
            merge_address(addr, addr, :fon)
            merged.push(addr)
          end
        }
        merged
      end
      def merge_address(target, source, sym)
        target[sym] = [target[sym], source[sym]].flatten
        target[sym].delete('')
        target[sym].uniq!
      end
      def prepare_addresses(hash)
        if(addrs = hash[:addresses])
          tmp_addrs = (addrs.is_a?(Array)) ? addrs : [addrs]
          merge_addresses(tmp_addrs).collect { |values|
            addr = Address.new
            values.each { |key, val| 
              meth = "#{key}="
              if(addr.respond_to?(meth))
                addr.send(meth, val)
              end
            }
            addr
          }
        else
          []
        end
      end
      def store_doctor(hash, addresses)
        pointer = nil
        if(doc = @app.doctor_by_gln(:ch, hash[:ean13]))
          pointer = doc.pointer
        else
          @doctors_created += 1
          ptr = Persistence::Pointer.new(:doctor)
          pointer = ptr.creator
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
              end	
            end
            doc_hash.store(key, value)
          end
          
        }
#        doc_hash.store(:addresses, prepare_addresses(addresses))
        @app.update(pointer, doc_hash)
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
