  #!/usr/bin/env ruby
require 'plugin/plugin'
require 'model/package'
require 'util/oddbconfig'
require 'util/log'
require 'util/mail'
require 'custom/lookandfeelbase'
require 'mechanize'
require 'drb'
require 'util/latest'
require 'date'
require 'rubyXL'
require 'rubyXL/convenience_methods/workbook'
require 'csv'

module ODDB
  class ShortagePlugin < Plugin
    EXPORT_DIR = File.join(ARCHIVE_PATH, 'downloads')
    BASE_URI = 'https://www.drugshortage.ch'
    SOURCE_URI = BASE_URI + '/UebersichtaktuelleLieferengpaesse2.aspx'
    NoMarketingSource =  'https://www.swissmedic.ch/dam/swissmedic/de/dokumente/internetlisten/meldungen_art11_ham.xlsx.download.xlsx/Liste%20Meldungen%2011%20VAM.xlsx'

    def initialize app, opts={:reparse => false}
      super(app)
      @@logInfo = []
      @options = opts
      @options ||= {}
      @latest_shortage = File.expand_path('../../data/html/drugshortage-latest.html', File.dirname(__FILE__))
      @latest_nomarketing = File.expand_path('../../data/xlsx/nomarketing-latest.xlsx', File.dirname(__FILE__))
      @csv_file_path = File.join EXPORT_DIR, 'drugshortage.csv'
      @yesterday_csv_file_path = File.join EXPORT_DIR, "drugshortage-#{(@@today-1).strftime("%Y.%m.%d")}.csv"
      @dated_csv_file_path = File.join EXPORT_DIR, "drugshortage-#{@@today.strftime("%Y.%m.%d")}.csv"
      @report_shortage = []
      @report_nomarketing = []
      FileUtils.rm_f(@latest_shortage, verbose: true)    if @options[:reparse] && File.exist?(@latest_shortage)
      FileUtils.rm_f(@latest_nomarketing, verbose: true) if @options[:reparse] && File.exist?(@latest_nomarketing)
    end
    def date
      @@today
    end
    def report
      @report_summary = [ sprintf("Update job took %3i seconds",  @duration_in_secs.to_i) ]
      report_shortage
      report_nomarketing
      return [] unless @has_relevant_changes
      (@report_summary + [''] + @report_nomarketing  + [''] + @report_shortage).join("\n")
    end
    def update(agent=Mechanize.new)
      @has_relevant_changes = false
      @agent = agent
      start_time = Time.now
      update_nomarketing
      update_drugshortage
      export_drugshortage_csv
      @duration_in_secs = (Time.now.to_i - start_time.to_i)
    end
    def export_drugshortage_csv
      @options = { }
      if report.empty? && File.exist?(@csv_file_path)
        FileUtils.cp(@csv_file_path, @dated_csv_file_path, verbose: true)
        FileUtils.rm_f(@yesterday_csv_file_path) if File.exist?(@yesterday_csv_file_path) && IO.read(@yesterday_csv_file_path).eql?(IO.read(@csv_file_path))
        return
      end

      session = SessionStub.new(@app)
      session.language = 'de'
      session.lookandfeel = LookandfeelBase.new(session)
      keys = [:nomarketing_date, :nomarketing_since, :nodelivery_since, :nomarketing_link,
              :shortage_last_update, :shortage_state, :shortage_delivery_date, :shortage_link,
            ]
      added_info = [ 'gtin', 'atc', 'package_name' ]
      sorted = (@found_nomarketings.values + @found_shortages.values).sort do |x,y| x.gtin <=> y.gtin end
      FileUtils.makedirs(File.dirname(@csv_file_path)) unless File.exist?(File.dirname(@csv_file_path))
      CSV.open(@csv_file_path, "w", col_sep: ';', encoding: 'UTF-8') do |csv|
        values = []; (added_info + keys).each do |key|
          next if :gtin.eql?(key)
          values << session.lookandfeel.lookup(key)
        end
        csv << values
        sorted.each do |info|
          values = []
          values << info.gtin
          unless @app.package_by_ean13(info.gtin)
            puts "Skipping non existing package #{info.gtin}"
            next
          end
          atc_class = @app.package_by_ean13(info.gtin).atc_class
          values << (atc_class ? atc_class.code : '')
          values << @app.package_by_ean13(info.gtin).name
          keys.each do |key|
            next if :gtin.eql?(key)
            begin
              values << (info[key] ? info[key].to_s.gsub(';', ',') : nil)
            rescue => error
              msg = "Got error: #{error} key: #{key} info: #{info}"
              $STDOUT.puts  msg
              raise msg
            end
          end
          csv << values
        end
      end
      FileUtils.rm_f(@yesterday_csv_file_path) if File.exist?(@yesterday_csv_file_path) && IO.read(@yesterday_csv_file_path).eql?(IO.read(@csv_file_path))
      @csv_file_path
    end
    # send a log mail after running the import
    def log_info
      body = report << "\n\n"
      info = super
      parts = []
      if File.exist?(@csv_file_path)
        parts.push ['text/plain', File.basename(@csv_file_path), File.read(@csv_file_path)]
      end
      info.update(:parts => parts, :report => body)
      info
      info
    end
    private
    def report_shortage
      unless @shortages && @shortages.size  > 0
        FileUtils.rm_f(Latest.get_daily_name(@latest_shortage))
        @report_summary << "Nothing changed in #{SOURCE_URI}"
        return
      end
      @report_shortage = []
      @report_summary << sprintf("Found           %3i shortages in #{SOURCE_URI}",  @found_shortages.size)
      @report_summary << sprintf("Deleted         %3i shortages",  @deleted_shortages.size)
      @report_summary << sprintf("Changed         %3i shortages", @changes_shortages.size)
      @report_shortage << "\nDrugShortag changes:"
      @changes_shortages.each {|gtin, changed| @report_shortage << "#{gtin} #{changed.join("\n              ")}" }
      @report_shortage << "\nDrugShortag deletions:"
      @deleted_shortages.each {|gtin| @report_shortage << "#{gtin}" }
      if @deleted_shortages.size > 0 || @changes_shortages.size > 0
        @has_relevant_changes = true
      else
        FileUtils.rm_f(Latest.get_daily_name(@latest_shortage), verbose: true)
      end
    end
    def report_nomarketing
      unless @found_nomarketings && @found_nomarketings.size  > 0
        FileUtils.rm_f(Latest.get_daily_name(@latest_nomarketing), verbose: true)
        @report_summary << "Nothing changed in #{@nomarketing_href}"
        return
      end
      @report_nomarketing = []
      @report_summary << sprintf("Found           %3i nomarketings packages for #{@nomarketing_href}",  @found_nomarketings.size)
      @report_summary << sprintf("Deleted         %3i nomarketings",  @deleted_nomarketings.size)
      @report_summary << sprintf("Changed         %3i nomarketings", @changes_nomarketings.size)
      @report_summary << sprintf("Nr. IKSNR       %3i not in oddb.org database", @missing_nomarketings.size)
      @report_nomarketing << "\nNomarketing changes:"
      @changes_nomarketings.each {|gtin, changed| @report_nomarketing << "#{gtin} #{changed.join("\n              ")}" }
      @report_nomarketing << "\nNomarketing deletions:"
      @deleted_nomarketings.each {|gtin| @report_nomarketing << "#{gtin}" }
      @report_nomarketing << "\nIKSNR not found in oddb database:"
      @missing_nomarketings.each {|iksnr| @report_nomarketing << "#{iksnr}" }
      if @deleted_nomarketings.size > 0 || @changes_nomarketings.size > 0
        FileUtils.rm_f(Latest.get_daily_name(@latest_nomarketing), verbose: true)
      else
        @has_relevant_changes = true
      end
    end
    def update_drugshortage(agent = Mechanize.new)
      @deleted_shortages = []
      @changes_shortages = {}
      @found_shortages = {}
      @shortages = []
      @agent = agent
      latest = Latest.get_latest_file(@latest_shortage, SOURCE_URI)
      return unless latest
      puts "\nupdate_drugshortage latest is #{latest}  #{latest && File.exist?(latest)} @latest_shortage #{@latest_shortage} #{File.exist?(@latest_shortage)}"
      content = File.open(@latest_shortage, "r:UTF-8", &:read)
      puts "content is #{content.size} long and #{content.encoding}. Using Nokogiri::VERSION #{Nokogiri::VERSION} RUBY_VERSION #{RUBY_VERSION}"
      page = Nokogiri::HTML(content)
      gtin_regex = /^\d{13}$/
      @shortages = page.css('td').find_all{|x| gtin_regex.match(x.text) }
      if @shortages.size == 0
        puts "Page has #{page.css('td').size} TD elements found via css"
        puts "Dumping TD is"
        puts page.css('td').collect{|x|x.text}
        puts "Page is "
        puts page.elements.first.text
        puts (msg = "unable to parse #{SOURCE_URI} via #{@latest_shortage}  #{File.size(@latest_shortage)} page has #{page.elements.size} elements")
        raise msg
      end
      @shortages.each do |shortage|
        added_info = OpenStruct.new
        if shortage.parent.css('td').size != 9 && shortage.parent.css('td').size != 27
          raise "Unable to parse #{shortage.text} in #{SOURCE_URI}. Found only #{shortage.parent.css('td').size} tds"
        end
        added_info.gtin =  shortage.text
        lines = shortage.parent.text.split("\n")
        added_info.shortage_last_update = Date.strptime(shortage.parent.css('td')[4].text,"%d.%m.%Y").to_s
        added_info.shortage_state = shortage.parent.css('td')[6].text
        added_info.shortage_delivery_date = shortage.parent.css('td')[7].text
        added_info.shortage_link  = (BASE_URI + '/' + shortage.parent.css('td')[0].children.first.children.first.attributes.first.last.value).clone
        @found_shortages[added_info.gtin] = added_info
      end
      old_packages_with_shortage = @app.active_packages.find_all do |package|
        package.shortage_link
      end
      # set packages which are no longer in the shortage list to the default values
      old_packages_with_shortage.each do |package|
        next if @found_shortages[package.barcode]
        next unless @app.package_by_ean13(package.barcode)
        @deleted_shortages << "#{package.barcode};#{package.atc_class ? package.atc_class.code : ''};#{package.name}"
        package.no_longer_in_shortage_list
      end
      puts @found_shortages.keys
      @found_shortages.each do |gtin, info|
        pack = @app.package_by_ean13(gtin)
        next unless pack
        pack.no_longer_in_shortage_list if @options[:reparse]
        changed = []
        PackageCommon::Shortage_fields.each do |item|
          in_pack = eval("pack.#{item}")
          in_info = eval("info.#{item}")
          next if in_pack.to_s.eql?(in_info.to_s)
          changed << (msg = "#{item}: #{in_pack} => #{in_info}".rstrip)
        end
        next if changed.size == 0
        @changes_shortages["#{gtin};#{pack.atc_class ? pack.atc_class.code : ''};#{pack.name}"] = changed
        pack.update_shortage_list(info)
      end
    end
    def update_nomarketing
      @deleted_nomarketings = []
      @changes_nomarketings = {}
      @found_nomarketings = {}
      @missing_nomarketings = []
      return unless (path = get_latest_nomarketing_file)
      parse_nomarketing_xlsx(path)
      update_nomarketing_packages
    end
    def get_latest_nomarketing_file
      Latest.get_latest_file(@latest_nomarketing, NoMarketingSource)
    end
    def update_nomarketing_packages
      old_packages_with_nomarketing = @app.active_packages.find_all do |package|
        package.nomarketing_date
      end

      # set packages which are no longer in the nomarketing list to the default values
      old_packages_with_nomarketing.each do |package|
        next if @found_nomarketings[package.barcode]
        atc = package.atc_class ? package.atc_class.code : ''
        @deleted_nomarketings << "#{package.barcode};#{atc};#{package.name}"
        package.no_longer_in_nomarketing_list
      end
      @found_nomarketings.each do |gtin, info|
        pack = @app.package_by_ean13(gtin)
        next unless pack
        pack.no_longer_in_nomarketing_list if @options[:reparse]
        changed = []
        PackageCommon::NoMarketing_fields.each do |item|
          in_pack = eval("pack.#{item}")
          in_info = eval("info.#{item}")
          next if in_pack.to_s.eql?(in_info.to_s)
          changed << "#{item}: #{in_pack} => #{in_info}".rstrip
        end
        next if changed.size == 0
        @changes_nomarketings["#{gtin};#{pack.atc_class ? pack.atc_class.code : ''};#{pack.name}"] = changed
        pack.update_nomarketing_list(info)
      end
    end
    def parse_nomarketing_xlsx(path)
      workbook = RubyXL::Parser.parse(path)
      rows = 0
      cols_headers = { 0 => /Datum der Meldung/,
                       1 => /Zulassungs-.*nummer.*/m,
                       7 => /Nicht-Inverkehrbringen ab/,
                       8 => /Vertriebsunterbruch ab/,
                       }
      first_row = false
      workbook.first.each do |row|
        rows += 1
        unless first_row
          first_row = cols_headers.values.first.match(row[cols_headers.keys.first].value.to_s)
          if first_row
            cols_headers.each do |cell, expected|
              next if expected.match(row[cell].value)
              raise "Format of #{path} does not match for cell #{cell} not not match #{expected}. Is #{row[cell].value}"
            end
            next
          end
        end
        next unless first_row
        break unless row[0] # empty row
        added_info = OpenStruct.new
        added_info.nomarketing_date   = Date.parse(row[cols_headers.keys[0]].value.to_s) if row[cols_headers.keys[0]] && row[cols_headers.keys[0]].value
        added_info.iksnr              = row[cols_headers.keys[1]].value.to_s
        added_info.nomarketing_since  = Date.parse(row[cols_headers.keys[2]].value.to_s) if row[cols_headers.keys[2]] && row[cols_headers.keys[2]].value
        added_info.nodelivery_since   = Date.parse(row[cols_headers.keys[3]].value.to_s) if row[cols_headers.keys[3]] && row[cols_headers.keys[3]].value
        added_info.nomarketing_link   = @nomarketing_href
        unless @app.registration(added_info.iksnr)
          @missing_nomarketings << (added_info.iksnr)
          next
        end
        @app.registration(added_info.iksnr).active_packages.each do |package|
          added_info.gtin = package.barcode
          @found_nomarketings[added_info.gtin] = added_info.clone
        end
      end
    end
  end
end
