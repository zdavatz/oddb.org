#!/usr/bin/env ruby
require 'plugin/plugin'
require 'model/package'
require 'util/oddbconfig'
require 'mechanize'
require 'drb'
require 'util/latest'
require 'date'

module ODDB
  class ShortagePlugin < Plugin
    BASE_URI = 'https://www.drugshortage.ch'
    SOURCE_URI = BASE_URI + '/UebersichtaktuelleLieferengpaesse2.aspx'
    attr_reader :changes, :deleted, :found
    def report
      return '' unless @shortages && @shortages.size  > 0
      fmt =  "Found             %3i shortages in #{SOURCE_URI}"
      fmt << "\nDeleted         %3i shortages"
      fmt << "\nChanged         %3i shortages"
      fmt << "\nUpdate job took %3i seconds"
      txt = sprintf(fmt, @found.size, @deleted, @changes.size, @duration_in_secs.to_i)
      txt << "\nGTIN of concerned packages is\n"
      txt << @changes.keys.join("\n")
      txt << "\nChanges were:\n"
      @changes.each {|gtin, changed| txt << "#{gtin} #{changed.join("\n              ")}" }
      txt
    end
    def update(agent=Mechanize.new)
      latest = File.expand_path('../../data/html/drugshortage-latest.html', File.dirname(__FILE__))
      start_time = Time.now
      @deleted = 0
      @changes = {}
      @found = {}
      return unless Latest.get_latest_file(latest, SOURCE_URI, agent)
      page = Nokogiri::HTML(File.read(latest))
      gtin_regex = /^\d{13}$/
      @shortages = page.css('tr').find_all{|x| x.children[2] && gtin_regex.match(x.children[2].text)}
      raise "unable to parse #{SOURCE_URI}" if @shortages.size == 0
      @shortages.each do |shortage|
        added_info = OpenStruct.new
        added_info.gtin =  gtin_regex.match(shortage.children[2].text)[0]
        added_info.shortage_state = shortage.children[7].text
        added_info.shortage_last_update = Date.strptime(shortage.children[5].text,"%d.%m.%Y").to_s
        added_info.shortage_delivery_date = shortage.children[8].text
        added_info.shortage_url  = BASE_URI + '/' + shortage.css('a').first.attributes.first.last.value
        @found[added_info.gtin] = added_info
      end
      old_packages_with_shortage = @app.packages.find_all do |package|
        package.shortage_url
      end
      # set packages which are no longer in the shortage list to the default values
      old_packages_with_shortage.each do |package|
        next if @found[package.barcode]
        @deleted += 1
        package.no_longer_in_shortage_list
      end
      @found.each do |gtin, info|
        pack = @app.package_by_ean13(gtin)
        next unless pack
        changed = []
        PackageCommon::Shortage_fields.each do |item|
          in_pack = eval("pack.#{item}")
          in_info = eval("info.#{item}")
          next if in_pack.to_s.eql?(in_info.to_s)
          changed << "#{item}: #{in_pack} => #{in_info}"
        end
        next if changed.size == 0
        @changes[gtin] = changed
        pack.update_shortage_list(info)
      end
      @duration_in_secs = (Time.now.to_i - start_time.to_i)
    end
  end
end
