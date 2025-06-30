#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::LppvPlugin -- oddb.org -- 10.05.2012 -- yasaka@ywesee.com
# ODDB::LppvPlugin -- oddb.org -- 10.02.2012 -- mhatakeyama@ywesee.com
# ODDB::LppvPlugin -- oddb.org -- 18.01.2006 -- sfrischknecht@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))

require "plugin/plugin"
require 'model/package'
require "util/html_parser"
require 'open-uri'
require 'nokogiri'
require 'simple_xlsx_reader'

module ODDB
	class LppvPlugin < Plugin
    # Taken from http://www.lppv.ch/20160530/wp-content/download/LPPA_D.xlsx
    # PhCode  GTIN  Artikelname IT  Bezeichnung muteDate  muteTyp
    # Mutetyp
    # Standardmässig drin seit MuteDatum        0
    # neu seit letzten Update                   1
    # gelöscht seit letzten update              2
    # Ausser Handel seit (innerhalb 365 Tage)   9
    COL = {
      :PhCode      => 0, # A
      :GTIN        => 1, # B
      :Artikelname => 2, # C
      :IT          => 3, # D
      :Bezeichnung => 4, # E
      :muteDate    => 5, # F
      :muteTyp     => 6, # G
    }
		LPPV_HOST = 'www.lppv.ch'
    # some readers to ease testing
		attr_reader :updated_packages, :packages_with_sl_entry, :not_updated
		def initialize(app)
			super
			@updated_packages = []
			@packages_with_sl_entry = []
			@not_updated = []
		end
    def update
      @eans = []
      doc = Nokogiri::HTML(URI.open("http://#{LPPV_HOST}/"))
      links = Hash[doc.xpath('//a[@href]').map {|link| [link.text.strip, link["href"]]}]
      link = links.values.find{|x| /LPPV_D/.match(x) }
      @download_to = File.join ODDB::WORK_DIR, File.basename(link)
      URI.open(@download_to, 'w+') { |f| f.write URI.open(link).read }
      worksheet = SimpleXlsxReader.open(@download_to).sheets.first
      positions = []
      rows = 0
      worksheet.rows.each do |row|
        rows += 1
        if rows == 1
          # verify and catch error if the format changes without warning
          COL.each do |key, value|
            actual_name = row[value].to_s
            raise "Unexpected column name #{actual_name} does not match exepect #{key.to_s}" unless actual_name.eql?(key.to_s)
          end
        else
          pharmacode = row[COL[:PhCode]].to_s
          gtin = row[COL[:GTIN]].to_s
          name = row[COL[:Artikelname]].to_s
          it = row[COL[:IT]].to_s
          desc = row[COL[:Bezeichnung]].to_s
          muteDate = row[COL[:muteDate]].to_s
          muteTyp = row[COL[:muteTyp]].to_s
          # puts "read #{pharmacode} #{gtin} #{name}"
          if gtin.to_i > 0
            @eans << gtin
          else
            if pharmacode.length > 0
              @eans << pharmacode.to_i.to_s
            else
              @not_updated << "#{pharmacode} neither GTIN nor pharmacoe #{name} #{desc}"
            end
          end
        end
      end
      # puts "Read #{rows} rows from #{link}. Found #{@not_updated.size} without a GTIN"
      update_packages(@eans.dup.flatten)
    end
    def update_package(package, data)
      # puts "Checking pharma #{package.pharmacode} GTIN #{package.barcode}: #{package.pharmacode} #{package.name}"
      if(ean = (data.delete(package.barcode) || data.delete(package.pharmacode)))
        if(package.sl_entry && package.price_public)
          @packages_with_sl_entry.push(package)
        else
          do_lppv_update(package)
        end
      elsif(package.lppv && package.data_origin(:lppv) == :lppv)
        @app.update(package.pointer, {:lppv => false}, :lppv)
      end
    end
    def update_packages(data)
      @app.each_package do |package|
        update_package(package, data)
      end
    end
    def report
      lines = [
        "Updated Packages (lppv flag true): #{@updated_packages.size} details:",
        @updated_packages.join("\n"),
        nil,
        "Packages with SL-Entry: #{@packages_with_sl_entry.size}",
        nil,
        "Not updated were: #{@not_updated.size} details:",
        nil,
        @not_updated.join("\n"),
      ]
      lines.flatten.join("\n")
    end
    def do_lppv_update(package)
      if(!package.lppv)
        args = {
          :lppv => true
        }
        @app.update(package.pointer, args, :lppv)
        @updated_packages.push("#{package.barcode} pharma #{package.pharmacode} #{package.name}")
      end
    end
	end
end
