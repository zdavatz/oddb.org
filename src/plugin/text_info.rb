#!/usr/bin/env ruby

# ODDB::TextInfoPlugin -- oddb.org -- 22.05.2013 -- yasaka@ywesee.com
# ODDB::TextInfoPlugin -- oddb.org -- 30.01.2012 -- mhatakeyama@ywesee.com
# ODDB::TextInfoPlugin -- oddb.org -- 17.05.2010 -- hwyss@ywesee.com
require "date"
require "drb"
require "mechanize"
require "fileutils"
# require "config"
require "zip"
require "nokogiri"
require "plugin/plugin"
require "plugin/refdata"
require "model/fachinfo"
require "model/patinfo"
require "view/rss/fachinfo"
require "util/logfile"
require "simple_xlsx_reader"
require "yaml"

module ODDB
  SwissmedicMetaInfo = Struct.new("SwissmedicMetaInfo", :iksnr, :authNrs, :atcCode, :title, :authHolder,
    :substances, :type, :lang, :informationUpdate, :refdata,
    :html_file, :cache_file, :cache_sha256, :download_url)
  class TextInfoPlugin < Plugin
    Languages = [:de, :fr] # TODO: , :it
    CharsNotAllowedInBasename = /[^A-z0-9\-\.]/
    Override_file = File.join(Dir.pwd, "etc", defined?(Minitest) ? "barcode_minitest.yml" : "barcode_to_text_info.yml")
    DEBUG_FI_PARSE = !!ENV["DEBUG_FI_PARSE"]
    def initialize app, opts = {newest: true}
      super(app)
      @options = opts
      @parser = DRb::DRbObject.new nil, FIPARSE_URI
      @dirs = {
        fachinfo: File.join(ODDB::WORK_DIR, "html", "fachinfo"),
        patinfo: File.join(ODDB::WORK_DIR, "html", "patinfo")
      }
      @aips_xml = File.join(ODDB::WORK_DIR, "xml", "AipsDownload_latest.xml")
      @meta_yml = File.join(ODDB::WORK_DIR, "xml", "AipsMetaCache.yml")
      @xref_yml = File.join(ODDB::WORK_DIR, "xml", "AipsXref.yml")
      @zip_file = File.join(ODDB::WORK_DIR, "AllHtml.zip")
      @html_cache = File.join(ODDB::WORK_DIR, "html_cache")
      @details_dir = File.join(ODDB::WORK_DIR, "details")
      @updated_fis = []
      @updated_pis = []
      @ignored_pseudos = 0
      @session_failures = 0
      @fis_are_up2date = []
      @pis_are_up2date = []
      @iksless = Hash.new { |h, k| h[k] = [] }
      @unknown_iksnrs = {}
      @new_iksnrs = {}
      @failures = []
      @download_errors = []
      @companies = []
      @nonconforming_content = []
      @wrong_meta_tags = []
      @news_log = File.join ODDB.config.log_dir, "textinfos.txt"
      @title = ""       # target fi/pi name
      @target = :both
      # FI/PI names
      @updated = []
      @skipped = []
      @invalid = []
      @notfound = []
      @iksnr_to_fi = {}
      @iksnr_to_pi = {}
      @duplicate_entries = []
      @fi_without_atc_code = []
      @fi_atc_code_missmatch = []
      @target_keys = Util::COLUMNS_FEBRUARY_2019
      @iksnrs_meta_info = {}
      @specify_barcode_to_text_info ||= {}
      @skipped_override ||= []
      @missing_override ||= {}
      @multiple_entries ||= {}
      @invalid_html_url ||= []
      @already_imported ||= []
      @zip_url = "https://files.refdata.ch/simis-public-prod/MedicinalDocuments/AllHtml.zip"
      @stop_on_low_memory = false
    end

    def getFreeMemoryInMB
      m = /MemFree[: ]*(\d+)/.match File.read("/proc/meminfo")
      (m[1].to_i / (2**10)).to_i
    end

    def save_meta_and_xref_info
      FileUtils.makedirs(File.dirname(@xref_yml))
      File.write(@meta_yml, YAML.dump(@iksnrs_meta_info))
      @xref_file_2_meta = {}
      @iksnrs_meta_info.collect do |key, value|
        value.each do |aVal|
          @xref_file_2_meta[File.basename(aVal.cache_file)] = aVal
        end
        value.collect { |meta| File.basename(meta.cache_file) }
      end
      File.write(@xref_yml, YAML.dump(@xref_file_2_meta))
      LogFile.debug "from #{@meta_yml} wrote #{@xref_file_2_meta.size} xrefs to #{@xref_yml}"
    end

    def download_all_html_zip(zip_url = @zip_url)
      FileUtils.makedirs(File.dirname(@zip_file))
      FileUtils.makedirs(@html_cache)
      LogFile.debug("Downloading #{zip_url} to #{@zip_file}")
      if /^http/.match?(zip_url)
        cmd = "wget --quiet --timestamping #{zip_url}"
        system(cmd)
        if File.exist?(File.basename(zip_url)) && FileUtils.uptodate?(@zip_file, [File.basename(zip_url)])
          LogFile.debug("#{@zip_file} #{File.mtime(@zip_file)} is uptodate size: #{(File.size(@zip_file) / 1024 / 1024).to_i} MB")
          return
        end
        FileUtils.cp(File.basename(zip_url), @zip_file, preserve: true, verbose: true)
      elsif File.exist?(zip_url)
        FileUtils.cp(zip_url, @zip_file, preserve: true, verbose: true)
      end
      # Replaced Zip::File by system call unzip -o -q -d tmp AllHtml.zip. This take only 13 seconds for the 1.1 GB
      # Using the code below we need 20 seconds alone for the 174 kB!
      LogFile.debug("Unzipping #{@zip_file} of #{(File.size(@zip_file) / 1024 / 1024).to_i} MB")
      cmd = "unzip -o -q -d #{@html_cache} #{@zip_file}"
      system(cmd)
      system("rm -f #{@html_cache}/*.-it.html")
      system("rm -f #{@html_cache}/*-pdf")
      LogFile.debug("Saved #{zip_url} to #{@zip_file} of #{(File.size(@zip_file) / 1024 / 1024).to_i} MB")
    end

    def save_info type, name, lang, page, flags = {}
      dir = File.join @dirs[type], lang.to_s
      FileUtils.mkdir_p dir
      name_base = name.gsub(/[\/\s\+:]/, "_")
      tmp = File.join dir, name_base + ".tmp.html"
      page.save tmp
      path = File.join dir, name_base + ".html"
      if File.exist?(path) && FileUtils.compare_file(tmp, path)
        flags.store lang, :up_to_date
      end
      FileUtils.mv tmp, path
      path
    end

    IKS_Package = Struct.new("IKS_Package", :iksnr, :seqnr, :name_base)
    def read_packages # adapted from swissmedic.rb
      latest_name = File.join ODDB::WORK_DIR, "xls", "Packungen-latest.xlsx"
      LogFile.debug "found latest_name #{latest_name}"
      @packages = {}
      @veterinary_products = {}
      @target_keys = Util::COLUMNS_FEBRUARY_2019
      start_time = Time.now
      rows = SimpleXlsxReader.open(latest_name).sheets.first.rows
      rows.each do |row|
        next unless row[@target_keys.keys.index(:iksnr)].to_i and
          row[@target_keys.keys.index(:seqnr)].to_i and
          row[@target_keys.keys.index(:production_science)].to_i
        next if row[@target_keys.keys.index(:production_science)] == "Tierarzneimittel"
        iksnr = "%05i" % row[@target_keys.keys.index(:iksnr)].to_i
        seqnr = "%03i" % row[@target_keys.keys.index(:seqnr)].to_i
        name_base = row[@target_keys.keys.index(:name_base)]
        @packages[iksnr] = IKS_Package.new(iksnr, seqnr, name_base)
      end
      duration = (Time.now - start_time)
      LogFile.debug "found latest_name #{latest_name} with #{@packages.size} packages took #{sprintf("%7.3f", duration)} seconds"
    end

    def postprocess
      if @options[:skip] || @options[:fachinfo_only] || @options[:patinfo_only]
        LogFile.debug "#{Time.now}:Skipping postprocess as demanded by options #{@options}"
        return
      else
        LogFile.debug "#{Time.now}:postprocess fachinfo.rss"
      end
      update_rss_feeds("fachinfo.rss", @app.sorted_fachinfos, View::Rss::Fachinfo)
      update_yearly_fachinfo_feeds
    end

    def self.replace_textinfo(app, new_ti, container, type) # type must be :patinfo or :fachinfo
      return unless type.is_a?(Symbol)
      old_ti = container.send(type)
      if old_ti
        Languages.each do |lang|
          lang_s = lang.to_s
          if old_ti.descriptions && desc = new_ti.description(lang_s)
            msg = "#{container.class} #{type} lang #{lang_s} #{new_ti.description(lang_s).to_s.split("\n")[0..2]}"
            LogFile.debug msg
            old_ti.descriptions[lang_s] = desc
            old_ti.descriptions.odba_isolated_store
          end
        end
        res = app.update(old_ti.pointer, {descriptions: old_ti.descriptions})
        LogFile.debug "updated #{container.pointer} #{container.pointer} type #{type} #{new_ti.pointer}"
      else
        res = app.update(container.pointer, {type => new_ti.pointer})
        LogFile.debug "updated #{container.pointer} type #{type}" # does not work always old_ti.oid #{old_ti.oid} new_ti.oid #{new_ti.oid}"
      end
      res
    end

    def self.store_fachinfo(app, reg, fis)
      existing = reg.fachinfo
      if existing
        lang = fis.keys.first
        begin
          old_text = eval("existing.#{lang}.text").clone
          fis[lang].change_log = eval("existing.#{lang}.change_log").clone
        rescue
          LogFile.debug "#{reg.iksnr} #{fis.keys} fixing invalid old_text"
          old_text = nil
        end
        updated_fi = app.update reg.fachinfo.pointer, fis
        if old_text
          text_item = eval("updated_fi.#{lang}")
          new_text = text_item.text
          if fis[lang].change_log && fis[lang].change_log.respond_to?(:size)
            LogFile.debug "#{reg.iksnr} #{fis.keys} #{existing.pointer} " +
              "eql? #{old_text.eql?(new_text)} having #{fis[lang].change_log.size} change_logs"
          else
            LogFile.debug "store_fachinfo: #{reg.iksnr} #{fis.keys} #{existing.pointer} " +
              "eql? #{old_text.eql?(new_text)} without change_logs"
          end
          unless old_text.eql?(new_text)
            text_item.add_change_log_item(old_text, new_text)
            changed = reg.fachinfo.description(lang).change_log.last.diff.to_s
            removed = /^+.*/.match changed
            added = /^\+.*/.match changed
            LogFile.debug "FI: #{reg.iksnr} #{lang} old_size #{old_text.size} -> #{new_text.size} #{removed} #{added}" # if defined? Minitest
            text_item.odba_store
          end
        else
          LogFile.debug "#{reg.iksnr} #{fis.keys} #{existing.pointer} no old_text"
        end
        updated_fi
      else
        reg.fachinfo = app.create_fachinfo
        LogFile.debug "#{reg.iksnr} odba_id #{reg.odba_id} #{fis.keys} create_fachinfo #{reg.fachinfo.pointer}"
        app.update reg.fachinfo.pointer, fis
        reg.odba_store
        reg.fachinfo
      end
    end

    def store_orphaned iksnr, info, point = :orphaned_fachinfo
      if info
        pointer = Persistence::Pointer.new point
        store = {
          key: iksnr,
          languages: info
        }
        @app.update pointer.creator, store
      end
    end

    def ensure_correct_atc_code(app, registration, atcFromFI)
      iksnr = registration.iksnr
      unless atcFromFI
        @fi_without_atc_code << iksnr
        LogFile.debug "iksnr #{iksnr} atcFromFI is nil"
      end
      atcFromRegistration = nil
      atcFromRegistration = registration.sequences.values.first.atc_class.code if registration.sequences.values.first && registration.sequences.values.first.atc_class
      if atcFromRegistration && atcFromFI == atcFromRegistration
        LogFile.debug "iksnr #{iksnr} atcFromFI #{atcFromFI} matched and found"
        return # no need to change anything
      end
      if (!atcFromRegistration || atcFromFI != !atcFromRegistration)
        return unless atcFromFI # in this case we cannot correct it!
        atc_class = app.atc_class(atcFromFI)
        return if atc_class.is_a?(ArgumentError)
        atc_class ||= app.create_atc_class(atcFromFI)
        atc_class.pointer ||= Persistence::Pointer.new([:atc_class, atcFromFI])
        return if atc_class.is_a?(ArgumentError)
        registration.sequences.values.each { |sequence|
          LogFile.debug "iksnr #{iksnr} save atcFromFI #{atcFromFI} in sequence #{iksnr} sequence #{sequence.seqnr} atc_class #{atc_class} #{atc_class.oid}"
          app.update(sequence.pointer, {atc_class: atc_class}, :swissmedic_text_info)
          atc_class.odba_store
          sequence.atc_class = atc_class
          sequence.odba_isolated_store
          registration.odba_isolated_store
        }
        return
      end
      if atcFromFI != atcFromRegistration
        # res = app.update(registration.pointer, { :atc_class => atc_class}, :swissmedic_text_info)
        LogFile.debug "iksnr #{iksnr} atcFromFI and xml #{atcFromFI} differ from registration #{atcFromRegistration}. No action"
        return
      end
      atc_code = atcFromFI
      atc_class = app.atc_class(atc_code)
      return unless atc_class
      atc_class.pointer ||= Persistence::Pointer.new([:atc_class, atc_code])
      registration.sequences.values.each { |sequence|
        LogFile.debug "iksnr #{iksnr} save atc_code #{atc_code} (not same as atcFromXml #{atcFromXml}) in sequence #{sequence.seqnr}  atc_class #{atc_class}"
        app.update(sequence.pointer, {atc_class: atc_class}, :swissmedic_text_info)
        sequence.odba_store
      }
      LogFile.debug "iksnr #{iksnr} atcFromFI #{atcFromFI}. What went wrong"
    end

    def update_html_cache_file(meta_info)
      unless File.exist?((meta_info.html_file)) && FileUtils.compare_file(meta_info.html_file, meta_info.cache_file)
        FileUtils.makedirs(File.dirname(meta_info.html_file))
        FileUtils.cp(meta_info.cache_file, meta_info.html_file, verbose: true, preserve: true)
      end
    end

    def update_fachinfo_lang(meta_info, fis, fi_flags = {})
      unless meta_info.authNrs && meta_info.authNrs.size > 0
        @iksless[:fi].push meta_info.title
        if fis.values.first.date.to_s.index(Date.today.year.to_s) ||
            fis.values.first.date.to_s.index((Date.today.year - 1).to_s)
          LogFile.debug "@iksless date #{fis.values.first.date} accepted #{meta_info[:type]} as #{meta_info} not found in Packungen.xlsx"
        else
          LogFile.debug "@iksless date #{fis.values.first.date} rejected #{meta_info[:type]} as #{meta_info} not found in Packungen.xlsx"
          return
        end
      end
      begin
        if reg = @app.registration(meta_info.iksnr)
          ## identification of Pseudo-Fachinfos happens at download-time.
          #  but because we still want to extract the iksnrs, we just mark them
          #  and defer inaction until here:
          unless fi_flags[:pseudo] || fis.empty?
            if problems = reg.fachinfo&.descriptions&.find_all{|key,value| key.is_a?(Symbol)}
              LogFile.debug "Removing fachinfo with lang symbols keys from #{reg.iksnr} #{problems.collect{|x|x.first}}"
              reg.fachinfo.descriptions.delete_if{|key,value| key.is_a?(Symbol)}
              reg.fachinfo.descriptions.odba_isolated_store
              reg.fachinfo.descriptions.odba_store
              reg.fachinfo.odba_store
              reg.odba_store
            end
            LogFile.debug "#{meta_info.title} iksnr #{meta_info.iksnr} store_fachinfo #{fi_flags} #{fis.keys} ATC #{meta_info.atcCode}"
            unless meta_info.iksnr.to_i == 0
              fachinfo ||= TextInfoPlugin.store_fachinfo(@app, reg, fis)
              TextInfoPlugin.replace_textinfo(@app, fachinfo, reg, :fachinfo)
              ensure_correct_atc_code(@app, reg, fis[meta_info.lang].atc_code)
              @updated_fis << "#{meta_info.iksnr} #{fis.keys} #{reg.name_base}"
            end
          end
        else
          LogFile.debug "#{meta_info.title} iksnr #{meta_info.iksnr} store_orphaned"
          store_orphaned meta_info.iksnr, fis, :orphaned_fachinfo
          @unknown_iksnrs.store meta_info.iksnr, meta_info.title
        end
        update_html_cache_file(meta_info)
      rescue RuntimeError => err
        @failures.push "IKSNR: #{meta_info.iksnr} #{err.message} #{err.backtrace[0..8].join("\n")}"
        []
      end
    end

    def fix_odba_error_in_patinfo(package, lang)
      begin
        # Workaround and fix a problem in the database
        return false unless package.sequence.has_patinfo?
        bad = package.patinfo.descriptions.find_all do |key, value|
          $key = key
          $value = value
          !value.instance_of?(ODDB::PatinfoDocument)
        end
        if bad.size > 0
          LogFile.debug "Deleting lang #{lang} from patinfo #{package.iksnr} odba_id #{package.odba_id} bad #{bad}"
          package.patinfo.descriptions.delete_if { |key, value| !value.instance_of?(ODDB::PatinfoDocument) }
          package.odba_store
          return true
        end
      rescue
        if $key
          LogFile.debug "Deleting lang #{lang} from patinfo #{package.iksnr} odba_id #{package.odba_id} bad #{$key}"
          package.patinfo.descriptions.delete_if { |key, value| key.eql?($key) }
          package.odba_store
          package.patinfo.descriptions.find_all { |key, value| !value.instance_of?(ODDB::PatinfoDocument) }
        end
        return true
      end
      false
    end

    def store_patinfo_change_log(package, lang, new_patinfo_lang)
      patinfo = package.patinfo
      begin
        old_text = patinfo.description(lang).to_s
      rescue
        ""
      end
      fix_odba_error_in_patinfo(package, lang)
      old_size = defined?(patinfo.description(lang).change_log) ? old_text.size : 0
      unchanged = old_text.eql?(new_patinfo_lang.to_s)
      if unchanged
        LogFile.debug "#{package.iksnr}/#{package.seqnr} #{lang} skip #{patinfo.odba_id} unchanged #{unchanged} size #{old_size}" if defined? Minitest
        false
      else
        if patinfo.descriptions[lang]
          patinfo.description(lang).add_change_log_item(old_text, new_patinfo_lang)
          new_patinfo_lang.change_log = patinfo.description(lang).change_log # save changelog!
        end
        patinfo.descriptions[lang] = new_patinfo_lang
        package.odba_store
        LogFile.debug "PI: #{package.iksnr}/#{package.seqnr}/#{package.ikscd} #{lang} having #{patinfo.description(lang).change_log.size} changes #{new_patinfo_lang.to_s[0..40]}"
        true
      end
    end
    def store_package_patinfo(package, lang, patinfo_lang)
      return unless package
      msg = "#{package.iksnr}/#{package.seqnr}/#{package.ikscd}: #{lang} #{patinfo_lang.name}"
      if package&.patinfo.instance_of?(ODDB::Patinfo) && package.patinfo.descriptions.instance_of?(ODDB::SimpleLanguage::Descriptions) && package.patinfo.description(lang)
        if store_patinfo_change_log(package, lang, patinfo_lang)
          msg += " change_diff"
        else
          return package.patinfo
        end
      elsif package.patinfo && package.patinfo.is_a?(ODDB::Patinfo) && package.patinfo.descriptions.instance_of?(ODDB::SimpleLanguage::Descriptions)
        package.patinfo.descriptions[lang] = patinfo_lang
        package.patinfo.odba_store
        msg += " new patinfo"
      else
        package.patinfo = @app.create_patinfo
        package.patinfo.descriptions[lang] = patinfo_lang
        package.patinfo.odba_store
        msg += " created patinfo"
      end
      package.sequence.odba_store
      package.odba_store
      unless package.patinfo.descriptions.values.first.is_a?(ODDB::PatinfoDocument)
        msg = "class #{package.patinfo.descriptions.values.first.class} is not a PatinfoDocument"
        raise msg
      end
      # Update patinfo of sequence
      package.patinfo.odba_store
      package.sequence.odba_store
      package.sequence.patinfo = package.patinfo unless package.sequence.patinfo.equal?(package.patinfo)
      package.sequence.odba_store
      package.patinfo.odba_store
      package.odba_store
      LogFile.debug "called odba_store #{msg}"
      package.patinfo
    end

    def store_patinfo_for_all_packages(reg, iksnr, lang, patinfo_lang)
      reg.each_package do |package|
        if package.instance_of?(ODDB::Package)
          patinfo = store_package_patinfo(package, lang, patinfo_lang)
          LogFile.debug "Updating #{iksnr}/#{package.seqnr}/#{package.ikscd}: #{lang} #{patinfo_lang.to_s[0..40]}"
          package.patinfo = patinfo unless package.patinfo.equal?(patinfo)
        else
          LogFile.debug "Failed updating #{iksnr} as odba_id #{package.odba_id} is a #{ODBA.cache.fetch(package.odba_id).class}"
        end
      end
      reg.odba_store
    end

    def report_multiple(meta_info)
      key = [meta_info.iksnr, meta_info.type, meta_info.lang]
      @already_imported ||= []
      unless @already_imported.index(key)
        @already_imported << key
        return false
      else
        return key if @multiple_entries[key] # Info must be collected only once
        text = "\n#{meta_info.iksnr} #{meta_info.type} #{meta_info.lang}: has #{@iksnrs_meta_info[key].size} entries\n"
        LogFile.debug(text)
        text += @iksnrs_meta_info[key].collect do |x|
          date = Date.parse(x.informationUpdate)
          "   #{date} #{x.title} from #{File.basename(x.download_url)}"
        end.join("\n")
        @multiple_entries[key] = text
      end
    end

    def update_patinfo_lang(meta_info, textinfo_pi)
      unless meta_info&.authNrs&.size&.> 0
        @iksless[:pi].push meta_info.title
        if textinfo_pi.date.to_s.index(Date.today.year.to_s) ||
            textinfo_pi.date.to_s.index((Date.today.year - 1).to_s)
          LogFile.debug "@iksless date #{textinfo_pi.date} accepted #{meta_info[:type]} as #{meta_info} not found in Packungen.xlsx"
        else
          LogFile.debug "@iksless date #{textinfo_pi.date} rejected #{meta_info[:type]} as #{meta_info} not found in Packungen.xlsx"
          return
        end
      end

      # return unless @options[:reparse] && @options[:newest]
      begin
        if reg = @app.registration(meta_info.iksnr)
          lang = meta_info.lang
          key = [meta_info.iksnr, meta_info.type, meta_info.lang]
          return if @iksnrs_meta_info[key].size == 0
          if @iksnrs_meta_info[key].size == 1 # Same PI for all packages
            store_patinfo_for_all_packages(reg, meta_info.iksnr, lang, textinfo_pi)
            msg = "#{meta_info.iksnr} #{meta_info.lang}: #{meta_info.title}"
            @updated_pis << "  #{msg}"
          else # more than 1 PI for iksnr found
            reg.packages.each do |package|
              barcode_override = "#{package.barcode}_#{meta_info.type}_#{lang}"
              msg = "#{meta_info.iksnr}/#{package.seqnr}/#{package.ikscd} #{lang}: #{meta_info.title}"
              name = @specify_barcode_to_text_info[barcode_override]
              if meta_info.title.eql?(name)
                res = store_package_patinfo(package, lang, textinfo_pi)
                LogFile.debug "barcode_override #{barcode_override} #{name} #{package.ikscd} #{msg} res = #{res.to_s[0..40]}"
                @updated_pis << msg
              elsif name
                LogFile.debug "Skipped #{barcode_override} in #{Override_file} as we skip #{meta_info.title} != #{name}"
                @skipped_override << barcode_override
              else
                LogFile.debug "missing_override: not found via #{barcode_override}: '#{name}' != '#{meta_info.title}'"
                @missing_override["#{barcode_override}"] = "#{meta_info.title} # != override #{name}"
              end
            end
          end
        else
          LogFile.debug "#{meta_info.title} iksnr #{meta_info.iksnr} store_orphaned"
          store_orphaned meta_info.iksnr, pis, :orphaned_patinfo
          @unknown_iksnrs.store meta_info.iksnr, meta_info.title
        end
        update_html_cache_file(meta_info)
      rescue RuntimeError => err
        @failures.push "IKSNR: #{meta_info.iksnr} #{err.message} #{err.backtrace[0..8].join("\n")}"
        []
      end
    end

    def report
      if defined?(@inconsistencies)
        if @inconsistencies.size == 0
          return "Your database seems to be okay. No inconsistencies found. #{@inconsistencies.inspect}"
        else
          msg = "Problems in your database?\n\n" +
            "Check for inconsistencies in swissmedicinfo FI and PI found #{@inconsistencies.size} problems.\n" +
            "Summary: \n"
          headings = {}
          @error_reasons.sort.each { |id, count|
            item = "  * found #{sprintf("%3d", count)} #{id}\n"
            headings[id] = item
            msg += item
          }
          msg += "\n"
          # [reg.iksnr, reg.name_base, id]
          # (1..10).sort {|a,b| b <=> a}   #=> [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
          heading = nil
          @inconsistencies.sort.each { |error|
            unless error[0].eql?(heading)
              msg += "\n\n   Details for #{headings[error[0]]}\n\n"
              heading = error[0]
            end
            msg += error[1..-1].join(", ")
            msg += "\n"
          }
          msg += "\n"
          msg += @run_check_and_update ? "The following iksnr were reimported" : "Re-importing the following iksnrs might fix some problems"
          msg += "\n\n" + @iksnrs_to_import.join(" ")
          return msg
        end
      end
      unknown_size = @unknown_iksnrs.size
      new_size = @new_iksnrs.size
      @wrong_meta_tags ||= []
      @nonconforming_content ||= []
      @nonconforming_content = @nonconforming_content.uniq.sort
      create_iksnr = @new_iksnrs.collect { |iksnr, name|
        "  IKSNR #{iksnr}: #{name} "
      }.join("\n")
      unknown = @unknown_iksnrs.collect { |iksnr, name|
        "  IKSNR #{iksnr}: #{name} "
      }.join("\n")
      res = []
      case @target
      when :both
        res = [
          "Stored #{@updated_fis.size} Fachinfos",
          "Ignored #{@ignored_pseudos} Pseudo-Fachinfos",
          "Ignored #{@fis_are_up2date.size} up-to-date Fachinfo-Texts",
          "Stored #{@updated_pis.size} Patinfos",
          "Ignored #{@pis_are_up2date.size} up-to-date Patinfo-Texts",
          "Checked #{@companies.size} companies",
          @companies.join("\n"), nil,
          "Unknown Iks-Numbers: #{unknown_size}",
          unknown, nil,
          "Create Iks-Numbers: #{new_size}", create_iksnr, nil,
          "Fachinfos without iksnrs: #{@iksless[:fi].size}",
          @iksless[:fi].join("\n"), nil,
          # "Patinfos without iksnrs: #{@iksless[:pi].size}",
          # @iksless[:pi].join("\n"), nil,
          "Session failures: #{@session_failures}", nil,
          "Download errors: #{@download_errors.size}",
          @download_errors.join("\n"), nil,
          "Parse Errors: #{@failures.size}",
          @failures.join("\n"),
          # names
          @updated.join("\n"),
          @skipped.join("\n"),
          @invalid.join("\n"),
          @notfound.join("\n"), nil,
          "#{@fi_without_atc_code.size} FIs without an ATC-code", @fi_without_atc_code.join("\n"),
          "#{@fi_atc_code_missmatch.size} FI in HTML != metadata", @fi_atc_code_missmatch.join("\n")
        ].join("\n")
      when :fi
        res = [
          "Stored #{@updated_fis.size} Fachinfos",
          "Ignored #{@ignored_pseudos} Pseudo-Fachinfos",
          "Ignored #{@fis_are_up2date} up-to-date Fachinfo-Texts", nil,
          "Checked #{@companies.size} companies",
          @companies.join("\n"), nil,
          "Create Iks-Numbers: #{new_size}", create_iksnr, nil,
          "Unknown Iks-Numbers: #{unknown_size}",
          unknown, nil,
          "Fachinfos without iksnrs: #{@iksless[:fi].size}",
          @iksless[:fi].join("\n"), nil,
          "Session failures: #{@session_failures}", nil,
          "Download errors: #{@download_errors.size}",
          @download_errors.join("\n"), nil,
          "Parse Errors: #{@failures.size}",
          # names
          @failures.join("\n"),
          @updated.join("\n"),
          @skipped.join("\n"),
          @invalid.join("\n"),
          @notfound.join("\n"), nil,
          "#{@fi_without_atc_code.size} FIs without an ATC-code", @fi_without_atc_code.join("\n"),
          "#{@fi_atc_code_missmatch.size} FI in HTML != metadata", @fi_atc_code_missmatch.join("\n"),
          "#{@fi_atc_code_different_in_registration.size} FIs with ATC-code != registration", @fi_atc_code_different_in_registration.join("\n")
        ].join("\n")
      when :pi
        res = [
          "Stored #{@updated_pis.size} Patinfos",
          "Ignored #{@pis_are_up2date} up-to-date Patinfo-Texts", nil,
          "Checked #{@companies.size} companies",
          @companies.join("\n"), nil,
          "Create Iks-Numbers: #{new_size}", create_iksnr, nil,
          "Unknown Iks-Numbers: #{unknown_size}",
          unknown, nil,
          # "Patinfo without iksnrs: #{@iksless[:pi].size}",
          # @iksless[:pi].join("\n"), nil,
          "Session failures: #{@session_failures}", nil,
          "Download errors: #{@download_errors.size}",
          @download_errors.join("\n"), nil,
          "Parse Errors: #{@failures.size}",
          @failures.join("\n"),
          # names
          @updated.join("\n"),
          @skipped.join("\n"),
          @invalid.join("\n"),
          @notfound.join("\n"), nil
        ].join("\n")
      end
      if @invalid_html_url.size == 0
        res << "\nNo missing html URL in #{File.basename(@aips_xml)}\n"
      else
        res << "\n#{@invalid_html_url.size} HTML URL not found given in #{File.basename(@aips_xml)}:\n"
        res << @invalid_html_url.join("\n")
      end
      if @multiple_entries.size == 0
        res << "\nNo multiple entries in #{File.basename(@aips_xml)}"
      else
        res << "\nFound #{@multiple_entries.size} multiple entries in #{File.basename(@aips_xml)}:\n"
        @multiple_entries.each do |key, val|
          res << val
        end
      end
      if @updated_pis == 0
        res << "\n\nNo updated patinfos"
      else
        res << "\n\nStored #{@updated_pis.size} updated patinfos:\n"
        res << @updated_pis.join("\n")
      end
      if @updated_fis == 0
        res << "\nNo updated fachinfos\n"
      else
        res << "\nStored #{@updated_fis.size} updated fachinfos:\n"
        res << @updated_fis.join("\n")
      end
      if @wrong_meta_tags.size == 0
        res << "\nNo wrong metatags found\n"
      else
        res << "\n#{@wrong_meta_tags.size} wrong metatags:\n"
        res << @wrong_meta_tags.join("\n")
      end
      res << ""
      if @nonconforming_content.size == 0
        res << "\nAll imported images had a supported format\n"
      else
        res << "\n#{@nonconforming_content.size} non conforming contents:\n"
        res << @nonconforming_content.join("\n")
      end
      if @skipped_override.size > 0
        res << "\n#{Override_file}: The #{@skipped_override.size} has skipped entries for\n"
        res << @skipped_override.join("\n")
      end
      if @missing_override.size == 0
        res << "\nNo need to add anything to #{Override_file}\n"
      else
        res << "\n#{Override_file}: The #{@missing_override.size} missing overrides are\n"
        res << @missing_override.collect { |key, value| "#{key} #{value}" }.join("\n")
      end
      /MemFree[: ]*(\d+)/ =~ File.read("/proc/meminfo")
      res << "\nHaving free #{getFreeMemoryInMB} MB\n"
      File.open(Override_file, "w+") { |out| YAML.dump(@specify_barcode_to_text_info.merge(@missing_override), out, line_width: -1) }
      res
    end

    def init_agent
      setup_default_agent
      @agent.user_agent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_4_11; de-de) AppleWebKit/525.18 (KHTML, like Gecko) Version/3.1.2 Safari/525.22"
      @agent
    end

    def setup_default_agent
      unless @agent
        @agent = Mechanize.new
        @agent.user_agent = "Mozilla/5.0 (X11; Linux x86_64; rv:16.0) Gecko/20100101 Firefox/16.0"
        @agent.redirect_ok = true
        @agent.redirection_limit = 5
        @agent.follow_meta_refresh = true
        @agent.ignore_bad_chunking = true
      end
      @agent
    end

    def self.create_sequence(app, registration, title, seqNr, packNr = "000")
      seq_args = {
        composition_text: nil,
        name_base: title,
        name_descr: nil,
        dose: nil,
        sequence_date: nil,
        export_flag: nil
      }
      sequence = registration.create_sequence(seqNr) unless sequence = registration.sequence(seqNr)
      sequence.name_base = registration.name_base
      sequence.create_package(packNr)
      app.update(sequence.pointer, seq_args, :swissmedic_text_info)
      sequence.fix_pointers
      # Niklaus does not know why we have to duplicate the code here. But it ensures that newly added fis
      # are found after an import_daily
      registration.sequences.values.first.name_base = title
      registration.sequences.odba_store
      LogFile.debug "#{registration.iksnr} seqNr #{seqNr}  #{sequence.pointer} seq_args #{seq_args.keys} app.name #{title} should match #{app.registration(registration.iksnr).name_base} registration.sequences #{registration.sequences.keys}" # [0..99]
      sequence.odba_store
      sequence
    end

    def self.create_registration(app, metainfo, seqNr = "01", packNr = "001")
      iksnr = metainfo.iksnr
      reg = app.create_registration(iksnr)
      # similar to method update_registration in src/plugin/swissmedic.rb
      LogFile.debug("#{iksnr}/#{seqNr}/#{packNr} #{metainfo.title} company #{metainfo.authHolder}")
      reg_ptr = reg.pointer # Persistence::Pointer.new([:registration, metainfo.iksnr]).creator
      args = {
        ith_swissmedic: nil,
        production_science: nil,
        vaccine: nil,
        registration_date: nil,
        expiration_date: nil,
        renewal_flag: false,
        renewal_flag_swissmedic: false,
        inactive_date: nil,
        export_flag: nil
      }

      company_args = {name: metainfo.authHolder, business_area: "ba_pharma"}
      if (company = app.company_by_name(metainfo.authHolder, 0.8))
        app.update company.pointer, args, :text_plugin_create_company
      else
        company_ptr = Persistence::Pointer.new(:company).creator
        company = app.update company_ptr, company_args
      end
      args.store :company, company.pointer
      registration = app.update reg_ptr, args, :text_plugin_create_registration
      sequence = TextInfoPlugin.create_sequence(app, reg, metainfo.title, seqNr, packNr)
      reg.odba_store
      reg
    end
    REFDATA_SERVER = DRbObject.new(nil, ODDB::Refdata::RefdataArticle::URI)

    def create_missing_registrations
      @iksnrs_meta_info ||= {}
      @iksnrs_meta_info.each do |key, infos|
        first_iksnr = infos.first.authNrs.first
        fi_info = @iksnrs_meta_info.find { |key, value| key[0] == first_iksnr && key[1] == "fi" && key[2] == "de" }
        fi_info = fi_info[1].first if fi_info
        infos.first.authNrs.each do |iksnr|
          if @app.registration(iksnr)

          else
            if @options[:newest] || (@options[:iksnrs] && @options[:iksnrs].index(iksnr))
              info = if fi_info
                fi_info.clone
              else
                infos.first.clone
                # There are some registration, which have only a patient info, but no FI
                # e.g. 59705 Ceres Hypericum comp. omöopathisches Arzneimittel
              end
              info[:iksnr] = iksnr
              TextInfoPlugin.create_registration(@app, info)
            end
            @new_iksnrs[iksnr] = infos.first.title
          end
        end
      end
    end

    def self.get_iksnrs_from_string(string)
      iksnrs = []
      src1 = string.gsub(/[^0-9,:\s]/, "")
      src = src1.gsub(/[\d\w]+:/, "") # Catches stuff like "Zulassungsnummer Lopresor 100: 39'252 (Swissmedic) Lopresor Retard 200: 44'447 (Swissmedic)"
      if (matches = src.strip.scan(/\d{5}|\d{2}\s*\d{3}|\d\s*{5}/))
        # support some wrong in numbers [000nnn] (too many 0)
        if matches.length == 2 && matches.first =~ /^0{3}\d{2}$/ and
            matches.first.length == 5 && matches.last.length == 1
          matches = [matches.first[1..-1] + matches.last]
        end
        _iksnr = + ""
        matches.each do |iksnr|
          if iksnr.length == 5
            iksnrs << iksnr
            _iksnr = ""
            next
          end
          # support [nnnnn] and [n,n,n,n,n]
          _iksnr << iksnr.gsub(/[^0-9]/, "")
          if _iksnr.length == 5
            iksnrs << _iksnr
            _iksnr = ""
          end
        end
      end
      iksnrs.sort.uniq
    rescue => e
      puts "get_iksnrs_from_string: string #{string} rescued from #{e}"
      puts e.backtrace.join("\n")
      []
    end

    def detect_format(html)
      return :swissmedicinfo if html.index("section1") or html.index("Section7000")
      /MonTitle/i.match?(html) ? :compendium : :swissmedicinfo
    end

    def submit_event agent, form, eventtarget, *args
      max_retries = ODDB.config.text_info_max_retry
      form["__EVENTTARGET"] = eventtarget
      agent.submit form, *args
    rescue Mechanize::ResponseCodeError
      retries ||= max_retries
      if retries > 0
        retries -= 1
        sleep max_retries - retries
        retry
      else
        raise
      end
    end

    def log_news lines
      FileUtils.mkdir_p(File.dirname(@news_log))
      File.open(@news_log, "w") do |fh|
        fh.print lines.join("\n")
      end
    end

    def true_news news, old_news
      news - old_news
    end

    def swissmedicinfo_index(state)
      index = {}
      Languages.each do |x|
        lang = x.to_s.upcase
        url = "https://www.swissmedicinfo.ch/#{state}.aspx?Lang=#{lang}"
        # LogFile.debug "swissmedicinfo_index #{url}"
        home = @agent.get(url)
        home.body
        names = {}
        home.search("table").each do |table|
          _names = []
          typ = "PI"
          typ = "FI" if /FI_/.match?(table.attributes["id"].value)
          trs = table.search("tr")
          trs.each_with_index do |tr, idx|
            tds = tr.search("td")
            next unless tds.first && tds.last
            _names << [tds.first.text, tds.last.text]
          end

          names[typ.downcase.intern] = _names.sort.reverse
        end

        index[lang.downcase.intern] = names
      end
      index
    end

    def textinfo_swissmedicinfo_index
      setup_default_agent
      index = {}
      %w[NewTexts UpdatedTexts].each do |state|
        index[state.downcase.intern] = swissmedicinfo_index(state)
      end
      index
    end

    def self.match_iksnr
      /Zulassungsnummer[^\d]*([\d’ ]+).*(Wo|Packungen)/m
    end

    def self.find_iksnr_in_string(string, iksnr)
      nr = + ""
      string.each_char { |char|
        nr << char if char >= "0" and char <= "9"
        if char.eql?(" ") or char.eql?(",")
          nr.eql?(iksnr) ? break : nr = ""
        end
      }
      nr
    end

    def get_aips_download_xml(file = nil)
      if file
        content = IO.read(file)
        LogFile.debug("Read #{content.length} bytes from #{file}")
        FileUtils.mkdir_p File.dirname(@aips_xml)
        File.write(@aips_xml, content)
        return @aips_xml
      end
      setup_default_agent
      url = "https://download.swissmedicinfo.ch"
      dir = File.join(ODDB::WORK_DIR, "xml")
      FileUtils.mkdir_p dir
      name = "swissmedicinfo"
      zip = File.join(dir, "#{name}.zip")
      response = nil
      LogFile.debug("Get XML from #{url}")
      5.times do |idx|
        if home = @agent.get(url)
          form = home.form_with(id: "Form1")
          bttn = form.button_with(name: "ctl00$MainContent$btnOK")
          if page = form.submit(bttn)
            form = page.form_with(id: "Form1")
            begin
              bttn = form.button_with(name: "ctl00$MainContent$BtnYes")
              response = form.submit(bttn)
              break
            rescue
              sleep(1)
              LogFile.debug "Unable to fetch #{url} tried  #{idx}"
              next
            end
          end
        end
      end
      if response
        tmp = File.join(dir, name + ".tmp.zip")
        response.save_as(tmp)
        FileUtils.mv(tmp, zip)
        LogFile.debug("Calling Zip::File")
        daily_name = nil
        Zip::File.foreach(zip) do |entry|
          if /^AipsDownload_/iu.match?(entry.name)
            daily_name = entry.name
          end
        end
        LogFile.debug("Called Zip::File daily_name is #{daily_name}")
        File.delete(@aips_xml) if File.exist?(@aips_xml)
        cmd = "unzip -o -q -d #{File.dirname(@aips_xml)} #{zip}"
        system(cmd)
        FileUtils.cp(File.join(dir, daily_name), @aips_xml, preserve: true, verbose: true)
        size = File.exist?(@aips_xml) ? File.size(@aips_xml) / 1024 : 0
        mtime = File.exist?(@aips_xml) ? File.mtime(@aips_xml) : 0
        LogFile.debug("Saved XML to #{@aips_xml} #{File.exist?(@aips_xml)} #{size} kB of #{mtime}")
      end
    end

    def extract_images(html_file, type, lang, iksnrs, image_folder)
      if html_file && File.exist?(html_file)
        html = File.read(html_file)
        if /<img\s/.match?(html)
          images = Nokogiri::HTML(html).search("//img")
          images.each_with_index do |img, index|
            type, src = img.attributes["src"].to_s.split(",")
            # next regexp must be in sync with ext/fiparse/src/textinfo_hpricot.rb
            unless /^data:image\/(jp[e]?g|gif|png);base64$/.match?(type)
              @nonconforming_content << "#{iksnrs}: '#{@title}' with non conforming #{type} element x"
            end
            if type =~ /^data:image\/(jp[e]?g|gif|png|x-[ew]mf);base64$/
              FileUtils.mkdir_p(image_folder)
              file = File.join(image_folder, "#{index + 1}.#{$1}")
              LogFile.debug "Extracting #{iksnrs} image to #{file}"
              File.open(file, "wb") { |f|
                f.write(Base64.decode64(src))
                f.close
              }
            end
          end
        end
        nil
      end
    end

    def strange?(info)
      if info.nil? or !info.respond_to?(:name)
        :nil
      elsif info.name.to_s.length > 2700 # Maybe all chapters are in title ;(
        :invalid
      else
        false # expected
      end
    end
    XML_OPTIONS = {
      "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema",
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance"
    }

    def get_fi_pi_to_update(names, type)
      # names eg. { :de => 'Alacyl'}
      iksnrs = []
      infos = {}
      return [iksnrs, infos] unless @doc
      iksnrs_from_xml = nil
      name = ""
      [:de, :fr].each do |lang|
        next unless names[lang]
        name = names[lang]
        res = @iksnrs_meta_info.values.flatten.find { |x| x.title.eql?(name) && x.type.eql?(type) && x.lang.eql?(lang) }
        iksnrs_from_xml = res&.authNrs
        next unless iksnrs_from_xml
        LogFile.debug "#{iksnrs_from_xml} for #{iksnrs_from_xml} #{type}"
        iksnrs_from_xml.each do |iksnr|
          if @options[:reparse]
            LogFile.debug "reparse #{@options[:reparse]} #{meta_info}"
            @to_parse << meta_info
          else
            @fis_are_up2date << iksnr if type == "fachinfo"
            @pis_are_up2date << iksnr if type == "patinfo"
          end
        end
      end
    end

    def find_changed_new_items(keys, names, state)
      return unless keys && names && state
      keys.each_pair do |typ, type|
        next if names[:de].nil? or names[:de][typ].nil?
        names.each_pair do |lang, infos|
          infos[typ].each do |name, date|
            get_fi_pi_to_update({lang => name}, type)
          end
        end
      end
    end

    def title_and_keys_by(target)
      if target == :fi
        [target.to_s.upcase, {fi: "fachinfo"}]
      elsif target == :pi
        [target.to_s.upcase, {pi: "patinfo"}]
      else # both
        ["FI/PI", {fi: "fachinfo", pi: "patinfo"}]
      end
    end

    def report_sections_by(title)
      [
        ["\nNew/Updates #{title} from swissmedicinfo.ch"], # updated
        ["\nSkipped #{title} form swissmedicinfo.ch"],     # skipped
        ["\nInvalid #{title} from swissmedicXML"],         # invalid
        ["\nNot found #{title} in swissmedicXML"]         # notfound
      ]
    end

    # Error reasons
    Flagged_as_inactive = "oddb.registration('Zulassungsnummer').inactive? but has Zulassungsnummer in Packungen.xlsx"
    Reg_without_base_name = "oddb.registration has no method name_base"
    Mismatch_name_2_xls = "oddb.registration.name_base differs from Sequenzname in Packungen.xlsx"
    Iksnr_only_oddb = "oddb.registration.iksnr has no Zulassungsnummer in Packungen.xlsx"
    Iksnr_only_packages = "Zulassungsnummer from Packungen.xlsx is not in oddb.registrations('Zulassungsnummer')"
    FI_iksnrs_mismatched_to_aips_xml = "oddb.registration.fachinfo.iksnrs do not match authNrs from AipsDownload_latest.xml"
    PI_iksnrs_mismatched_to_aips_xml = "oddb.registration('iksnr').sequences['0x'].patinfo.descriptions['de'].iksnrs.to_s does not match entity authNrs from AipsDownload_latest.xml"
    Mismatch_reg_name_to_fi_name = "oddb.registration.name_base differs from oddb.registration.fachinfo.name_base"
    Mismatch_reg_name_to_pi_name = "oddb.registration.registration.name_base differs from name_base in registration('iksnr').sequences['0x'].patinfo.name_base"

    def log_error(iksnr, name_base, id, added_info, suppress_re_import = false)
      @error_reasons[id] += 1
      info = [id, iksnr, name_base]
      if added_info then (added_info.class == Array) ? info += added_info : info << added_info end
      @inconsistencies << info
      @iksnrs_to_import << iksnr unless suppress_re_import
      LogFile.debug "check_swissmedicno_fi_pi #{[id, iksnr, name_base]}"
    end

    def check_swissmedicno_fi_pi(options = nil, patinfo_must_be_deleted = false)
      @options = options if options
      LogFile.debug "found  #{@app.registrations.size} registrations and #{@app.sequences.size} sequences. Options #{options}. Having #{@iksnrs_meta_info.size} @iksnrs_meta_info"
      parse_aips_download if @iksnrs_meta_info.size == 0
      read_packages
      @error_reasons = {
        Flagged_as_inactive => 0,
        Reg_without_base_name => 0,
        Mismatch_name_2_xls => 0,
        Iksnr_only_oddb => 0,
        Iksnr_only_packages => 0,
        FI_iksnrs_mismatched_to_aips_xml => 0,
        PI_iksnrs_mismatched_to_aips_xml => 0,
        Mismatch_reg_name_to_fi_name => 0,
        Mismatch_reg_name_to_pi_name => 0
      }
      @inconsistencies = []
      @iksnrs_to_import = []
      @nrDeletes = []
      split_reg_exp = / |,|-/
      @packages.each_key { |iksnr|
        log_error(@packages[iksnr].iksnr, @packages[iksnr].name_base, Iksnr_only_packages, @packages[iksnr]) unless @app.registration(iksnr)
      }
      @app.registrations.each { |aReg|
        reg = aReg[1]
        iksnr_2_check = reg.iksnr
        xls_package_info = @packages[iksnr_2_check]

        log_error(reg.iksnr, reg.name_base, Flagged_as_inactive, xls_package_info) if reg.inactive? and xls_package_info
        next if reg.inactive? # we are only interested in the active registrations

        log_error(reg.iksnr, reg.name_base, Iksnr_only_oddb, xls_package_info, true) unless xls_package_info

        if xls_package_info and !xls_package_info.name_base.eql?(reg.name_base)
          log_error(reg.iksnr, reg.name_base, Mismatch_name_2_xls, xls_package_info) unless xls_package_info
        end

        if reg.fachinfo and reg.fachinfo.iksnrs
          fi_iksnrs = TextInfoPlugin.get_iksnrs_from_string(reg.fachinfo.iksnrs.to_s)
          xml_iksnrs = @fis_to_iksnrs[iksnr_2_check] || []
          if xml_iksnrs and fi_iksnrs != xml_iksnrs
            txt = ""
            xml_iksnrs.each { |id| txt += @app.registration(id) ? "#{id} #{@app.registration(id).name_base}, " : id + ", " }
            log_error(reg.iksnr, reg.name_base, FI_iksnrs_mismatched_to_aips_xml, txt)
            # TODO: update the fachinfo.iksnrs
          end
        end

        # Check first part of the fachinfo name (case-insensitive)
        if !reg.name_base
          log_error(reg.iksnr, reg.name_base, Reg_without_base_name, "")
        elsif reg.fachinfo and reg.fachinfo.name_base
          fi_name = reg.fachinfo.name_base.split(split_reg_exp)[0].downcase
          reg_name = reg.name_base.split(split_reg_exp)[0].downcase
          unless reg_name.eql?(fi_name)
            log_error(reg.iksnr, reg.name_base, Mismatch_reg_name_to_fi_name, reg.fachinfo.name_base)
            hasDefect = true
          end
        end

        foundPatinfo = false
        reg.sequences.each { |aSeq|
          seq = aSeq[1]
          hasDefect = false
          foundPatinfo = true if seq.patinfo and seq.patinfo.pointer
          next if seq.patinfo.nil? or seq.patinfo.name_base.nil?

          if seq.patinfo and seq.patinfo.descriptions["de"] # and seq.patinfo.descriptions['de'].iksnrs
            pi_iksnrs = TextInfoPlugin.get_iksnrs_from_string(seq.patinfo.descriptions["de"].iksnrs.to_s)
            pi_xml_iksnrs = @pis_to_iksnrs[iksnr_2_check]
            if pi_iksnrs and pi_xml_iksnrs and pi_iksnrs.sort.uniq != pi_xml_iksnrs
              log_error(reg.iksnr, reg.name_base, PI_iksnrs_mismatched_to_aips_xml, pi_xml_iksnrs)
              hasDefect = true
            end
          end

          # Check first part of the name (case-insensitive)
          if reg.name_base
            reg_name = reg.name_base.split(split_reg_exp)[0].downcase
            pi_name = seq.patinfo.name_base.split(split_reg_exp)[0].downcase
            unless reg_name.eql?(pi_name)
              log_error(reg.iksnr, reg.name_base, Mismatch_reg_name_to_pi_name, [reg_name, pi_name, seq.seqnr, seq.patinfo.pointer])
              hasDefect = true
            end
          end

          next if hasDefect == false and seq.patinfo.descriptions.nil?

          if hasDefect and patinfo_must_be_deleted
            @nrDeletes << seq.patinfo.pointer.to_s
            LogFile.debug "delete_patinfo_pointer #{@nrDeletes.size}: #{iksnr_2_check} #{reg.name_base} #{seq.seqnr} #{seq.patinfo.name_base} #{seq.patinfo.pointer}"
            @app.delete(seq.patinfo.pointer)
            @app.update(seq.pointer, patinfo: nil)
            seq.odba_isolated_store
          end
        }
      }
      LogFile.debug "found  #{@inconsistencies.size} inconsistencies.\nDeleted #{@nrDeletes.inspect} patinfos."
      LogFile.debug "#{@iksnrs_to_import.sort.uniq.size}/#{@iksnrs_to_import.size} iksnrs_to_import  are  \n#{@iksnrs_to_import.sort.uniq.join(" ")}"
      @iksnrs_to_import = @iksnrs_to_import.sort.uniq
      @packages = nil # free some memory if we want to import
      true # an update/import should return true or you will never send a report
    end

    def update_swissmedicno_fi_pi(options = {})
      LogFile.debug "#{options}"
      threads = []
      @iksnrs_to_import = []
      threads << Thread.new do
        @run_check_and_update = true
        check_swissmedicno_fi_pi(options, @run_check_and_update)
      end
      threads.map(&:join)
      @iksnrs_to_import = ["-99999"] if @iksnrs_to_import.size == 0
      # set correct options to force a reparse (reimport)
      @options[:reparse] = true
      @options[:download] = false
      LogFile.debug "finished"
      true # an update/import should return true or you will never send a report
    end

    private

    def info_is_unchanged(meta_info, cache_content)
      src = File.exist?(meta_info.html_file) ? IO.read(meta_info.html_file) : ""
      src.eql?(cache_content)
    end

    def found_matching_iksnr(iksnrs)
      matched_iksnrs = @options[:iksnrs] && ((@options[:iksnrs] & iksnrs).size > 0)
      @options[:iksnrs].nil? || (@options[:reparse] && @options[:iksnrs].size == 0) || matched_iksnrs
    end

    def get_textinfo(meta_info, iksnr)
      reg = @app.registration(iksnr)
      # Workaround for 55829 Ebixa
      if meta_info.type == "fi"
        reg.fachinfo if reg
      else
        begin
        reg.packages.each { |pack| @pack = pack; pack.delete_invalid_patinfo }
        rescue => error
          # fix some error in the database. see https://github.com/zdavatz/oddb.org/issues/386
          msg = "FIX_DB_ERROR #{iksnr} #{meta_info.lang} #{meta_info.title} #{error} #{@pack.odba_id}"
          LogFile.debug(msg)
          reg.sequences.values.collect{|seq| seq.packages.delete_if{|nr, pack| !pack.instance_of?(ODDB::Package)}}
          reg.odba_store
          reg.packages.each { |pack| @pack = pack; pack.delete_invalid_patinfo }
        end
        infoTxt = reg.packages.collect { |x| x.patinfo if x.respond_to?(:patinfo) }.compact.first
        # consider case where all packages have the same patinfo
        infoTxt ||= reg.sequences.values.collect { |x| x.patinfo if x.respond_to?(:patinfo) }.compact.first
        infoTxt
      end
    end

    public

    def parse_textinfo(meta_info, idx)
      return if meta_info.lang.eql?("it") || meta_info.lang.eql?("en") # we cannot parse correctly for italian/english
      return if report_multiple(meta_info)
      type = meta_info[:type].to_sym
      unless File.exist?(meta_info.cache_file)
        msg = "#{meta_info.iksnr} #{meta_info.lang} #{meta_info.title} #{meta_info.download_url}"
        LogFile.debug(msg)
        @invalid_html_url << msg
        return
      end
      cache_content = IO.read(meta_info.cache_file)
      if unchanged = info_is_unchanged(meta_info, cache_content)
        nr_uptodate = (type == :fi) ? @fis_are_up2date.size : @pis_are_up2date.size
      end
      @app.registration(meta_info.iksnr)
      if @options[:reparse]
        if meta_info.authNrs && found_matching_iksnr(meta_info.authNrs)
          LogFile.debug "at #{nr_uptodate}: #{type}  because reparse is demanded: #{@options[:reparse]} #{meta_info.authNrs}"
        else
          return
        end
      end
      if !(File.exist?(meta_info.cache_file) && File.size(meta_info.cache_file) > 0)
        LogFile.debug "Missing cache_file for #{meta_info.type} #{meta_info.lang} #{meta_info.authNrs} #{meta_info.cache_file}"
      end
      new_html = meta_info.cache_file
      textinfo_fi = nil
      reg = @app.registration(meta_info.iksnr)
      if reg.nil? || reg.sequences.size == 0 # Workaround for Ebixa problem
        LogFile.debug "must create #{meta_info.type} #{meta_info.lang} #{meta_info.authNrs} as no sequence found for reg #{reg.class}"
        reg = TextInfoPlugin.create_registration(@app, meta_info)
      end
      text_info = get_textinfo(meta_info, meta_info.iksnr)
      if !unchanged
        # LogFile.debug "#{new_html} does is not the same: #{meta_info.authNrs}"
      elsif @options[:reparse]
        LogFile.debug "reparse demanded via @options #{@options}"
      elsif found_matching_iksnr(meta_info.authNrs)
        true # nothing to do ??
      end
      # image_base, image_subfolder must be in sync with ext/fiparse/src/fiparse.rb and ext/fiparse/src/textinfo_hpricot.rb
      image_base = File.expand_path("./doc/resources/images")
      image_subfolder = File.join(type.to_s, meta_info.lang.to_s, "#{meta_info.iksnr}_#{meta_info.title[0, 10].gsub(/[^A-z0-9]/, "_")}")
      bytes = File.read("/proc/#{$$}/stat").split(" ").at(22).to_i
      mbytes = (bytes / (2**20)).to_i
      LogFile.debug "Checking #{meta_info.iksnr} #{type} #{meta_info.lang} unchanged #{unchanged} for #{File.basename(new_html)} using #{mbytes} MB (free #{getFreeMemoryInMB}) at #{idx}/#{@metas&.size}" unless unchanged
      if type == :fi
        if unchanged && !@options[:reparse] && reg && reg.fachinfo && text_info.descriptions.keys.index(meta_info.lang)
          LogFile.debug "#{meta_info.iksnr} at #{nr_uptodate}: #{type} #{new_html} unchanged #{new_html}" if defined?(Minitest)
          @fis_are_up2date << meta_info.iksnr unless @updated_fis.find{|x| x.match(meta_info.iksnr)}
          return
        end
        begin
          sanitized_html = sanitize_html_for_parsing(new_html)
          textinfo_fi ||= @parser.parse_fachinfo_html(sanitized_html, title: meta_info.title, image_folder: image_subfolder)
          update_fachinfo_lang(meta_info, {meta_info.lang => textinfo_fi})
        rescue => err
          # registration('66016').sequences.values.collect{|x| x.patinfo && x.patinfo['de'].class}
          LogFile.debug "#{err} skip #{meta_info.iksnr} #{meta_info.lang} unchanged #{File.basename(new_html)} using #{mbytes} MB #{err}"
          LogFile.debug "odba_id #{text_info.odba_id} #{err.backtrace[0..9].join("\n")}"
          LogFile.debug "backtrace two  #{err.backtrace[-10..-1].join("\n")}"
          @failures.push "IKSNR: #{meta_info.iksnr} FI unable to parse #{err.message} #{new_html} #{err.backtrace[0..8].join("\n")}"
          return nil
        end
      elsif type == :pi
        begin  # Workaround and fix a problem in the database
          if text_info && text_info.respond_to?(:descriptions)
            text_info.descriptions.keys
          end
          if unchanged && !@options[:reparse] && reg && text_info && text_info.respond_to?(:descriptions) && text_info.descriptions.keys.index(meta_info.lang)
            @pis_are_up2date << meta_info.iksnr
            return
          end
        rescue => err # SystemStackError => err
          LogFile.debug "SystemStackError? #{err} skip #{meta_info.iksnr} #{meta_info.lang} unchanged #{File.basename(new_html)} using #{mbytes} MB #{err}"
          @failures.push "IKSNR: #{meta_info.iksnr} #{text_info.odba_id} PI unable to parse #{err.message} #{new_html} #{err.backtrace[0..4].join("\n")}"
          reg.sequences.values.collect { |x|
            x.patinfo = nil
            x.odba_store
          }
        end
        startTime = Time.now
        begin
          sanitized_html = sanitize_html_for_parsing(new_html)
          textinfo_pi = @parser.parse_patinfo_html(sanitized_html, title: meta_info.title, image_folder: image_subfolder)
        rescue => err
          LogFile.debug "SystemStackError? #{err} skip #{meta_info.iksnr} #{meta_info.lang} unchanged #{File.basename(new_html)} using #{mbytes} MB #{err}"
          @failures.push "IKSNR: #{meta_info.iksnr} PI unable to parse #{err.message} #{new_html} #{err.backtrace[0..8].join("\n")}"
          textinfo_pi
        end
        time2parse = Time.now - startTime
        LogFile.debug "Took #{time2parse} to parse #{new_html}" if time2parse > 1.0
        update_patinfo_lang(meta_info, textinfo_pi)
        if textinfo_pi.respond_to?(:name)
          textinfo_pi.name
        end
        nil
      end
      # Extract image to path generated from XML title,
      # This should be the "correct" path
      extract_images(new_html, meta_info.type, meta_info.lang, meta_info.authNrs, File.join(image_base, image_subfolder))
      reg&.odba_store
      GC.start
    end
    # In text_info.rb, fügen Sie diese neue Methode hinzu (z.B. nach der parse_textinfo Methode):

def sanitize_html_for_parsing(html_file)
  return html_file unless File.exist?(html_file)
  content = File.read(html_file, mode: 'rb').force_encoding('UTF-8')
  
  # 1. BREAK THE GIANT LINE IMMEDIATELY (Including Header)
  # Added: </title>, />, and </style> to ensure the header isn't one giant line.
  # Added: <body> to ensure the transition to the content is clean.
  sanitized = content.gsub(/(<\/title>|\/>|<\/style>|<\/p>|<\/head>|<\/tr>|<\/table>|<\/div>|<body>)/i, "\\1\n")
  
  # 2. REMOVE TARGETED PARAGRAPHS SAFELY
  # Removed /m so it only stays within one line.
  # Catches ▼ symbol and � (Unicode replacement character for corrupted encoding)
  sanitized = sanitized.gsub(/<p[^>]*>[^<]*?(▼|▼|�).*?<\/p>/i, "")
  
  # 3. CLEANUP CHARACTERS
  sanitized = sanitized.gsub(/[·•∙‧⋅§‒–—―]/, "-") # bullets and dashes
  sanitized = sanitized.gsub(/[\u00A0\u202F]/, " ") # non-breaking spaces
  sanitized = sanitized.gsub(/[\u200B\u200C\u200D\uFEFF]/, "") # zero-width characters
  sanitized = sanitized.gsub(/®/, "") # registered trademark

  # Normalize all umlauts to HTML entities for consistency
  sanitized = sanitized.gsub(/ä/, '&auml;')
                     .gsub(/ö/, '&ouml;')
                     .gsub(/ü/, '&uuml;')
                     .gsub(/Ä/, '&Auml;')
                     .gsub(/Ö/, '&Ouml;')
                     .gsub(/Ü/, '&Uuml;')
                     .gsub(/ß/, '&szlig;') 
  
  # Replace French/German quotation marks 
  sanitized = sanitized.gsub(/(&nbsp;|\s)*(&laquo;|«)(&nbsp;|\s)*/, ' "')
                       .gsub(/(&nbsp;|\s)*(&raquo;|»)(&nbsp;|\s)*/, '" ')
  
  # 4. NORMALIZE LINE ENDINGS
  sanitized = sanitized.gsub(/\r\n?/, "\n")
  
  # Only write back if changed
  if sanitized != content
    File.write(html_file, sanitized, mode: 'wb:utf-8')
    LogFile.debug "Sanitized #{html_file}: Fully de-minified header and body."
  end
  html_file
end

    def set_html_and_cache_name(meta_info)
      meta_info.iksnr = meta_info.authNrs.first unless meta_info.iksnr
      meta_info.cache_file = File.join(@html_cache, File.basename(meta_info.download_url))
      base_name = "#{meta_info.title.gsub(CharsNotAllowedInBasename, "_")}.html"
      meta_info.html_file = File.join(@details_dir, meta_info.type, meta_info.lang, "#{meta_info.iksnr}_#{base_name}")
    end

    def handle_chunk(chunk)
      return nil unless chunk.size > 100
      chunk += " </MedicinalDocumentsBundle></MedicinalDocumentsBundle>"
      unless /<MedicinalDocumentsBundles/.match?(chunk)
        chunk = %(<?xml version="1.0" encoding="utf-8"?>
<MedicinalDocumentsBundles>) + chunk
      end
      doc = Nokogiri(chunk)
      meta_infos = []
      meta_info = SwissmedicMetaInfo.new
      type = doc.at("Type").text
      domain = doc.at("Domain").text
      return meta_infos if /Veterinary/.match?(domain)
      if type.eql?("SmPC")
        meta_info.type = "fi"
      elsif type.eql?("PIL")
        meta_info.type = "pi"
      else
        return meta_infos
      end
      meta_info.authNrs = doc.search("RegulatedAuthorization/Identifier").children.collect { |x| x.text }
      meta_info.informationUpdate = doc.at("Date").text
      meta_info.authHolder = doc.at("Holder/Name").text
      languages = {}
      doc.search("AttachedDocument").collect { |x| x }.each do |aDoc|
        aLang = {}
        lang = aDoc.at("Language").text
        aLang [:lang] = lang
        aLang [:title] = aDoc.at("Description").text
        aLang [:start] = aDoc.at("Period/Start").text
        aDoc.search("DocumentReference/Url").find_all do |x|
          url = x.children.first.text
          if /.html/.match?(url)
            aLang[:url] = url
            languages[lang] = aLang
          end
        end
      end
      # Missing are at the moment
      # substances
      # atcCode
      languages.each do |lang, infoDoc|
        meta_info.lang = lang
        meta_info.download_url = infoDoc[:url]
        meta_info.title = infoDoc[:title]
        infoTxt = "#{(meta_info.authNrs.size > 0) ? meta_info.authNrs.first : meta_info.iksnr}_#{meta_info.type}_#{meta_info.lang}"
        @iksnr_lang_type[infoTxt] = meta_info.title unless @iksnr_lang_type[infoTxt]
        set_html_and_cache_name(meta_info)
        if File.exist?(meta_info.cache_file)
          @iksnrs_from_aips << meta_info.iksnr if meta_info.iksnr
          @duplicate_entries << infoTxt + ': "' + @iksnr_lang_type[infoTxt] + '"' # was first
          @duplicate_entries << infoTxt + ': "' + meta_info.title + '"' # was duplicate
        end
        meta_info.authNrs.each do |iksnr|
          meta_info.iksnr = iksnr
          meta_infos << meta_info.clone
        end
      end
      meta_infos
    end

    public

    def parse_aips_download(aips_file = @options[:html_file] || @aips_xml)
      LogFile.debug "#{aips_file} from @options #{@options}"
      start_time = Time.now
      @iksnrs_from_aips = []
      @iksnr_lang_type = {}
      # FileUtils.rm_rf(@details_dir, verbose: true) # spart etwas Zeit und lässt alte Dokus zu
      FileUtils.makedirs(@details_dir, verbose: true)
      unless File.exist?(aips_file)
        LogFile.debug("Did not find #{aips_file}")
        return
      end
      content = IO.read(aips_file)
      mtime = File.mtime(aips_file).to_datetime.strftime("%Y-%m-%d %H:%M:%S")
      mBytes = content.size / 1024 / 1024
      LogFile.debug "read #{aips_file} #{mtime} #{mBytes} MB"
      content.split("</MedicinalDocumentsBundle>").each_with_index do |chunk, idx|
        meta_infos = handle_chunk(chunk)
        meta_infos&.each do |meta_info|
          iksnr = meta_info.iksnr
          if meta_info.iksnr.length != 5
            msg = "Patching as IKSNR length #{meta_info.iksnr} #{meta_info.lang} #{meta_info.iksnr.length}"
            LogFile.debug(msg)
            @wrong_meta_tags << msg
            iksnr = meta_info.iksnr = meta_info.iksnr[0..4]
          end
          key = [iksnr, meta_info.type, meta_info.lang]
          key_string = "#{iksnr}_#{meta_info.type}_#{meta_info.lang}"
          @iksnrs_meta_info[key] ||= []
          @iksnrs_meta_info[key] << meta_info.clone
          reg = @app.registration(iksnr)
          if reg
            @iksnrs_meta_info[key].each do |info|
              if @iksnrs_meta_info[key].size > 1
                unless info.authHolder.eql?(reg.company.to_s)
                  nrEntries = @iksnrs_meta_info[key].find_all { |x| x.authHolder.eql?(reg.company.to_s) }.size
                  puts "Mismatching authHolder #{iksnr} meta #{meta_info.authHolder} != db #{reg.company}. Has #{nrEntries}/#{@iksnrs_meta_info[key].size} entries" if DEBUG_FI_PARSE
                  if nrEntries >= 1
                    @iksnrs_meta_info[key].delete_if { |x| !x.authHolder.eql?(reg.company.to_s) }
                    @duplicate_entries.delete_if { |x| x.index(key_string) == 0 } if nrEntries == 1
                    puts "Mismatching authHolder #{iksnr}. Has now #{@iksnrs_meta_info[key].size} entries" if DEBUG_FI_PARSE
                  elsif DEBUG_FI_PARSE
                    puts "Could not delete Mismatching authHolder #{iksnr}. Still #{@iksnrs_meta_info[key].size} entries"
                  end
                  puts "Mismatching authHolder #{iksnr}. Has #{@duplicate_entries.find_all { |x| x.index(key_string) == 0 }.size} @duplicate_entries" if DEBUG_FI_PARSE
                end
              end
            end
          end
        end
      end
      @companies ||= @options[:companies]
      duration = (Time.now - start_time).to_i
      LogFile.debug "#{Time.now}: created #{@iksnrs_meta_info.size} @iksnrs_meta_info took #{duration} seconds"
      create_missing_registrations
    end

    private

    def get_entries_to_update
      @to_parse = []
      @iksnrs_meta_info.values.flatten.each do |meta_info|
        if @options[:target] == :both || @options[:target].to_s.eql?(meta_info.type)
          if @options[:companies] && @options[:companies].size > 0
            @to_parse << meta_info if @options[:companies]&.downcase&.match(meta_info.authHolder)
          elsif @options[:iksnrs] && @options[:iksnrs].size > 0
            found = @options[:iksnrs].find { |x| meta_info.authNrs.index(x) }
            @to_parse << meta_info if found
          else
            next unless Languages.find{|l| l.to_s.eql?(meta_info.lang)}
            @to_parse << meta_info
          end
        end
      end
    end

    def get_swissmedicinfo_changed_items(index, target)
      started = Time.now
      title, keys = title_and_keys_by(target)
      @updated, @skipped, @invalid, @notfound = report_sections_by(title)
      @doc = Nokogiri::XML(IO.read(@aips_xml))
      index.each_pair do |state, names|
        find_changed_new_items(keys, names, state)
      end
      finished = Time.now
      @took = ((finished - started) * 10).to_i
      @doc = nil
    end

    public

    def import_swissmedicinfo(options = nil)
      @options = options if options
      $stdout.sync = true
      @specify_barcode_to_text_info = {}
      @specify_barcode_to_text_info = YAML.load_file(Override_file) if File.exist?(Override_file)
      read_packages
      @options[:target] ||= :both
      threads = []
      if @options[:download] != false
        get_aips_download_xml
      end
      LogFile.debug "Parsing @options[:newest] #{@options[:newest]} #{@options[:newest] != false}"
      @to_parse = []
      if FileUtils.uptodate?(@meta_yml, [@aips_xml, @zip_file])
        startTime = Time.now
        @iksnrs_meta_info = YAML.load_file(@meta_yml, aliases: true, permitted_classes: [OpenStruct, Struct::SwissmedicMetaInfo, Symbol])
        duration = Time.now - startTime
        LogFile.debug "Loaded #{@iksnrs_meta_info.size} items from #{@meta_yml}, took #{sprintf("%5.2f", duration)} seconds"
      else
        get_aips_download_xml(@aips_xml)
        parse_aips_download(@aips_xml) # to get all meta information
        download_all_html_zip
        save_meta_and_xref_info
      end
      get_entries_to_update

      LogFile.debug "After parse_aips_download we have  #{@to_parse.size} items to parse. Having #{@iksnrs_meta_info.size} meta items. #{@options[:newest]}"

      if @options[:newest]
        index = nil
        # @to_parse = [] # Reset it to empty, as we want to add only the changed items!
        threads << Thread.new do
          index = textinfo_swissmedicinfo_index
          get_swissmedicinfo_changed_items(index, @options[:target])
        end
        threads.map(&:join)
        # report
        date = (date ? " - #{date}" : "")
        @to_parse.each do |meta|
          text_info = get_textinfo(meta, meta.iksnr)
          unless text_info
            msg = "  #{(meta.type == "fi") ? "Fachinfo" : "Patinfo "} - #{meta.lang.to_s.upcase} - #{meta.title}#{date}#{meta.authNrs}"
            @updated << msg
            LogFile.debug "msg #{msg}"
          end
        end
      end
      LogFile.debug "must parse @to_parse #{@to_parse.size}  FI/PIs"
      LogFile.debug "must parse @iksnrs_meta_info #{@iksnrs_meta_info.size} FI/PIs"
      if @options[:reparse]
        iksnrs_to_parse = if @options[:all]
          @iksnrs_meta_info.values.flatten.collect { |x| x.iksnr }.uniq.sort
        else
          @options[:iksnrs]
        end
        @metas = @iksnrs_meta_info.values.flatten.select do |x|
          iksnrs_to_parse.index(x.iksnr) && (@options[:target].eql?(:both) || @options[:target].eql?(x.type.to_sym))
        end
      elsif @options[:target]
        @metas = @iksnrs_meta_info.values.flatten.select { |x| @options[:target].eql?(x.type.to_sym) }
      else
        @metas = @iksnrs_meta_info.values.flatten
      end
      @metas = @metas.sort_by { |x| x.iksnr }
      @metas.each_with_index do |meta_info, idx|
        if @stop_on_low_memory && getFreeMemoryInMB < 1024 # < 512 was not enough!
          LogFile.debug "Stopping as only  #{getFreeMemoryInMB} MB memory left"
          break
        end
        ODBA.cache.transaction do
          parse_textinfo(meta_info, idx)
        rescue => error
          puts error
          puts error.backtrace[0..10].join("\n")
          raise error # to trigger rollback of transaction
        end
      end
      if @options[:download] != false
        postprocess
      end
      true # report
    end
  end
end
