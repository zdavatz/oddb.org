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

module ODDB
  module Doctors
    Personen_XLSX = File.expand_path(File.join(__FILE__, '../../data/xls/Personen_latest.xlsx'))
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
        super
        @doctors_created = 0
        @doctors_deleted = 0
      end
      def update
        latest = get_latest
        save_for_log "parse_xls #{latest}"
        parse_xls(latest)
        @info_to_gln.keys
        get_detail_info
        @doctors_created
      end
      def setup_default_agent
        unless @agent
          @agent = Mechanize.new
#          @agent.user_agent = 'Mozilla/5.0 (X11; Linux x86_64; rv:16.0) Gecko/20100101 Firefox/16.0'
#          @agent.user_agent = 'Linux Firefox'
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
          $stdout.puts diplome.split(/[,\r]/)
          $stdout.puts stammdaten
        }
      end
      def get_latest
        $stderr.puts "TODO: get_latest"
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
      def store_doctor(doc_id, hash)
        pointer = nil
        if(doc = @app.doctor_by_origin(:ch, doc_id))
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
        doc_hash.store(:origin_db, :ch)
        doc_hash.store(:origin_id, doc_id)
        doc_hash.store(:addresses, prepare_addresses(hash))
        @app.update(pointer, doc_hash)
      end
      def parse_xls(path)
        $stdout.puts "parsing #{path}"
        workbook = RubyXL::Parser.parse(path)
        positions = []
        rows = 0
        workbook[0].each do |row|
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
