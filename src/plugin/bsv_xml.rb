#!/usr/bin/env ruby
# BsvXmlPlugin -- oddb.org -- 10.11.2008 -- hwyss@ywesee.com

require 'config'
require 'drb'
require 'fileutils'
require 'mechanize'
require 'model/text'
require 'plugin/plugin'
require 'rexml/document'
require 'rexml/streamlistener'
require 'util/persistence'
require 'zip/zip'

module ODDB
  class BsvXmlPlugin < Plugin
    class Listener
      include REXML::StreamListener
      FORMATS = {
        'b' => :bold,
        'i' => :italic,
      }
      @@iconv = Iconv.new('latin1//TRANSLIT//IGNORE', 'utf8')
      def initialize app
        @app = app
        @change_flags = {}
      end
      def date txt
        unless txt.to_s.empty?
          parts = txt.split('.', 3).collect do |part| part.to_i end
          Date.new *parts.reverse
        end
      end
      def text text
        @text << @@iconv.iconv(text) if @text
      end
      def time txt
        unless txt.to_s.empty?
          parts = txt.split('.', 3).collect do |part| part.to_i end
          Time.local *parts.reverse
        end
      end
      def update_chapter chp, text, subheading=nil
        sec = chp.next_section
        if subheading
          sec.subheading << subheading.to_s << "\n"
        end
        text.each do |line|
          par = sec.next_paragraph
          line.scan /(<(\/)?([bi])>|[^<]+|<)/ do |match|
            if fmt = FORMATS[match[2]]
              if match[1]
                par.reduce_format fmt
              else
                par.augment_format fmt
              end
            else
              par << match[0]
            end
          end
        end
        chp.clean!
      end
    end
    class GenericsListener < Listener
      def tag_start name, attrs
        @text = ''
      end
      def tag_end name
        case name
        when 'GenGroupOrg'
          @pointer = Persistence::Pointer.new [:generic_group, @text]
        when 'PharmacodeOrg'
          @original = Package.find_by_pharmacode(@text)
        when 'PharmacodeGen'
          @generic = Package.find_by_pharmacode(@text)
        when 'OrgGen'
          if @pointer && @original && @generic
            group = @app.create @pointer
            @app.update @original.pointer, {:generic_group => @pointer}, :bag
            @app.update @generic.pointer, {:generic_group => @pointer}, :bag
          end
          @pointer, @original, @generic = nil
        end
        @text = nil
      end
    end
    class ItCodesListener < Listener
      def tag_start name, attrs
        case name
        when 'ItCode'
          code = attrs['Code'].to_s
          @pointer = Persistence::Pointer.new [:index_therapeuticus, code]
          @target_data = @data = {}
        when 'Limitations'
          @target_data = @lim_data = {}
        else
          @text = ''
        end
      end
      def tag_end name
        case name
        when 'ItCode'
          @app.update @pointer.creator, @data, :bag
          unless @lim_data.empty?
            lim_ptr = @pointer + :limitation_text
            @lim_data.each_key do |key|
              if key.to_s.size == 2
                chp = Text::Chapter.new
                update_chapter chp, @lim_data[key]
                @lim_data[key] = chp
              end
            end
            @app.update lim_ptr.creator, @lim_data, :bag
          end
        when /Limitation([A-Z].+)/, /Description(..)/
          @target_data.store $~[1].downcase.to_sym, @text
        when 'ValidFromDate'
          @target_data.store :valid_from, date(@text)
        when 'Points'
          @target_data.store :limitation_points, @text.to_i
        end
        @text = nil
      end
    end
    class PreparationsListener < Listener
      MEDDATA_SERVER = DRbObject.new(nil, MEDDATA_URI)
      GENERIC_TYPES = { 'O' => :original, 'G' => :generic }
      attr_reader :change_flags, :conflicted_packages,
                  :conflicted_packages_oot, :conflicted_registrations,
                  :missing_ikscodes, :missing_ikscodes_oot, :unknown_packages,
                  :unknown_packages_oot, :unknown_registrations
      def initialize *args
        super
        @conflicted_packages = []
        @conflicted_packages_oot = []
        @conflicted_registrations = []
        @missing_ikscodes = []
        @missing_ikscodes_oot = []
        @unknown_packages = []
        @unknown_packages_oot = []
        @unknown_registrations = []
        @origin = @@today.strftime "#{ODDB.config.url_bag_sl_zip} (%d.%m.%Y)"
      end
      def flag_change pointer, key
        (@change_flags[pointer] ||= []).push key
      end
      def load_ikskey pcode
        tries = 3
        ikskey = nil
        begin
          MEDDATA_SERVER.session(:product) { |meddata|
            results = meddata.search({:pharmacode => pcode})
            if(results.size == 1)
              data = meddata.detail(results.first, {:ean13 => [1,2]})
              if(ean13 = data[:ean13])
                ikskey = ean13[4,8]
              end
            end
          }
          ikskey
        rescue Errno::ECONNRESET
          if(tries > 0)
            tries -= 1
            sleep(3 - tries)
            retry
          else
            raise
          end
        end
      end
      def tag_start name, attrs
        case name
        when 'Pack'
          @pcode = attrs['Pharmacode']
          @data = @pac_data.dup
          @report = @report_data.dup.update(@data).update(@reg_data).
                                     update(@seq_data)
          @report.store :pharmacode_bag, @pcode
          @data.store :pharmacode, @pcode
          if @pack = Package.find_by_pharmacode(@pcode)
            @out_of_trade = @pack.out_of_trade
            @registration ||= @pack.registration
            if @registration
              @report.store :swissmedic_no_oddb, @registration.iksnr
              unless ['00000', @registration.iksnr].include?(@iksnr)
                @conflicted_registrations.push @report
              end
            end
          elsif ikskey = load_ikskey(@pcode)
            @iksnr = ikskey[0,5] if @iksnr == '00000'
            @registration ||= @app.registration(ikskey[0,5])
            @pack = @registration.package ikskey[5,3] if @registration
            @refdata_registration = true
          else
            # package is out of trade
            @out_of_trade = true
          end
          @sl_data = {}
          @lim_data = {}
          @conflict = false
        when 'Preparation'
          @descriptions = {}
          @reg_data = {}
          @seq_data = {}
          @pac_data = {}
          @sl_entries = {}
          @lim_texts = {}
          @name = {}
          @report_data = {}
          @refdata_registration = false
        when /(.+)Price/
          @price_type = $~[1].downcase.to_sym
          @price = Util::Money.new(0, @price_type, 'CH')
          @price.origin = @origin
          @price.authority = :sl
        when 'Limitation'
          @in_limitation = true
        when 'ItCode'
          @itcode = attrs['Code']
          @it_descriptions = {}
        else
          @text = ''
        end
      end
      def tag_end name
        case name
        when 'Pack'
          if @pack && !@conflict
            if seq = @pack.sequence
              @app.update seq.pointer, @seq_data, :bag
            end
            pold = @pack.price_public
            pnew = @data[:price_public]
            unless pold && pnew
              pold = @pack.price_exfactory
              pnew = @data[:price_exfactory]
            end
            if pold && pnew
              if pold > pnew
                flag_change @pack.pointer, :price_cut
              elsif pold < pnew
                flag_change @pack.pointer, :price_rise
              end
            end
            @app.update @pack.pointer, @data, :bag
            unless @sl_data.empty?
              @sl_entries.store @pack.pointer, @sl_data
              @lim_texts.store @pack.pointer, @lim_data
            end
          end
          @pcode, @pack, @sl_data, @lim_data, @out_of_trade = nil
        when 'Preparation'
          @sl_entries.each do |pac_ptr, sl_data|
            pack = pac_ptr.resolve @app
            unless pack.nil? || sl_data.empty?
              pointer = pac_ptr + :sl_entry
              @app.update pointer.creator, sl_data, :bag
            end
          end
          @lim_texts.each do |pac_ptr, lim_data|
            pac = pac_ptr.resolve(@app)
            if (sl_entry = pac.sl_entry) && !lim_data.empty?
              txt_ptr = sl_entry.pointer + :limitation_text
              @app.update txt_ptr.creator, lim_data, :bag
            end
          end
          if @registration
            @app.update @registration.pointer, @reg_data, :bag
          elsif @refdata_registration
            @unknown_registrations.push @report_data
          end
          @iksnr, @registration, @sl_entries, @lim_texts = nil
        when 'AtcCode'
          @seq_data.store :atc_class, @text
        when 'SwissmedicNo5'
          @iksnr = "%05i" % @text.to_i
          @report_data.store :swissmedic_no5_bag, @iksnr
          @registration = @app.registration(@iksnr)
        when 'SwissmedicNo8'
          @report.store :swissmedic_no8_bag, @text
          if @text.strip.empty?
            if @out_of_trade
              @missing_ikscodes_oot.push @report
            else
              @missing_ikscodes.push @report
            end
          end
          if @registration
            @ikscd = '%03i' % @text[-3,3].to_i
            @pack ||= @registration.package @ikscd
            if @pack && @pack.pharmacode && @pack.pharmacode != @pcode
              @report.store :pharmacode_oddb, @pack.pharmacode
              @conflict = true
            end
          end
        when 'OrgGenCode'
          gtype = GENERIC_TYPES[@text]
          @reg_data.store :generic_type, (gtype || :unknown)
          @pac_data.store :sl_generic_type, gtype
        when 'FlagSB20'
          @pac_data.store :deductible, @text == 'Y' ? 20 : 10
        when 'FlagNarcosis'
          @data.store :narcotic, @text == 'Y'
        when 'BagDossierNo'
          @sl_data.store :bsv_dossier, @text if @sl_data
        when /(.+)Price/
          if @price > 0
            @data.store :"price_#{@price_type}", @price
          end
          @price, @price_type = nil
        when 'Price'
          @price.amount = @text.to_f if @price
        when 'ValidFromDate'
          if @price
            @price.valid_from = time(@text)
          elsif @sl_entries
            @sl_entries.each_value do |sl_data|
              sl_data.store :valid_from, date(@text)
            end
          end
        when 'ValidThruDate'
          if @sl_entries
            @sl_entries.each_value do |sl_data|
              sl_data.store :valid_until, date(@text)
            end
          end
        when 'StatusTypeCodeSl'
          if @sl_data
            @sl_data.store :status, @text
            active = false
            flag = nil
            case @text
            when '2', '6'
              flag = :sl_entry
              active = true
            when '3', '7'
              flag = :sl_entry_delete
            when '9', '10'
              #  9: inactive
              # 10: pending
            else
              active = true
            end
            if active && !@out_of_trade
              if @registration && @pack.nil?
                @unknown_packages.push @report
              else
                if @conflict
                  @conflicted_packages.push @report
                end
                flag_change @pack.pointer, flag if flag
              end
            elsif @registration && @pack.nil?
              @unknown_packages_oot.push @report
            elsif @conflict
              @conflicted_packages_oot.push @report
            end
          end
        when 'IntegrationDate'
          @sl_data.store :introduction_date, date(@text) if @sl_data
        when 'PriceChangeTypeCode'
          @price.mutation_code = @text
        when 'Limitation'
          @in_limitation = false
        when 'LimitationType'
          # ignore
        when /^Limitation([A-Z].+)$/
          @sl_data.store $~[1].downcase.to_sym, @text if @sl_data
        when /^Name(..)$/
          key = $~[1].downcase.to_sym
          @name[key] = @text
          @report_data.store(:name_base, @text) if key == :de
        when /^Description(..)$/
          key = $~[1].downcase.to_sym
          if @in_limitation
            if @lim_data # we are within a Package
              chp = Text::Chapter.new
              update_chapter chp, @text
              @lim_data.store key, chp
            else
              @lim_texts.each_value do |text_data|
                chp = text_data[key] ||= Text::Chapter.new
                subheading = if @it_descriptions
                               [@itcode, @it_descriptions[key]].compact.join(': ')
                             else
                               @name[key]
                             end
                update_chapter chp, @text, subheading
              end
            end
          elsif @it_descriptions
            @it_descriptions[key] = @text
          else
            @descriptions[key] ||= @text
            @report_data[:name_descr] ||= @text if key == :de
          end
        when 'Points'
          @sl_data.store :limitation_points, @text.to_i if @sl_data
        when 'ItCode'
          @itcode = nil
          @it_descriptions = nil
        end
        @text = nil
      rescue Exception => e
        puts e.class
        puts e.message
        puts e.backtrace
        raise
      end
    end
    attr_reader :preparations_listener
    def initialize *args
      @latest = File.join ARCHIVE_PATH, 'xml', 'XMLPublications-latest.zip'
      super
    end
    def update
      path = download_to ARCHIVE_PATH
      if File.exist?(@latest) && FileUtils.cmp(@latest, path)
        FileUtils.rm path
        return
      end
      _update path
      FileUtils.cp path, @latest
      path
    end
    def _update path=@latest
      Zip::ZipFile.foreach(path) do |entry|
        case entry.name
        when /(\w+)(-\d+)?.xml$/
          updater = $~[1].gsub(/[A-Z]/) do |match| "_" << match.downcase end
          entry.get_input_stream do |io| send('update' << updater, io) end
        when 'Publications.xls'
          # do nothing, is not even an xls as of 11.11.2008
        end
      end
    end
    def download_to archive_path
      archive = File.join archive_path, 'xml'
      FileUtils.mkdir_p archive
      agent = WWW::Mechanize.new
      zip = agent.get ODDB.config.url_bag_sl_zip
      target = File.join archive,
               Date.today.strftime("XMLPublications-%Y.%m.%d.zip")
      zip.save_as target
      target
    end
    def log_info
      body = ''
      info = super
      parts = [
        [:missing_ikscodes, 'Missing Swissmedic-Codes in SL %d.%m.%Y'],
        [:unknown_registrations, 'Unknown Registrations in SL %d.%m.%Y'],
        [:unknown_packages, 'Unknown Packages in SL %d.%m.%Y'],
        [:conflicted_registrations, 'SMJ/SL-Differences (Registrations) %d.%m.%Y'],
        [:conflicted_packages, 'SMJ/SL-Differences (Packages) %d.%m.%Y'],
        [:missing_ikscodes_oot, 
          'Missing Swissmedic-Codes in SL (out of trade) %d.%m.%Y'],
        [:unknown_packages_oot, 'Unknown Packages in SL (out of trade) %d.%m.%Y'],
        [:conflicted_packages_oot, 
          'SMJ/SL-Differences (Packages, out of trade) %d.%m.%Y'],
      ].collect do |collection, fmt|
        values = @preparations_listener.send(collection).collect do |data|
          report_format data
        end.sort
        name = @@today.strftime fmt
        header = report_format_header(name, values.size)
        body << header << "\n"
        report = [
          header,
          values.join("\n\n"),
        ].join("\n")
        ['text/plain', name.gsub(/[\s()\/-]/, '_') << '.txt', report]
      end
      info.update(:parts => parts, :report => body)
      info
    end
    def report_format_header name, size
      sprintf "%-58s%5i", name, size
    end
    def report_format hash
      [
        :name_base,
        :name_descr,
        :atc_class,
        :generic_type,
        :deductible,
        :pharmacode_bag,
        :pharmacode_oddb,
        :swissmedic_no_oddb,
        :swissmedic_no5_bag,
        :swissmedic_no8_bag,
      ].collect do |key|
        label = key.to_s.capitalize.gsub('_', '-') << ':'
        sprintf "%-20s %s", label, hash[key]
      end.join("\n")
    end
    def update_generics io
      listener = GenericsListener.new @app
      REXML::Document.parse_stream io, listener
    end
    def update_it_codes io
      listener = ItCodesListener.new @app
      REXML::Document.parse_stream io, listener
    end
    def update_preparations io
      @preparations_listener = PreparationsListener.new @app
      REXML::Document.parse_stream io, @preparations_listener
      @change_flags = @preparations_listener.change_flags
    end
  end
end
