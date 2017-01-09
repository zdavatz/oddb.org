#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TextInfoPlugin -- oddb.org -- 22.05.2013 -- yasaka@ywesee.com
# ODDB::TextInfoPlugin -- oddb.org -- 30.01.2012 -- mhatakeyama@ywesee.com 
# ODDB::TextInfoPlugin -- oddb.org -- 17.05.2010 -- hwyss@ywesee.com 
require 'date'
require 'drb'
require 'mechanize'
require 'fileutils'
require 'config'
require 'thread'
require 'zip'
require 'nokogiri'
require 'plugin/plugin'
require 'plugin/refdata'
require 'model/fachinfo'
require 'model/patinfo'
require 'view/rss/fachinfo'
require 'util/logfile'
require 'rubyXL'

module ODDB

  SwissmedicMetaInfo = Struct.new("SwissmedicMetaInfo", :iksnr, :authNrs, :atcCode, :title, :authHolder, :substances, :type, :lang,
                                  :informationUpdate, :refdata, :xml_file, :same_content_as_xml_file)
  class TextInfoPlugin < Plugin
    attr_reader :updated_fis, :updated_pis, :problematic_fi_pi, :missing_override_file
    Languages = [:de, :fr] # TODO: , :it
    CharsNotAllowedInBasename = /[^A-z0-9,\s\-]/
    Override_file = File.join(Dir.pwd, 'etc',  defined?(Minitest) ? 'barcode_minitest.yml' : 'barcode_to_text_info.yml')
    DEBUG_FI_PARSE = !!ENV['DEBUG_FI_PARSE']
    def initialize app, opts={:newest => true}
      super(app)
      @options = opts
      @parser = DRb::DRbObject.new nil, FIPARSE_URI
      @dirs = {
        :fachinfo => File.join(ODDB.config.data_dir, 'html', 'fachinfo'),
        :patinfo  => File.join(ODDB.config.data_dir, 'html', 'patinfo'),
      }
      @aips_xml   = File.join(ODDB.config.data_dir, 'xml', 'AipsDownload_latest.xml')
      @details_dir =  File.join(ODDB.config.data_dir, 'details')
      @updated_fis = []
      @corrected_fis = []
      @corrected_pis = []
      @updated_pis = []
      @ignored_pseudos = 0
      @session_failures = 0
      @up_to_date_fis = 0
      @up_to_date_pis = 0
      @iksless = Hash.new{|h,k| h[k] = [] }
      @unknown_iksnrs = {}
      @new_iksnrs = {}
      @failures = []
      @download_errors = []
      @companies = []
      @nonconforming_content = []
      @wrong_meta_tags = []
      @news_log = File.join ODDB.config.log_dir, 'textinfos.txt'
      @problematic_fi_pi = File.join ODDB.config.log_dir, 'problematic_fi_pi.lst'
      @missing_override_file = File.join ODDB.config.log_dir, 'missing_override.lst'
      @title  = ''       # target fi/pi name
      @format = :swissmedicinfo
      @target = :both
      @search_term = []
      # FI/PI names
      @updated  = []
      @skipped  = []
      @invalid  = []
      @notfound = []
      @iksnr_to_fi = {}
      @iksnr_to_pi = {}
      @duplicate_entries = []
      @fi_without_atc_code = []
      @fi_atc_code_missmatch = []
      @target_keys = Util::COLUMNS_JULY_2015
      @iksnrs_meta_info = {}
      @missing_override ||= []
    end
    def save_info type, name, lang, page, flags={}
      dir = File.join @dirs[type], lang.to_s
      FileUtils.mkdir_p dir
      name_base = name.gsub(/[\/\s\+:]/, '_')
      tmp = File.join dir, name_base + '.tmp.html'
      page.save tmp
      path = File.join dir, name_base + '.html'
      if File.exist?(path) && FileUtils.compare_file(tmp, path)
        flags.store lang, :up_to_date
      end
      FileUtils.mv tmp, path
      path
    end

    def puts_sync(msg)
      $stdout.puts Time.now.to_s + ': ' + msg; $stdout.flush
    end
    IKS_Package = Struct.new("IKS_Package", :iksnr, :seqnr, :name_base)  
    def read_packages # adapted from swissmedic.rb
      latest_name = File.join ARCHIVE_PATH, 'xls', 'Packungen-latest.xlsx'
      LogFile.debug "read_packages found latest_name #{latest_name}"
      @packages = {}
      @veterinary_products = {}
      @target_keys = Util::COLUMNS_JULY_2015
      RubyXL::Parser.parse(latest_name)[0][4..-1].each do |row|
        next unless row[@target_keys.keys.index(:iksnr)].to_i and
            row[@target_keys.keys.index(:seqnr)].to_i and
            row[@target_keys.keys.index(:production_science)].to_i
        next if (row[@target_keys.keys.index(:production_science)] == 'Tierarzneimittel')
        iksnr = "%05i" % row[@target_keys.keys.index(:iksnr)].to_i
        seqnr = "%03i" % row[@target_keys.keys.index(:seqnr)].to_i
        name_base = row[@target_keys.keys.index(:name_base)].value.to_s
        @packages[iksnr] = IKS_Package.new(iksnr, seqnr, name_base)
      end
      LogFile.debug "read_packages found latest_name #{latest_name} with #{@packages.size} packages"
    end
    def postprocess
      update_rss_feeds('fachinfo.rss', @app.sorted_fachinfos, View::Rss::Fachinfo)
      update_yearly_fachinfo_feeds
    end

    def TextInfoPlugin::replace_textinfo(app, new_ti, container, type) # type must be :patinfo or :fachinfo
      return unless type.is_a?(Symbol)
      old_ti = container.send(type)
      if old_ti
        Languages.each do |lang|
          if old_ti.descriptions && desc = new_ti.descriptions[lang]
            msg = "replace_textinfo: #{container.class} #{type}lang #{lang} #{new_ti.descriptions[lang].to_s.split("\n")[0..2]}"
            LogFile.debug msg; puts(msg)
            old_ti.descriptions[lang] = desc
            old_ti.descriptions.odba_isolated_store
          end
        end
        res = app.update(old_ti.pointer, {:descriptions => old_ti.descriptions})
        LogFile.debug "replace_textinfo updated #{container.pointer} #{container.pointer} type #{type} #{new_ti.pointer}"
      else
        res = app.update(container.pointer, {type => new_ti.pointer})
        LogFile.debug "replace_textinfo updated #{container.pointer} type #{type}" # does not work always old_ti.oid #{old_ti.oid} new_ti.oid #{new_ti.oid}"
      end
      res
    end

    def TextInfoPlugin::add_change_log_item(text_item, old_text, new_text, lang)
      msg = "add_change_log_item: update #{text_item.class} lang #{lang} #{text_item.class} #{old_text.split("\n")[0..2]} -> #{new_text.split("\n")[0..2]}"
      LogFile.debug msg
      text_item.add_change_log_item(old_text, new_text)
      text_item.odba_store
    end

    def TextInfoPlugin::store_fachinfo(app, reg, fis)
      existing = reg.fachinfo
      if existing
        lang = fis.keys.first
        old_text = eval("existing.#{lang}.text")
        updated_fi = app.update reg.fachinfo.pointer, fis
        if old_text
          text_item = eval("updated_fi.#{lang}")
          new_text = text_item.text
          LogFile.debug "store_fachinfo: #{reg.iksnr} #{fis.keys} #{existing.pointer} eql? #{old_text.eql?(new_text)}"
          unless old_text.eql?(new_text)
            TextInfoPlugin::add_change_log_item(text_item, old_text, new_text, lang)
          end
        else
          LogFile.debug "store_fachinfo: #{reg.iksnr} #{fis.keys} #{existing.pointer} no old_text"
        end
        updated_fi
      else
        fachinfo = app.create_fachinfo
        LogFile.debug "store_fachinfo: #{reg.iksnr} #{fis.keys} create_fachinfo #{fachinfo.pointer}"
        updated_fi = app.update fachinfo.pointer, fis
      end
    end
    def store_orphaned iksnr, info, point=:orphaned_fachinfo
      if info
        pointer = Persistence::Pointer.new point
        store = {
          :key       => iksnr,
          :languages => info,
        }
        @app.update pointer.creator, store
      end
    end

    def ensure_correct_atc_code(app, registration, atcFromFI)
      iksnr = registration.iksnr
      unless atcFromFI
        @fi_without_atc_code << iksnr
        LogFile.debug "ensure_correct_atc_code iksnr #{iksnr} atcFromFI is nil"
      end
      found = @iksnrs_meta_info.find{|key, val| key[0] == iksnr && val.first.atcCode}
      atcFromXml = nil
      atcFromXml = found.flatten.find{ |x| x.is_a?(SwissmedicMetaInfo) }.atcCode if found
      atcFromRegistration = nil
      atcFromRegistration = registration.sequences.values.first.atc_class.code if registration.sequences.values.first and registration.sequences.values.first.atc_class

      if atcFromFI == atcFromXml and atcFromRegistration and atcFromFI == atcFromRegistration
        LogFile.debug "ensure_correct_atc_code iksnr #{iksnr} atcFromFI #{atcFromFI} atcFromXml #{atcFromXml} matched and found"
        return # no need to change anything
      end
      if atcFromFI == atcFromXml and not atcFromRegistration
        return unless atcFromFI # in this case we cannot correct it!
        atc_class = app.atc_class(atcFromFI)
        return if atc_class.is_a?(ArgumentError)
        atc_class ||= app.create_atc_class(atcFromFI)
        atc_class.pointer ||= Persistence::Pointer.new([:atc_class, atcFromFI])
        return if atc_class.is_a?(ArgumentError)
        registration.sequences.values.each{
          |sequence|
            LogFile.debug "ensure_correct_atc_code iksnr #{iksnr} save atcFromFI #{atcFromFI} in sequence #{iksnr} sequence #{sequence.seqnr} atc_class #{atc_class} #{atc_class.oid}"
            res = app.update(sequence.pointer, { :atc_class => atc_class}, :swissmedic_text_info)
            atc_class.odba_store
            sequence.atc_class = atc_class
            sequence.odba_isolated_store
            registration.odba_isolated_store
        }
        return
      end
      if  atcFromFI == atcFromXml and atcFromFI != atcFromRegistration
        # res = app.update(registration.pointer, { :atc_class => atc_class}, :swissmedic_text_info)
        LogFile.debug "ensure_correct_atc_code iksnr #{iksnr} atcFromFI and xml #{atcFromFI} differ from registration #{atcFromRegistration}. No action"
        return
      end
      if atcFromFI and atcFromXml and atcFromFI != atcFromXml
        @fi_atc_code_missmatch << "#{iksnr} FI-html: #{atcFromFI} xml: #{atcFromXml}"
        LogFile.debug "ensure_correct_atc_code iksnr #{iksnr} save atcFromFI #{atcFromFI} (not same as atcFromXml #{atcFromXml}). No action"
        return
      else
        atc_code = atcFromFI
        atc_code ||= atcFromXml
        atc_class = app.atc_class(atc_code)
        return unless atc_class
        atc_class.pointer ||= Persistence::Pointer.new([:atc_class, atc_code])
        registration.sequences.values.each{
          |sequence|
            LogFile.debug "ensure_correct_atc_code iksnr #{iksnr} save atc_code #{atc_code} (not same as atcFromXml #{atcFromXml}) in sequence #{sequence.seqnr}  atc_class #{atc_class}"
            res = app.update(sequence.pointer, { :atc_class => atc_class}, :swissmedic_text_info)
            sequence.odba_store
        }
        return
      end
      LogFile.debug "ensure_correct_atc_code iksnr #{iksnr} atcFromFI #{atcFromFI} atcFromXml #{atcFromXml}. What went wrong"
    end

    def update_fachinfo_lang(meta_info, fis, fi_flags = {})
      LogFile.debug "update_fachinfo_lang #{meta_info.iksnr} #{meta_info}"
      unless meta_info.authNrs && meta_info.authNrs.size > 0
        @iksless[:fi].push meta_info.title
        return
      end
      begin
        if reg = @app.registration(meta_info.iksnr)
          ## identification of Pseudo-Fachinfos happens at download-time.
          #  but because we still want to extract the iksnrs, we just mark them
          #  and defer inaction until here:
          unless fi_flags[:pseudo] || fis.empty?
            LogFile.debug  "update_fachinfo_lang #{meta_info.title} iksnr #{meta_info.iksnr} store_fachinfo #{fi_flags} #{fis.keys} ATC #{meta_info.atcCode}"
            unless meta_info.iksnr.to_i == 0
              fachinfo ||= TextInfoPlugin::store_fachinfo(@app, reg, fis)
              TextInfoPlugin::replace_textinfo(@app, fachinfo, reg, :fachinfo)
              ensure_correct_atc_code(@app, reg, meta_info.atcCode)
              @updated_fis << "  #{meta_info.iksnr} #{fis.keys} #{reg.name_base}"
            end
          end
        else
          LogFile.debug "update_fachinfo_lang #{meta_info.title} iksnr #{meta_info.iksnr} store_orphaned"
          store_orphaned meta_info.iksnr, fis, :orphaned_fachinfo
          @unknown_iksnrs.store meta_info.iksnr, meta_info.title
        end
      rescue RuntimeError => err
        @failures.push err.message
        []
      end
    end

   def store_patinfo_for_one_packages(package, lang, patinfo_lang)
      package.patinfo = @app.create_patinfo unless package.patinfo
      msg = "#{package.pointer} #{lang} #{package.patinfo.oid} #{package.patinfo.pointer} #{patinfo_lang.to_s.split("\n")[0..1]}"
      LogFile.debug msg; puts msg
      eval("package.patinfo.descriptions['#{lang}']= patinfo_lang")
      package.patinfo.odba_store
      package.odba_store
      @corrected_pis << "#{package.iksnr} #{lang} #{package.name}"
    end

    def store_patinfo_for_all_packages(iksnr, lang, patinfo_lang)
      reg = @app.registration(iksnr)
      # Remove possible package specific patinfos
      reg.each_package do |package|
          package.instance_eval("@patinfo = nil")
      end
      reg.odba_store

      # existing = reg.sequences.collect{ |seqnr, seq| seq.patinfo }.compact.first
      existing = reg.sequences.collect{ |seqnr, seq| seq.patinfo }.compact.first
      if existing
        languages = existing.descriptions
        LogFile.debug "store_patinfo update for reg.iksnr #{reg.iksnr} lang #{lang} existing oid #{existing.oid} #{languages[lang].to_s.split("\n")[0..1]}"
        LogFile.debug "store_patinfo update for reg.iksnr #{reg.iksnr} lang #{lang} new #{patinfo_lang.to_s.split("\n")[0..1]}"
        languages[lang] = patinfo_lang
        ptr = existing.pointer
        patinfo = @app.update ptr, languages
        patinfo.odba_store
      else
        patinfo = @app.create_patinfo
        patinfo.descriptions # create descriptions by default
        patinfo.descriptions[lang] = patinfo_lang
        reg.sequences.values.first.patinfo = patinfo
        patinfo.odba_store
        reg.sequences.values.first.odba_store
        reg.odba_store
        LogFile.debug "store_patinfo #{patinfo.pointer} none for reg.iksnr #{reg.iksnr} new oid #{patinfo.oid} #{ patinfo_lang.to_s.split("\n")[0..2]}"
      end
      reg.each_sequence do |seq|
        if !seq.pdf_patinfo.nil? and !seq.pdf_patinfo.empty?
          seq.pdf_patinfo = ''
          @app.update(seq.pointer, {:pdf_patinfo => ''}, :text_info)
          seq.odba_isolated_store
        end
        seq.patinfo = patinfo
        seq.odba_store
      end
      reg.odba_store
      @corrected_pis << "#{iksnr} #{lang} #{reg.name_base}"
    end

    def update_patinfo_lang(meta_info, pis)
      LogFile.debug "update_patinfo_lang #{meta_info} #{pis.keys}"
      unless meta_info.authNrs && meta_info.authNrs.size > 0
        @iksless[:pi].push meta_info.title
        return
      end
      # return unless @options[:reparse] && @options[:newest]
      if pis.size != 1 || !pis.values.first
        LogFile.debug "We expect pis.size to be 1 and valid, but it is #{pis}"
        return
        exit 3
      end
      begin
        if reg = @app.registration(meta_info.iksnr)
          lang = meta_info.lang
          key = [ meta_info.iksnr, meta_info.type, meta_info.lang ]
          return if @iksnrs_meta_info[key].size == 0
          if  @iksnrs_meta_info[key].size == 1 # Same PI for all packages
            pis.each do |lang, patinfo_lang|
              store_patinfo_for_all_packages(meta_info.iksnr, lang, patinfo_lang)
              msg = "#{meta_info.iksnr} #{meta_info.lang}: #{meta_info.title}"
              @updated_pis << "  #{msg}"
            end
          else # more than 1 PI for iksnr found
            pis.each do|lang, patinfo_lang|
              next unless lang.to_s.eql?(meta_info.lang)
              msg = "#{meta_info.iksnr} #{lang}: #{meta_info.title}"
              reg.packages.each do |package|
                barcode_override = "#{package.barcode}_#{meta_info.type}_#{lang}"
                name = @specify_barcode_to_text_info[barcode_override]
                if meta_info.title.eql?(name)
                  current_name = nil
                  current_name ||= eval("package.patinfo.#{lang}.name if package.patinfo.#{lang}") if package.patinfo
                  if current_name == nil || patinfo_lang.name.eql?(current_name)
                    LogFile.debug "#{package.pointer}: Updated as matched via #{barcode_override} -> #{name} #{package.instance_eval('@patinfo')}"
                    store_patinfo_for_one_packages(package, lang, patinfo_lang)
                  else # must save other langues which may be correct
                    old_ti = package.patinfo
                    package.patinfo = @app.create_patinfo
                    Languages.each do |old_lang|
                      next if old_lang.eql?(lang)
                      eval("package.patinfo.descriptions['#{old_lang}']= old_ti.descriptions['#{old_lang}']")
                    end
                    LogFile.debug "#{package.pointer}: Created new #{current_name} as matched via #{barcode_override} -> #{name} #{package.patinfo.oid}"
                    store_patinfo_for_one_packages(package, lang, patinfo_lang)
                  end
                  @corrected_pis << msg
                  @updated_pis << "  #{msg}"
                elsif name
                  LogFile.debug "Skipped: #{msg} as #{meta_info.title} != #{name}"
                else
                  LogFile.debug "missing_override: not found via #{barcode_override}: '#{name}' != '#{meta_info.title}'"
                  @missing_override << "#{barcode_override}: '#{meta_info.title}' # != override #{name}"
                end
              end
            end
          end
        else
          LogFile.debug "update_patinfo_lang #{meta_info.title} iksnr #{meta_info.iksnr} store_orphaned"
          store_orphaned meta_info.iksnr, pis, :orphaned_patinfo
          @unknown_iksnrs.store meta_info.iksnr, meta_info.title
        end
      rescue RuntimeError => err
        @failures.push err.message
        []
      end
    end

    def delete_patinfo iksnr, language
      puts_sync "delete_patinfo iksnr #{iksnr} #{language}"
      return unless iksnr
      if reg = @app.registration(iksnr)

        reg.each_sequence{
            |seq| 
                next unless seq.patinfo and seq.patinfo.pointer;
                puts_sync "delete_patinfo #{iksnr} pointer #{seq.patinfo.pointer}"
                @app.delete(seq.patinfo.pointer)
                @app.update(seq.pointer, :patinfo => nil)
                seq.odba_isolated_store
          }
      else
        puts_sync "delete_patinfo nothing to do for #{iksnr} ??"
      end
    end

    def report
      if defined?(@inconsistencies)
        if @inconsistencies.size == 0
          return "Your database seems to be okay. No inconsistencies found. #{@inconsistencies.inspect}"
        else
          msg = "Problems in your database?\n\n"+
                "Check for inconsistencies in swissmedicinfo FI and PI found #{@inconsistencies.size} problems.\n"+
                "Summary: \n"
          headings = {}
          @error_reasons.sort.each{ |id, count|  
                                    item = "  * found #{sprintf('%3d', count)} #{id}\n"
                                    headings[id] = item
                                    msg += item
                                  }
          msg += "\n"
          # [reg.iksnr, reg.name_base, id]
          # (1..10).sort {|a,b| b <=> a}   #=> [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
          heading = nil
          @inconsistencies.sort.each{
            |error|
              unless error[0].eql?(heading)
                msg += "\n\n   Details for #{headings[error[0]]}\n\n"
                heading = error[0]
              end
              msg += error[1..-1].join(", ")
              msg += "\n"
          }
          msg += "\n"
          msg += @run_check_and_update ? "The following iksnr were reimported" : "Re-importing the following iksnrs might fix some problems"
          msg += "\n\n" + @iksnrs_to_import.join(' ')
          return msg
        end
      end
      unknown_size = @unknown_iksnrs.size
      new_size     = @new_iksnrs.size
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
          "Searched for #{@search_term.join(', ')}",
          "Stored #{@updated_fis.size} Fachinfos",
          "Ignored #{@ignored_pseudos} Pseudo-Fachinfos",
          "Ignored #{@up_to_date_fis} up-to-date Fachinfo-Texts",
          "Stored #{@updated_pis.size} Patinfos",
          "Ignored #{@up_to_date_pis} up-to-date Patinfo-Texts", nil,
          "Checked #{@companies.size} companies",
          @companies.join("\n"), nil,
          "Unknown Iks-Numbers: #{unknown_size}",
          unknown, nil,
          "Create Iks-Numbers: #{new_size}", create_iksnr, nil,
          "Fachinfos without iksnrs: #{@iksless[:fi].size}",
          @iksless[:fi].join("\n"), nil,
          #"Patinfos without iksnrs: #{@iksless[:pi].size}",
          #@iksless[:pi].join("\n"), nil,
          "Session failures: #{@session_failures}", nil,
          "Download errors: #{@download_errors.size}",
          @download_errors.join("\n"), nil,
          "Parse Errors: #{@failures.size}",
          @failures.join("\n"),
          # names
          @updated.join("\n"),
          @skipped.join("\n"),
          @invalid.join("\n"),
          @notfound.join("\n"),nil,
          "#{@fi_without_atc_code.size} FIs without an ATC-code",      @fi_without_atc_code.join("\n"),
          "#{@fi_atc_code_missmatch.size} FI in HTML != metadata",     @fi_atc_code_missmatch.join("\n"),
        ].join("\n")
      when :fi
        res = [
          "Searched for #{@search_term.join(', ')}",
          "Stored #{@updated_fis.size} Fachinfos",
          "Ignored #{@ignored_pseudos} Pseudo-Fachinfos",
          "Ignored #{@up_to_date_fis} up-to-date Fachinfo-Texts", nil,
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
          @notfound.join("\n"),nil,
          "#{@fi_without_atc_code.size} FIs without an ATC-code",      @fi_without_atc_code.join("\n"),
          "#{@fi_atc_code_missmatch.size} FI in HTML != metadata",      @fi_atc_code_missmatch.join("\n"),
          "#{@fi_atc_code_different_in_registration.size} FIs with ATC-code != registration",      @fi_atc_code_different_in_registration.join("\n"),
        ].join("\n")
      when :pi
        res = [
          "Searched for #{@search_term.join(', ')}",
          "Stored #{@updated_pis.size} Patinfos",
          "Ignored #{@up_to_date_pis} up-to-date Patinfo-Texts", nil,
          "Checked #{@companies.size} companies",
          @companies.join("\n"), nil,
          "Create Iks-Numbers: #{new_size}", create_iksnr, nil,
          "Unknown Iks-Numbers: #{unknown_size}",
          unknown, nil,
          #"Patinfo without iksnrs: #{@iksless[:pi].size}",
          #@iksless[:pi].join("\n"), nil,
          "Session failures: #{@session_failures}", nil,
          "Download errors: #{@download_errors.size}",
          @download_errors.join("\n"), nil,
          "Parse Errors: #{@failures.size}",
          @failures.join("\n"),
          # names
          @updated.join("\n"),
          @skipped.join("\n"),
          @invalid.join("\n"),
          @notfound.join("\n"),nil,
        ].join("\n")
      end
      res << ""
      if @updated_pis == 0
        res << "\nNo updated patinfos"
      else
         res << "\nStored #{@updated_pis.size} updated patinfos:\n"
         res << @updated_pis.join("\n")
      end
      if @updated_fis == 0
        res << "\nNo updated patinfos"
      else
         res << "\nStored #{@updated_fis.size} updated fachinfos:\n"
         res << @updated_fis.join("\n")
      end
      if @wrong_meta_tags.size == 0
        res << "\nNo wrong metatags found"
      else
         res << "#{@wrong_meta_tags.size} wrong metatags:\n"
         res << @wrong_meta_tags.join("\n")
      end
      res << ""
      if @nonconforming_content.size == 0
        res << "\nAll imported images had a supported format"
      else
        res << "#{@nonconforming_content.size} non conforming contents:\n"
        res << @nonconforming_content.join("\n")
      end
      res << ""
      if @missing_override.size == 0
        res << "\nNo need to add anything to #{Override_file}"
      else
        res << "\n#{Override_file}: The #{@missing_override.size} missing overrides are\n"
        res << @missing_override.join("\n")
      end
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
        @agent.user_agent = 'Mozilla/5.0 (X11; Linux x86_64; rv:16.0) Gecko/20100101 Firefox/16.0'
        @agent.redirect_ok         = true
        @agent.redirection_limit   = 5
        @agent.follow_meta_refresh = true
        @agent.ignore_bad_chunking = true
      end
      @agent
    end

    def TextInfoPlugin::create_sequence(app, registration, title, seqNr ='00', packNr = '000')
      seq_args = {
        :composition_text => nil,
        :name_base        => title,
        :name_descr       => nil,
        :dose             => nil,
        :sequence_date    => nil,
        :export_flag      => nil,
      }
      sequence = registration.create_sequence(seqNr) unless sequence = registration.sequence(seqNr)
      sequence.name_base = registration.name_base
      app.registrations[registration.iksnr]=registration
      app.registrations.odba_store
      sequence.create_package(packNr)
      package = sequence.package(packNr)
      part = package.create_part
      res = app.update(sequence.pointer, seq_args, :swissmedic_text_info)
      registration.sequences[seqNr] = sequence
      sequence.fix_pointers
      registration.sequences.odba_store
      registration.odba_store
      # Niklaus does not know why we have to duplicate the code here. But it ensures that newly added fis
      # are found after an import_daily
      registration.sequences.values.first.name_base = title;
      registration.sequences.values.first.odba_store;
      LogFile.debug "create_sequence #{registration.iksnr} seqNr #{seqNr}  #{sequence.pointer} seq_args #{seq_args} app.name #{title} should match #{app.registration(registration.iksnr).name_base} registration.sequences #{registration.sequences}"
    end

    def TextInfoPlugin::create_registration(app, info, seqNr ='00', packNr = '000')
      iksnr = info.iksnr
      # similar to method update_registration in src/plugin/swissmedic.rb
      LogFile.debug("create_registration #{iksnr}/#{seqNr}/#{packNr} #{info.title} company #{info.authHolder}")
      reg_ptr = Persistence::Pointer.new([:registration, info.iksnr]).creator
      args = {
        :ith_swissmedic      => nil,
        :production_science  => nil,
        :vaccine             => nil,
        :registration_date   => nil,
        :expiration_date     => nil,
        :renewal_flag        => false,
        :renewal_flag_swissmedic => false,
        :inactive_date       => nil,
        :export_flag         => nil,
      }

      company_args = { :name => info.authHolder, :business_area => 'ba_pharma' }
      company = nil
      if(company = app.company_by_name(info.authHolder, 0.8))
        app.update company.pointer, args, :text_plugin_create_company
      else
        company_ptr = Persistence::Pointer.new(:company).creator
        company = app.update company_ptr, company_args
      end
      args.store :company, company.pointer
      registration = app.update reg_ptr, args, :text_plugin_create_registration
      TextInfoPlugin::create_sequence(app, registration, info.title, seqNr, packNr)
      registration
    end
    REFDATA_SERVER = DRbObject.new(nil, ODDB::Refdata::RefdataArticle::URI)

    def create_missing_registrations
      @iksnrs_meta_info ||= {}
      @iksnrs_meta_info.each do |key, infos|
        first_iksnr = infos.first.authNrs.first
        fi_info = @iksnrs_meta_info.find{|key, value| key[0] == first_iksnr && key[1] ==  'fi' && key[2] == 'de' }
        fi_info = fi_info[1].first if fi_info
        infos.first.authNrs.each do |iksnr|
          unless @app.registration(iksnr)
            if @options[:newest] || (@options[:iksnrs] && @options[:iksnrs].index(iksnr))
              if fi_info
                info = fi_info.clone
              else
                info = infos.first.clone
                # There are some registration, which have only a patient info, but no FI
                # e.g. 59705 Ceres Hypericum comp. omöopathisches Arzneimittel
              end
              info[:iksnr] = iksnr
              TextInfoPlugin::create_registration(@app, info)
            end
            @new_iksnrs[iksnr] = infos.first.title
          end
        end
      end
    end

    def TextInfoPlugin::get_iksnrs_from_string(string)
      iksnrs = []
      src1 = string.gsub(/[^0-9,:\s]/, "")
      src = src1.gsub(/[\d\w]+:/, '') # Catches stuff like "Zulassungsnummer Lopresor 100: 39'252 (Swissmedic) Lopresor Retard 200: 44'447 (Swissmedic)"
      if(matches = src.strip.scan(/\d{5}|\d{2}\s*\d{3}|\d\s*{5}/))
        # support some wrong in numbers [000nnn] (too many 0)
        if (matches.length == 2 && matches.first =~ /^0{3}\d{2}$/) and
            (matches.first.length == 5 && matches.last.length == 1 )
          matches = [matches.first[1..-1] + matches.last]
        end
        _iksnr = ''
        matches.each do |iksnr|
          if iksnr.length == 5
            iksnrs << iksnr
            _iksnr = ''
            next
          end
          # support [nnnnn] and [n,n,n,n,n]
          _iksnr << iksnr.gsub(/[^0-9]/, '')
          if _iksnr.length == 5
            iksnrs << _iksnr
            _iksnr = ''
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
      return :swissmedicinfo if html.index('section1') or html.index('Section7000')
      html.match(/MonTitle/i) ? :compendium : :swissmedicinfo
    end    
    def extract_iksnrs languages
      iksnrs = []
      languages.each_value do |doc|
        return TextInfoPlugin::get_iksnrs_from_string(doc.iksnrs.to_s)
      end
    end
    
    def submit_event agent, form, eventtarget, *args
      max_retries = ODDB.config.text_info_max_retry
      form['__EVENTTARGET'] = eventtarget
      agent.submit form, *args
    rescue Mechanize::ResponseCodeError => err
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
      File.open(@news_log, 'w') do |fh|
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
        url  = "http://www.swissmedicinfo.ch/?Lang=#{lang}"
        # LogFile.debug "swissmedicinfo_index #{url}"
        home = @agent.get(url)
        # behave as javascript click
        form = home.form_with(:id => 'ctl01')
        form['__EVENTTARGET']   = "ctl00$HeaderContent$ucSpecialSearch1$LB#{state}Auth"
        form['__EVENTARGUMENT'] = ''
        res = form.submit
        names = {}
        {# typ => [name, date]
          'FI' => [1, 3],
          'PI' => [0, 2],
        }.each_pair do |typ, i|
          _names = []
          res.search("//table[@id='MainContent_ucSearchResult1_ucResultGrid#{typ}_GVMonographies']/tr").each do |tr|
            tds = tr.search('td')
            unless tds.empty?
              next unless tds[i.first] && tds[i.last]
              _names << [tds[i.first].text, tds[i.last].text]
            end
          end
          names[typ.downcase.intern] = _names.sort.reverse end
        index[lang.downcase.intern] = names
      end
      index
    end
    def textinfo_swissmedicinfo_index
      setup_default_agent
      url = 'http://www.swissmedicinfo.ch/'
      # accept form
      accept = @agent.get(url)
      form   = accept.form_with(:id => 'ctl01')
      button = form.button_with(:name => 'ctl00$MainContent$btnOK')
      form.submit(button) # discard
      index = {}
      %w[New Change].each do |state|
        index[state.downcase.intern] = swissmedicinfo_index(state)
      end
      index
    end

    def TextInfoPlugin.match_iksnr
      /Zulassungsnummer[^\d]*([\d’ ]+).*(Wo|Packungen)/m
    end

    def TextInfoPlugin.find_iksnr_in_string(string, iksnr)
      nr  = ''
      string.each_char{ 
        |char|
          nr << char if char >= '0' and char <= '9'
          nr.eql?(iksnr) ? break : nr  = '' if char.eql?(' ') or char.eql?(',')
      }
      nr
    end

    def download_swissmedicinfo_xml(file = nil)
      return IO.read(file) if file
      setup_default_agent
      url  = "http://download.swissmedicinfo.ch/Accept.aspx?ReturnUrl=%2f"
      dir  = File.join(ODDB.config.data_dir, 'xml')
      FileUtils.mkdir_p dir
      name = 'swissmedicinfo'
      zip = File.join(dir, "#{name}.zip")
      response = nil
      if home = @agent.get(url)
        form = home.form_with(:id => 'Form1')
        bttn = form.button_with(:name => 'ctl00$MainContent$btnOK')
        if page = form.submit(bttn)
          form = page.form_with(:id => 'Form1')
          bttn = form.button_with(:name => 'ctl00$MainContent$BtnYes')
          response = form.submit(bttn)
        end
      end
      if response
        tmp = File.join(dir, name + '.tmp.zip')
        response.save_as(tmp)
        FileUtils.mv(tmp, zip)
        xml = ''
        Zip::File.foreach(zip) do |entry|
          if entry.name =~ /^AipsDownload_/iu
            entry.get_input_stream { |io| xml = io.read }
          end
        end
        File.open(@aips_xml, 'w') { |fh| fh.puts(xml) }
      end
    end
    def extract_matched_content(name, type, lang)
      content = nil, styles = nil, title = nil, iksnrs = nil
      return content unless @doc and name
      nameForRegexp = name.gsub('"','.')
      path  = "//medicalInformation[@type='#{type[0].downcase + 'i'}' and @lang='#{lang.to_s}']/title[match(., \"#{nameForRegexp}\")]"
      match = @doc.xpath(path, Class.new do
        def match(node_set, name)
          found_node = catch(:found) do
            node_set.find_all do |node|
              title = node.text.gsub(CharsNotAllowedInBasename, '')
              name  = name.gsub(CharsNotAllowedInBasename, '')
              throw :found, node if title == name
              false
            end
            nil
          end
          found_node ? [found_node] : []
        end
      end.new).first
      return nil, nil,nil,nil unless match
      if match
        content = match.parent.at('./content')
        styles  = match.parent.at('./style').text
        title   = match.parent.at('./title').text
        iksnrs  = TextInfoPlugin::get_iksnrs_from_string(match.parent.at('./authNrs').text)
        unless iksnrs.size > 0
          @wrong_meta_tags << "#{match.parent.at('./authNrs')} authNrs-text: #{match.parent.at('./authNrs').text}"
        end
      end
      return content, styles, title, iksnrs
    end
    def extract_matched_name(iksnr, type, lang)
      name = nil
      return name unless @doc
      path  = "//medicalInformation[@type='#{type[0].downcase + 'i'}' and @lang='#{lang.to_s}']/authNrs"
      @doc.xpath(path, Class.new do
        def match(node_set, iksnr)
          node_set.find_all do |node|
            iksnr.eql?(TextInfoPlugin.find_iksnr_in_string(node.text, iksnr))
          end
        end
      end.new).each{ 
        |x| 
            if iksnr.eql?(TextInfoPlugin.find_iksnr_in_string(x.text, iksnr))
              name = x.parent.at('./title').text 
              puts_sync "extract_matched_name #{iksnr} #{type} as '#{type[0].downcase + 'i'}' lang '#{lang.to_s}' path is #{path} returns #{name}"
              return name
            end
      }
      @notfound << "  IKSNR-not found #{iksnr.inspect} : #{type} - #{lang.to_s}."
      return name
    end
    def extract_image(html_file, name, type, lang, iksnrs)
      if html_file && File.exist?(html_file)
        resource_dir = (File.join(ODDB::IMAGE_DIR, type.to_s, lang.to_s))
        FileUtils.mkdir_p(resource_dir)
        html = File.open(html_file, 'r:utf-8').read
        if html =~ /<img\s/
          images = Nokogiri::HTML(html).search('//img')
          html = nil
          name_base = File.basename(name.gsub(/®/, '').gsub(/[^A-z0-9]/, '_')).strip
          dir = File.join(resource_dir, name_base + '_files')
          FileUtils.mkdir_p(dir)
          images.each_with_index do |img, i|
            type, src = img.attributes['src'].to_s.split(',')
            # next regexp must be in sync with ext/fiparse/src/textinfo_hpricot.rb
            unless type =~ /^data:image\/(jp[e]?g|gif|png);base64$/
              @nonconforming_content << "#{iksnrs}: '#{@title}' with non conforming #{type} element x"
            end
            if type =~ /^data:image\/(jp[e]?g|gif|png|x-[ew]mf);base64$/
              file = File.join(dir, "#{i + 1}.#{$1}")
              File.open(file, 'wb'){ |f| f.write(Base64.decode64(src)) }
            end
          end
        end
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
  'xmlns:xsd'         => 'http://www.w3.org/2001/XMLSchema',
  'xmlns:xsi'         => 'http://www.w3.org/2001/XMLSchema-instance',
  }

    def get_fi_pi_to_update(names, type)
      # names eg. { :de => 'Alacyl'}
      iksnrs = []
      infos  = {}
      return [iksnrs,infos] unless @doc
      iksnrs_from_xml = nil
      name  = ''
      content = nil
      [:de, :fr].each do |lang|
        next unless names[lang]
        name = names[lang]
        saved = iksnrs_from_xml
        content, styles, title, iksnrs_from_xml = extract_matched_content(name, type, lang)
        next unless iksnrs_from_xml
        iksnrs_from_xml.each do |iksnr|
          meta_info = SwissmedicMetaInfo.new
          meta_info.type = type.to_s == 'fachinfo' ? 'fi' : 'pi'
          meta_info.iksnr = iksnr
          meta_info.authNrs = iksnrs_from_xml
          meta_info.lang = lang.to_s
          meta_info.title = title
          info = "#{iksnrs_from_xml.first}_#{meta_info.type}_#{meta_info.lang}"
          meta_info.xml_file = File.join(@details_dir, info + '.xml')
          unless File.exist?(meta_info.xml_file)
            LogFile.debug "get_fi_pi_to_update: creating #{meta_info.xml_file}"
            builder = Nokogiri::XML::Builder.new(:encoding => 'utf-8') do |xml|
              datetime = Time.new.strftime('%FT%T%z')
              xml.medicalInformations(XML_OPTIONS) do
                xml.comment "Generated by __FILE__ at #{Time.now}"
                xml.medicalInformation('type' => meta_info.type,
                                       'lang' => meta_info.lang,
                                       'version' => 2) do
                  xml.title       meta_info.title
                  xml.authHolder  ""
                  xml.atcCode     ""
                  xml.substances  ""
                  xml.authNrs     iksnrs_from_xml.join(', ')
                  xml.style       styles
                  # content # does not output anything
                  # xml.content { xml.cdata content } # outputtted CDATA twice
                  # xml.content { xml.cdata! content }# generated     <content> <cdata>&lt;content&gt;&lt;![CDATA[&lt;?xml version="1.0"
                  xml.content { xml.cdata content.text }
                end
              end
            end
            output = builder.to_xml
            File.open(meta_info.xml_file, 'w:utf-8'){ |fh| fh << builder.to_xml }
            age_in_hours = 0
          else
            age = Time.now - File.mtime(meta_info.xml_file )
            age_in_hours = (age / 60*60).to_i
          end
          # informationUpdate could be read from meta_info.xml_file
          if iksnrs_from_xml.size > 0 && type == 'fachinfo' and @app.registration(iksnrs_from_xml[0]) and not @app.registration(iksnrs_from_xml[0]).fachinfo
            LogFile.debug "get_fi_pi_to_update: no reg or fi add #{meta_info}"
            @to_parse << meta_info
          elsif @options[:reparse] || age_in_hours < 3
            LogFile.debug "get_fi_pi_to_update: reparse #{@options[:reparse]} or age_in_hours < 3 is #{age_in_hours} #{meta_info}"
            @to_parse << meta_info
          else
            @up_to_date_fis += 1 if type == 'fachinfo'
            @up_to_date_pis += 1 if type == 'patinfo'
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
        [target.to_s.upcase, {:fi => 'fachinfo'}]
      elsif target == :pi
        [target.to_s.upcase, {:pi => 'patinfo'}]
      else #both
        ['FI/PI', {:fi => 'fachinfo', :pi => 'patinfo'}]
      end
    end
    def report_sections_by(title)
      [
        ["New/Updates #{title} from swissmedicinfo.ch"], # updated
        ["Skipped #{title} form swissmedicinfo.ch"],     # skipped
        ["Invalid #{title} from swissmedicXML"],         # invalid
        ["Not found #{title} in swissmedicXML"],         # notfound
      ]
    end

    # Error reasons
    Flagged_as_inactive               = "oddb.registration('Zulassungsnummer').inactive? but has Zulassungsnummer in Packungen.xlsx"
    Reg_without_base_name             = 'oddb.registration has no method name_base'
    Mismatch_name_2_xls               = 'oddb.registration.name_base differs from Sequenzname in Packungen.xlsx'
    Iksnr_only_oddb                   = 'oddb.registration.iksnr has no Zulassungsnummer in Packungen.xlsx'
    Iksnr_only_packages               = "Zulassungsnummer from Packungen.xlsx is not in oddb.registrations('Zulassungsnummer')"
    FI_iksnrs_mismatched_to_aips_xml  = 'oddb.registration.fachinfo.iksnrs do not match authNrs from AipsDownload_latest.xml'
    PI_iksnrs_mismatched_to_aips_xml  = "oddb.registration('iksnr').sequences['0x'].patinfo.descriptions['de'].iksnrs.to_s does not match entity authNrs from AipsDownload_latest.xml"
    Mismatch_reg_name_to_fi_name      = 'oddb.registration.name_base differs from oddb.registration.fachinfo.name_base'
    Mismatch_reg_name_to_pi_name      = "oddb.registration.registration.name_base differs from name_base in registration('iksnr').sequences['0x'].patinfo.name_base"
    
    def log_error(iksnr, name_base, id, added_info, suppress_re_import = false)
      @error_reasons[id] += 1      
      info = [id, iksnr, name_base]
      if added_info then added_info.class == Array ? info += added_info : info << added_info end
      @inconsistencies << info
      @iksnrs_to_import << iksnr unless suppress_re_import
      LogFile.debug "check_swissmedicno_fi_pi #{[id, iksnr, name_base]}"
    end

    def check_swissmedicno_fi_pi(options = nil, patinfo_must_be_deleted = false)
      @options = options if options
      LogFile.debug "check_swissmedicno_fi_pi found  #{@app.registrations.size} registrations and #{@app.sequences.size} sequences. Options #{options}. Having #{@iksnrs_meta_info.size} @iksnrs_meta_info"
      parse_aips_download if @iksnrs_meta_info.size == 0
      read_packages
      @error_reasons = {
          Flagged_as_inactive               => 0,
          Reg_without_base_name             => 0,
          Mismatch_name_2_xls               => 0,
          Iksnr_only_oddb                   => 0,
          Iksnr_only_packages               => 0,
          FI_iksnrs_mismatched_to_aips_xml  => 0,
          PI_iksnrs_mismatched_to_aips_xml  => 0,
          Mismatch_reg_name_to_fi_name      => 0,
          Mismatch_reg_name_to_pi_name      => 0,
      }
      @inconsistencies = []
      @iksnrs_to_import = []
      @nrDeletes = []
      split_reg_exp = / |,|-/
      @packages.each_key{ |iksnr|
          log_error(@packages[iksnr].iksnr, @packages[iksnr].name_base, Iksnr_only_packages, @packages[iksnr]) unless @app.registration(iksnr)
      }
      @app.registrations.each{
        |aReg| 
          reg= aReg[1];
          iksnr_2_check = reg.iksnr
          xls_package_info = @packages[iksnr_2_check]

          log_error(reg.iksnr, reg.name_base, Flagged_as_inactive, xls_package_info) if reg.inactive? and xls_package_info
          next if reg.inactive? # we are only interested in the active registrations
      
          log_error(reg.iksnr, reg.name_base, Iksnr_only_oddb, xls_package_info, true) unless xls_package_info

          if xls_package_info and not xls_package_info.name_base.eql?(reg.name_base)
            log_error(reg.iksnr, reg.name_base, Mismatch_name_2_xls, xls_package_info) unless xls_package_info
          end

          if  reg.fachinfo and reg.fachinfo.iksnrs
            fi_iksnrs = TextInfoPlugin::get_iksnrs_from_string(reg.fachinfo.iksnrs.to_s) 
            xml_iksnrs = @fis_to_iksnrs[iksnr_2_check] ? @fis_to_iksnrs[iksnr_2_check] : []
            if xml_iksnrs and fi_iksnrs != xml_iksnrs
              txt = ''
              xml_iksnrs.each{ |id| txt += @app.registration(id) ? "#{id} #{@app.registration(id).name_base}, " : id + ', ' }
              log_error(reg.iksnr, reg.name_base, FI_iksnrs_mismatched_to_aips_xml, txt) 
              # TODO: update the fachinfo.iksnrs
            end
          end

          # Check first part of the fachinfo name (case-insensitive)
          if not reg.name_base
            log_error(reg.iksnr, reg.name_base, Reg_without_base_name, '')
          elsif reg.fachinfo and reg.fachinfo.name_base
            fi_name  = reg.fachinfo.name_base.split(split_reg_exp)[0].downcase
            reg_name = reg.name_base.split(split_reg_exp)[0].downcase
            unless reg_name.eql?(fi_name)
              log_error(reg.iksnr, reg.name_base, Mismatch_reg_name_to_fi_name, reg.fachinfo.name_base)
              hasDefect = true
            end
          end

          foundPatinfo = false
          reg.sequences.each {
            |aSeq|
              seq = aSeq[1]
              hasDefect = false
              foundPatinfo = true if seq.patinfo and seq.patinfo.pointer
              next if (seq.patinfo == nil or  seq.patinfo.name_base == nil)

              if  seq.patinfo  and seq.patinfo.descriptions['de'] # and seq.patinfo.descriptions['de'].iksnrs
                pi_iksnrs = TextInfoPlugin::get_iksnrs_from_string(seq.patinfo.descriptions['de'].iksnrs.to_s)
                pi_xml_iksnrs = @pis_to_iksnrs[iksnr_2_check]
                if pi_iksnrs and pi_xml_iksnrs and pi_iksnrs.sort.uniq != pi_xml_iksnrs
                  log_error(reg.iksnr, reg.name_base, PI_iksnrs_mismatched_to_aips_xml, pi_xml_iksnrs) 
                  hasDefect = true
                end
              end

              # Check first part of the name (case-insensitive)
              if reg.name_base
                reg_name = reg.name_base.split(split_reg_exp)[0].downcase
                pi_name  = seq.patinfo.name_base.split(split_reg_exp)[0].downcase
                unless reg_name.eql?(pi_name)
                  log_error(reg.iksnr, reg.name_base, Mismatch_reg_name_to_pi_name, [reg_name, pi_name, seq.seqnr, seq.patinfo.pointer] )
                  hasDefect = true
                end
              end

              next if hasDefect == false and seq.patinfo.descriptions == nil

              if hasDefect and patinfo_must_be_deleted
                @nrDeletes << seq.patinfo.pointer.to_s
                LogFile.debug "delete_patinfo_pointer #{@nrDeletes.size}: #{iksnr_2_check} #{reg.name_base} #{seq.seqnr} #{seq.patinfo.name_base} #{seq.patinfo.pointer}"
                @app.delete(seq.patinfo.pointer)
                @app.update(seq.pointer, :patinfo => nil)
                seq.odba_isolated_store
              end
          } 
      }
      LogFile.debug "check_swissmedicno_fi_pi found  #{@inconsistencies.size} inconsistencies.\nDeleted #{@nrDeletes.inspect} patinfos."
      LogFile.debug "check_swissmedicno_fi_pi #{@iksnrs_to_import.sort.uniq.size}/#{@iksnrs_to_import.size} iksnrs_to_import  are  \n#{@iksnrs_to_import.sort.uniq.join(' ')}"
      @iksnrs_to_import = @iksnrs_to_import.sort.uniq
      @packages = nil # free some memory if we want to import
      true # an update/import should return true or you will never send a report
    end
  
    def update_swissmedicno_fi_pi(options = {})
      LogFile.debug "update_swissmedicno_fi_pi #{options}"
      threads = []
      @iksnrs_to_import =[]
      threads << Thread.new do
        @run_check_and_update = true
        check_swissmedicno_fi_pi(options, @run_check_and_update)
      end
      threads.map(&:join)
      @iksnrs_to_import = [ '-99999'] if @iksnrs_to_import.size == 0
      # set correct options to force a reparse (reimport)
      @options[:reparse] = true
      @options[:download] = false
      LogFile.debug "update_swissmedicno_fi_pi finished"
      true # an update/import should return true or you will never send a report
    end
  private
    def call_xmllint(filename, is_html= false)
      # avoid it as it take way too much time. over 20 minutes for all files.
      # LogFile.debug "xmllint #{filename}"
      # system("xmllint #{is_html ? '--html' : ''} --format --output #{filename} #{filename} 2>/dev/null")
    end
    # return
    def extract_html(meta_info)
      unless meta_info.xml_file && File.exist?(meta_info.xml_file)
        return [ nil, nil, nil ]
      end
      content = IO.read(meta_info.xml_file, :encoding => 'UTF-8')
      html = /<content><!\[CDATA\[(.*)\]\]><\/content/mi.match(content)[1]
      html_name = meta_info.xml_file.sub('.xml', '.html')
      path = File.join(ODDB.config.data_dir, 'html', meta_info.type, meta_info.lang)
      html_name = File.join(path, meta_info.title.gsub(CharsNotAllowedInBasename, '_') + '.html')
      is_same_html = File.exist?(html_name) && IO.read(html_name, :encoding => 'UTF-8') == html
      unless is_same_html
        FileUtils.makedirs(File.dirname(html_name))
        File.open(html_name, 'w+:utf-8') {|f| f.write html }
        call_xmllint(html_name, true)
        LogFile.debug "IKSNR #{meta_info.iksnr}: File.size(#{html_name}) is #{File.size(html_name)}"
      end
      m = /<style>(.*)<\/style>/.match(content)
      styles = m ? m[1] : ''
      return [ html_name, styles, is_same_html ]
    end

    def found_matching_iksnr(iksnrs)
      matched_iksnrs = @options[:iksnrs] && ((@options[:iksnrs] & iksnrs).size > 0)
      return (@options[:iksnrs] == nil || matched_iksnrs)
    end

    def get_textinfo(meta_info, iksnr)
      reg = @app.registration(iksnr)
      # Workaround for 55829 Ebixa
      TextInfoPlugin::create_registration(@app, meta_info) unless reg && reg.sequences && reg.sequences.size > 0
      reg = @app.registration(iksnr)
      if meta_info.type == 'fi'
        info = reg.fachinfo if reg
      else
        info = reg.packages.collect{|x| x.patinfo if x.respond_to?(:patinfo)  }.compact.first
        # consider case where all packages have the same patinfo
        info ||= reg.sequences.values.collect{|x| x.patinfo if x.respond_to?(:patinfo)  }.compact.first
      end
    end

    def parse_textinfo(meta_info)
      type = meta_info[:type].to_sym
      return unless Languages.index(meta_info.lang.to_sym)
      return if @options[:target] != :both && @options[:target] != type
      if type == :pi && !@packages[meta_info[:iksnr]]
        LogFile.debug "skip #{meta_info[:type]} as #{meta_info.iksnr} #{meta_info.title} not found in Packungen.xlsx"
        return
      end
      nr_uptodate = type == :fi ? @up_to_date_fis : @up_to_date_pis
      if @options[:reparse]
        if meta_info.authNrs && found_matching_iksnr(meta_info.authNrs)
          LogFile.debug "parse_textinfo #{__LINE__} at #{nr_uptodate}: #{type}  because reparse is demanded: #{@options[:reparse]} #{meta_info.authNrs}"
        else
          return
        end
      end
      res = extract_html(meta_info)
      html_name = res[0]
      is_same_html = res[2]
      unless html_name
        LogFile.debug "parse_textinfo #{type} #{__LINE__}: no html_name for #{meta_info}"
        return
      end
      textinfo_fi = nil
      text_info = nil
      reg = nil
      reg = @app.registration(meta_info.iksnr)
      if reg == nil || reg.sequences.size == 0 # Workaround for Ebixa problem
        if type == :fi
          LogFile.debug "must create #{meta_info.type} #{meta_info.lang} #{meta_info.authNrs} as no sequence found for reg #{reg.class}"
          TextInfoPlugin::create_registration(@app, meta_info)
        else
          LogFile.debug "skip #{meta_info.type} #{meta_info.lang} #{meta_info.authNrs} as no sequence found for reg #{reg.class}"
          return
        end
      end if type != :fi # we will create a registration in this case later
      text_info = get_textinfo(meta_info,  meta_info.iksnr)

      if !text_info || !text_info.descriptions.keys.index(meta_info.lang)
        LogFile.debug "must create textinfo for #{meta_info.type} #{meta_info.lang} #{meta_info.iksnr} of #{meta_info.authNrs}"
      elsif !is_same_html
        LogFile.debug "parse_textinfo #{__LINE__} #{html_name} does is not the same: #{meta_info.authNrs}"
      elsif @options[:reparse]
        LogFile.debug "parse_textinfo #{__LINE__} reparse demanded via @options #{@options}"
      elsif found_matching_iksnr(meta_info.authNrs)
        if meta_info.same_content_as_xml_file
          type == :fi ? @up_to_date_fis += 1 : @up_to_date_pis += 1
          return
        end
      elsif meta_info.same_content_as_xml_file
        LogFile.debug "parse_textinfo #{__LINE__} at #{nr_uptodate}: #{type} same_content_as_xml_file #{meta_info.authNrs}" if false # default casse
        type == :fi ? @up_to_date_fis += 1 : @up_to_date_pis += 1
        return
      end
      styles = res[1]
      extract_image(html_name, meta_info.title, meta_info.type, meta_info.lang, meta_info.authNrs)
      if type == :fi
        if is_same_html && !@options[:reparse] && reg && reg.fachinfo && text_info.descriptions.keys.index(meta_info.lang)
          LogFile.debug "parse_textinfo #{__LINE__} #{meta_info.iksnr} at #{nr_uptodate}: #{type} #{html_name} is_same_html #{html_name}"
          @up_to_date_fis += 1
          return
        end
        textinfo_fi ||= @parser.parse_fachinfo_html(html_name, @format, meta_info.title, styles)
        update_fachinfo_lang(meta_info, { meta_info.lang => textinfo_fi } )
      elsif type == :pi
        # TODO: Do we really catch all the cases when packages have different PIs?
        if is_same_html && !@options[:reparse] && reg && text_info && text_info.descriptions.keys.index(meta_info.lang)
          LogFile.debug "parse_textinfo #{__LINE__} at #{nr_uptodate}: #{type} #{html_name} is_same_html #{html_name}"
          @up_to_date_pis += 1
          return
        end
        textinfo_pi = @parser.parse_patinfo_html(html_name, @format, meta_info.title, styles)
        update_patinfo_lang(meta_info, { meta_info.lang => textinfo_pi } )
        textinfo_pi = nil
      end
      LogFile.debug "parse_textinfo #{__LINE__} at #{nr_uptodate}: #{type} textinfo  #{textinfo.to_s.split("\n")[0..2]}" if  self.respond_to?(:textinfo)
      if reg
        reg.odba_store
        textinfo = nil
        textinfo_fi = nil
        reg = nil
      end
    end

    def handle_chunk(chunk)
      return nil unless chunk.size > 100
      chunk += " </medicalInformation></medicalInformations>"
      chunk = %(<?xml version="1.0" encoding="utf-8"?>
<medicalInformations>) + chunk unless /<medicalInformations>/.match(chunk)
      meta_info = SwissmedicMetaInfo.new

      if m = /type="([^"]+)/.match(chunk) then meta_info.type  = m[1] end
      if m = /lang="([^"]+)/.match(chunk) then meta_info.lang = m[1] end
      if m = /informationUpdate="([^"]+)/.match(chunk) then meta_info.informationUpdate = m[1] end
      if m =/<authNrs>([^<]+)</.match(chunk) then meta_info.iksnr = m[1].split(', ').first end
      if m =/<authHolder>([^<]+)</.match(chunk) then meta_info.authHolder = m[1] end
      if m =/<substances>([^<]+)</.match(chunk) then meta_info.substances = m[1] end
      if m =/<title>([^<]+)</.match(chunk) then meta_info.title = m[1] end
      if m =/<authNrs>([^<]+)</.match(chunk) then meta_info.authNrs = m[1].split(', ').sort end
      if m =/<atcCode>([^,\W<]*)/.match(chunk) then meta_info.atcCode = m[1].split(' ')[0] end
      info = "#{meta_info.authNrs.size > 0 ? meta_info.authNrs.first : meta_info.iksnr}_#{meta_info.type}_#{meta_info.lang}"
      @iksnr_lang_type[info] =  meta_info.title unless @iksnr_lang_type[info]
      outfile = File.join(@details_dir, info + '.xml')
      is_duplicate = false
      if File.exist?(outfile)
        @iksnrs_from_aips << meta_info.iksnr
        @duplicate_entries << info + ': "' + @iksnr_lang_type[info] + '"' # was first
        @duplicate_entries << info + ': "' + meta_info.title + '"' # was duplicate
        outfile = File.join(@details_dir,  info + '_' + meta_info.title.gsub(/[^\w]/, '_') + '_problem.xml')
        is_duplicate = true
      end
      meta_info.same_content_as_xml_file = File.exist?(outfile) && IO.read(outfile, :encoding => 'UTF-8') == chunk
      unless meta_info.same_content_as_xml_file
        FileUtils.makedirs(File.dirname(outfile))
        File.open(outfile, 'w+') { |f| f.write(chunk) }
        call_xmllint(outfile)
      end
      # Tidy it up
      meta_info.xml_file = outfile
      # puts "#{Time.now}: wrote #{outfile} #{File.size(outfile)} bytes" if is_duplicate
      return meta_info
    end

    def report_problematic_names
      LogFile.debug "#{Time.now}: Creating #{@problematic_fi_pi} with #{@duplicate_entries.size} @duplicate_entries"
      File.open(@problematic_fi_pi, 'w+') do |file|
        file.write("# resolve these problems and add them to #{@missing_override_file}")
        @iksnrs_from_aips.sort.uniq.each do|iksnr|
          file.puts "# known packages. There are #{@duplicate_entries.size} @duplicate_entries"
          @app.registration(iksnr).packages.each do |pack|
            if pack.is_a?(ODDB::Package)
              file.puts "#{iksnr} #{pack.barcode} #{pack.name}"
            else
              file.puts "# not a pack for #{iksnr} #{pack.inspect}"
            end
          end if @app.registration(iksnr)
        end if @duplicate_entries.size > 0
        file.puts "# Start of @duplicate_entries"
        @duplicate_entries.sort.uniq.each { |duplicate| file.puts duplicate }
      end
      LogFile.debug "created #{@problematic_fi_pi}"
    end

    def parse_aips_download
      LogFile.debug "parse_aips_download with @options #{@options}"
      @iksnrs_from_aips = []
      @iksnr_lang_type = {}
      @aips_xml = @options[:xml_file] if @options[:xml_file]
      # FileUtils.rm_rf(@details_dir, verbose: true) # spart etwas Zeit und lässt alte Dokus zu
      FileUtils.makedirs(@details_dir, verbose: true)
      return unless File.exist?(@aips_xml)
      content = IO.read(@aips_xml, :encoding => 'UTF-8')
      LogFile.debug "#{Time.now}: read #{content.size} bytes"
      content.split('</medicalInformation>').each do |chunk|
        meta_info = handle_chunk(chunk)
        next unless meta_info
        if meta_info.authNrs.size == 0
          puts_sync "get_meta_info no authNrs found for #{info} with all_numbers #{all_numbers}"
        else
          meta_info.authNrs.each do |iksnr|
            meta_info.iksnr = iksnr
            key = [ iksnr, meta_info.type, meta_info.lang ]
            key_string = "#{iksnr}_#{meta_info.type}_#{meta_info.lang}"
            @iksnrs_meta_info[key] ||= []
            @iksnrs_meta_info[key] << meta_info.clone
            reg = @app.registration(iksnr)
            @iksnrs_meta_info[key].each do |info|
              unless info.authHolder.eql?(reg.company.to_s)
                nrEntries = @iksnrs_meta_info[key].find_all{ |x| x.authHolder.eql?(reg.company.to_s) }.size
                puts "Mismatching authHolder #{iksnr} meta #{meta_info.authHolder} != db #{reg.company.to_s}. Has #{nrEntries}/#{@iksnrs_meta_info[key].size} entries" if DEBUG_FI_PARSE
                if nrEntries >= 1
                  @iksnrs_meta_info[key].delete_if{ |x| !x.authHolder.eql?(reg.company.to_s) }
                  @duplicate_entries.delete_if{ |x| x.index(key_string) == 0} if nrEntries == 1
                  puts "Mismatching authHolder #{iksnr}. Has now #{@iksnrs_meta_info[key].size} entries" if DEBUG_FI_PARSE
                else
                  puts "Could not delete Mismatching authHolder #{iksnr}. Still #{@iksnrs_meta_info[key].size} entries" if DEBUG_FI_PARSE
                end
                puts "Mismatching authHolder #{iksnr}. Has #{@duplicate_entries.find_all{ |x| x.index(key_string) == 0}.size } @duplicate_entries" if DEBUG_FI_PARSE
              end if @iksnrs_meta_info[key].size > 1
            end if reg
          end
        end
        if @options[:target] == :both || @options[:target].to_s.eql?(meta_info.type)
          if @options[:companies] && @options[:companies].size > 0
            @to_parse << meta_info if @options[:companies].downcase.match(meta_info.authHolder)
          elsif @options[:iksnrs] && @options[:iksnrs].size > 0
            found = @options[:iksnrs].find{ |x| meta_info.authNrs.index(x)}
            @to_parse << meta_info if found
          else
            @to_parse << meta_info
          end
        end
      end
      content = nil # get rid of the 800MB file!
      @companies ||=  @options[:companies]
      puts "#{Time.now}: created #{@iksnrs_meta_info.size} @iksnrs_meta_info"
      create_missing_registrations
      report_problematic_names
    end
    def title_and_keys_by(target)
      if target == :fi
        [target.to_s.upcase, {:fi => 'fachinfo'}]
      elsif target == :pi
        [target.to_s.upcase, {:pi => 'patinfo'}]
      else #both
        ['FI/PI', {:fi => 'fachinfo', :pi => 'patinfo'}]
      end
    end
    def get_swissmedicinfo_changed_items(index, target)
      title,keys = title_and_keys_by(target)
      @updated,@skipped,@invalid,@notfound = report_sections_by(title)
      @doc = Nokogiri::XML(IO.read(@aips_xml, {:encoding => 'UTF-8'}))
      index.each_pair do |state, names|
        find_changed_new_items(keys, names, state)
      end
      LogFile.debug "get_swissmedicinfo_changed_items #{@new_iksnrs.size} @new_iksnrs"
      @doc = nil
    end
  public
    def iksnrs_meta_info
      @iksnrs_meta_info
    end



    def import_swissmedicinfo(options=nil)
      LogFile.debug "import_swissmedicinfo options #{options} @options #{@options} "
      @options = options if options
      $stdout.sync = true
      @specify_barcode_to_text_info = {}
      @specify_barcode_to_text_info = YAML.load(File.read(Override_file)) if File.exist?(Override_file)
      read_packages
      @options[:target] ||= :both
      threads = []
      if @options[:download] != false
        threads << Thread.new do
          download_swissmedicinfo_xml
        end
      end
      threads.map(&:join)
      LogFile.debug "Parsing @options[:newest] #{@options[:newest]} #{@options[:newest] != false}"
      @to_parse = []
      parse_aips_download # to get all meta information
      LogFile.debug "After parse_aips_download we have  #{@to_parse.size} items to parse. Having #{@iksnrs_meta_info.size} meta items."
      @iksnrs_meta_info_clone = @iksnrs_meta_info.clone
      if @options[:newest]
        index = nil
        # @to_parse = [] # Reset it to empty, as we want to add only the changed items!
        threads << Thread.new do
          index = textinfo_swissmedicinfo_index
          get_swissmedicinfo_changed_items(index, @options[:target])
        end
        threads.map(&:join)
        # report
        @to_parse.each do |meta|
          date = (date ? " - #{date}" : '')
          info =  get_textinfo(meta, meta.iksnr)
          unless info
            msg  = "  #{meta.type == 'fi' ? 'Fachinfo' : 'Patinfo '} - #{meta.lang.to_s.upcase} - #{meta.title}#{date}#{meta.authNrs}"
            @updated << msg
          end
        end
      end
      LogFile.debug "import_swissmedicinfo must parse @to_parse #{@to_parse.size}  FI/PIs"
      LogFile.debug "import_swissmedicinfo must parse @iksnrs_meta_info #{@iksnrs_meta_info.size} FI/PIs"
      @iksnrs_meta_info.values.flatten.sort{|x,y| x.iksnr.to_i <=> y.iksnr.to_i}.each do |meta_info|
        parse_textinfo(meta_info)
      end
      File.open(@missing_override_file, 'w+') {|f| f.puts  @missing_override.join("\n")}
      if @options[:download] != false
        puts_sync "job is done. now postprocess works ..."
        postprocess
      end
      true # report
    end
  end
end
