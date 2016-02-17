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
require 'model/fachinfo'
require 'model/patinfo'
require 'view/rss/fachinfo'
require 'util/logfile'
require 'rubyXL'
require 'ext/refdata/src/refdata'

module ODDB

  SwissmedicMetaInfo = Struct.new("SwissmedicMetaInfo", :iksnr, :authNrs, :atcCode, :title, :authHolder, :substances, :type, :lang, :informationUpdate, :refdata, :xml_file)
  class TextInfoPlugin < Plugin
    attr_reader :updated_fis, :updated_pis
    Languages = [:de, :fr, :it]
    CharsNotAllowedInBasename = /[^A-z0-9,\s\-]/
    Override_file = File.join(Dir.pwd, 'etc',  defined?(Minitest) ? 'barcode_minitest.yml' : 'barcode_to_text_info.yml')
    def initialize app, opts={}
      super(app)
        GC.start
      @options = opts
      @parser = DRb::DRbObject.new nil, FIPARSE_URI
      @dirs = {
        :fachinfo => File.join(ODDB.config.data_dir, 'html', 'fachinfo'),
        :patinfo  => File.join(ODDB.config.data_dir, 'html', 'patinfo'),
      }
      @aips_xml   = File.join(ODDB.config.data_dir, 'xml', 'AipsDownload_latest.xml')
      @updated_fis = 0
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
      @@iksnrs_meta_info = {}
      @@missing_override ||= []
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
      RubyXL::Parser.parse(latest_name)[0][4..-1].each do |row|
        next unless cell(row, @target_keys.index(:iksnr)).to_i and
            cell(row, @target_keys.index(:seqnr)).to_i and
            cell(row, @target_keys.index(:production_science)).to_i
        next if (cell(row, @target_keys.index(:production_science)) == 'Tierarzneimittel')
        iksnr = "%05i" % cell(row, @target_keys.index(:iksnr)).to_i
        seqnr = "%03i" % cell(row, @target_keys.index(:seqnr)).to_i
        name_base = cell(row, @target_keys.index(:name_base)).value.to_s
        @packages[iksnr] = IKS_Package.new(iksnr, seqnr, name_base)
      end
      LogFile.debug "read_packages found latest_name #{latest_name} with #{@packages.size} packages"
    end
    def postprocess
      update_rss_feeds('fachinfo.rss', @app.sorted_fachinfos, View::Rss::Fachinfo)
      update_yearly_fachinfo_feeds
    end

    def TextInfoPlugin::replace_textinfo(app, new_ti, container, type) # description
      return unless type.is_a?(Symbol)
      old_ti = container.send(type)
      if old_ti
        # support update with only a de/fr description
        %w[de fr].each do |lang|
          if old_ti.descriptions and desc = new_ti.descriptions[lang]
            old_ti.descriptions[lang] = desc
            old_ti.descriptions.odba_isolated_store
          end
        end
        app.update(old_ti.pointer, {:descriptions => old_ti.descriptions})
      else
        app.update(container.pointer, {type => new_ti.pointer})
      end
    end
    def TextInfoPlugin::add_change_log_item(text_item, old_text, new_text, lang)
      msg = "add_change_log_item: update #{text_item.class} lang #{lang} #{text_item.class} #{old_text[-30..-1]} -> #{new_text[-30..-1]}"
      LogFile.debug msg
      $stdout.puts(msg); $stdout.sync
      text_item.add_change_log_item(old_text, new_text)
      text_item.odba_isolated_store
    end
    def TextInfoPlugin::store_fachinfo(app, reg, fis)
      puts "store_fachino #{reg.iksnr} #{fis.keys}"
      existing = reg.fachinfo
      ptr = Persistence::Pointer.new(:fachinfo).creator
      if existing
        TextInfoPlugin::Languages.each { |lang| eval("@old_text_#{lang} = existing.#{lang}.text") }
        ptr = existing.pointer
      end
      updated_fi = app.update ptr, fis
      if existing
        TextInfoPlugin::Languages.each do |lang|
          cmd = "if @old_text_#{lang} && @old_text_#{lang} != (new_text = updated_fi.#{lang}.text)
          TextInfoPlugin::add_change_log_item(updated_fi.#{lang}, @old_text_#{lang}, new_text, '#{lang}')
          end"
          eval(cmd)
        end
      else
        ptr = Persistence::Pointer.new(:fachinfo).creator
        app.update ptr, fis.keys
      end

      updated_fi
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
      atcFromXml =  @@iksnrs_meta_info.find{|key, val| key[0] == iksnr && val.first.atcCode}
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
        atc_class ||=  app.create(Persistence::Pointer.new([:atc_class, atcFromFI])) if atcFromFI
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
        atc_class ||=  app.create(Persistence::Pointer.new([:atc_class, atc_code]))
        registration.sequences.values.each{
          |sequence|
            LogFile.debug "ensure_correct_atc_code iksnr #{iksnr} save atc_code #{atc_code} (not same as atcFromXml #{atcFromXml}) in sequence #{sequence.seqnr}  atc_class #{atc_class} #{atc_class.oid}"
            res = app.update(sequence.pointer, { :atc_class => atc_class}, :swissmedic_text_info)
            sequence.odba_store
        }
        return
      end
      LogFile.debug "ensure_correct_atc_code iksnr #{iksnr} atcFromFI #{atcFromFI} atcFromXml #{atcFromXml}. What went wrong"
    end

    def update_fachinfo_lang(meta_info, fis, fi_flags = {})
      LogFile.debug "update_fachinfo #{meta_info}"
      unless meta_info.authNrs && meta_info.authNrs.size > 0
        @iksless[:fi].push meta_info.title
        return
      end
      return unless @options[:reparse]
      meta_info.authNrs.each do |iksnr|
        begin
          if reg = @app.registration(iksnr)
            ## identification of Pseudo-Fachinfos happens at download-time.
            #  but because we still want to extract the iksnrs, we just mark them
            #  and defer inaction until here:
            unless fi_flags[:pseudo] || fis.empty?
              LogFile.debug  "update_fachinfo #{meta_info.title} iksnr #{iksnr} store_fachinfo #{fi_flags} #{fis.keys} ATC #{meta_info.atcCode}"
              unless iksnr.to_i == 0
                fachinfo ||= TextInfoPlugin::store_fachinfo(@app, reg, fis)
                TextInfoPlugin::replace_textinfo(@app, fachinfo, reg, :fachinfo)
                ensure_correct_atc_code(@app, reg, meta_info.atcCode)
                @updated_fis += 1
              end
            end
          else
            LogFile.debug "update_fachinfo #{meta_info.title} iksnr #{iksnr} store_orphaned"
            store_orphaned iksnr, fis, :orphaned_fachinfo
            @unknown_iksnrs.store iksnr, meta_info.title
          end
        rescue RuntimeError => err
          @failures.push err.message
          []
        end
      end
    end

   def store_patinfo_for_one_packages(package, lang, patinfo_lang)
      LogFile.debug("store_patinfo_for_one_packages #{package.iksnr} #{lang} #{patinfo_lang.to_s[0..150]}")
      puts "store_patinfo_for_all_packages #{package.iksnr} #{lang} patinfo #{package.patinfo.to_s[0..150]}"
      package.patinfo = @app.create_patinfo unless package.patinfo
      package.patinfo.pointer = Persistence::Pointer.new([:patinfo]) unless package.patinfo.pointer
      eval("package.patinfo.descriptions['#{lang}']= patinfo_lang")
      package.patinfo.odba_store
      package.odba_store
      @corrected_pis << "#{package.iksnr} #{lang} #{package.name}"
    end

    def store_patinfo_for_all_packages(iksnr, lang, patinfo_lang)
      LogFile.debug("store_patinfo_for_all_packages #{iksnr} #{lang} #{patinfo_lang.to_s[0..150]}")
      puts         ("store_patinfo_for_all_packages #{iksnr} #{lang} #{patinfo_lang.to_s[0..150]}")
      reg = @app.registration(iksnr)
      puts "store_patinfo_for_all_packages #{reg.iksnr} #{lang}"
      existing = reg.packages.collect{ |package| package.patinfo }.compact.first
      ptr = Persistence::Pointer.new(:patinfo).creator
      old_text = {}
      pis =  {lang => patinfo_lang}
      if existing
        TextInfoPlugin::Languages.each do |a_lang|
          if lang.to_s.eql?(a_lang.to_s)
            puts "Skipping #{a_lang}"
            next
          end
          pis[a_lang] =  existing.description(a_lang)
        end
        ptr = existing.pointer
      end
      updated_pi = @app.update ptr, {lang => patinfo_lang}
      reg.packages.each do |package|
          package.instance_eval("@patinfo = nil")
      end
      reg.odba_store
      @corrected_pis << "#{iksnr} #{lang} #{reg.name_base}"
    end

    def update_patinfo_lang(meta_info, pis)
      LogFile.debug "update_patinfo #{meta_info} #{pis.keys}"
      unless meta_info.authNrs && meta_info.authNrs.size > 0
        @iksless[:pi].push meta_info.title
        return
      end
      return unless @options[:reparse]
      if pis.size != 1 || !pis.values.first
        puts "We expect pis.size to be 1 and valid, but it is #{pis}"
        return
        exit 3
      end
      meta_info.authNrs.each do |iksnr|
        begin
          if reg = @app.registration(iksnr)
            lang = meta_info.lang
            key = [ iksnr, meta_info.type, meta_info.lang ]
            return if @@iksnrs_meta_info[key].size == 0
            if  @@iksnrs_meta_info[key].size == 1 # Same PI for all packages
              pis.each { |lang, patinfo_lang| store_patinfo_for_all_packages(iksnr, lang, patinfo_lang) }
            else # more than 1 PI for iksnr found
              pis.each do|lang, patinfo_lang|
                next unless lang.to_s.eql?(meta_info.lang)
                @app.registration(iksnr).sequences.values.each do |sequence|
                  # force all sequences to empty patinfo
                  next unless sequence.pdf_patinfo && sequence.patinfo
                  sequence.pdf_patinfo = nil
                  sequence.patinfo = nil
                  sequence.odba_store
                end
                msg = "#{iksnr} #{lang}: #{meta_info.title}"
                @app.registration(iksnr).packages.each do |package|
                  barcode_override = "#{package.barcode}_#{meta_info.type}_#{lang}"
                  name = @@specify_barcode_to_text_info[barcode_override]
                  if meta_info.title.eql?(name)
                    puts "Updated as matched via #{barcode_override} -> #{name} #{package.instance_eval('@patinfo')}"
                    store_patinfo_for_one_packages(package, lang, patinfo_lang)
                    @corrected_pis << msg
                    @updated_pis << "  #{msg}"
                  elsif name
                    puts "Skipped: #{msg} != #{meta_info.title}"
                  else
                    puts "missing_override: not found via #{barcode_override}: '#{name}' != '#{meta_info.title}'"
                    @@missing_override << "#{barcode_override}: '#{meta_info.title}' # != override #{name}"
                  end
                end
              end
            end
          else
            LogFile.debug "update_patinfo #{meta_info.title} iksnr #{iksnr} store_orphaned"
            store_orphaned iksnr, pis, :orphaned_patinfo
            @unknown_iksnrs.store iksnr, meta_info.title
          end
        rescue RuntimeError => err
          @failures.push err.message
          []
        end
      end
    end

    def update_fachinfo name, iksnrs_from_xml, fis, fi_flags
      begin
        LogFile.debug "update_fachinfo #{name} iksnr #{iksnrs_from_xml} #{fis.keys}"
        return unless iksnrs_from_xml
        if iksnrs_from_xml.empty?
          @iksless[:fi].push name
        end
        ## Now that we have identified the pertinent iksnrs_from_xml, we can remove
        #  up-to-date fachinfos from the queue.
        if fi_flags[:de] && fi_flags[:fr] && !@options[:reparse]
          fis.clear
          @up_to_date_fis += 1
        end
        fachinfo = nil
        # assign infos.
        iksnrs_from_xml.each do |iksnr|
          if reg = @app.registration(iksnr)
            ## identification of Pseudo-Fachinfos happens at download-time.
            #  but because we still want to extract the iksnrs, we just mark them
            #  and defer inaction until here:
            unless fi_flags[:pseudo] || fis.empty?
              LogFile.debug  "update_fachinfo #{name} iksnr #{iksnr} store_fachinfo #{fi_flags} #{fis.keys} ATC #{fis.values.first.atc_code}"
              unless iksnr.to_i == 0
                fachinfo ||= TextInfoPlugin::store_fachinfo(@app, reg, fis)
                TextInfoPlugin::replace_textinfo(@app, fachinfo, reg, :fachinfo)
                ensure_correct_atc_code(@app, reg, fis.values.first.atc_code)
                @updated_fis += 1
              end
            end
          else
            LogFile.debug "update_fachinfo #{name} iksnr #{iksnr} store_orphaned"
            store_orphaned iksnr, fis, :orphaned_fachinfo
            @unknown_iksnrs.store iksnr, name
          end
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
    
    # pis is a hash of language => html
    def update_patinfo name, iksnrs_from_xml, pis, pi_flags
      begin
        puts_sync "update_patinfo #{name} iksnrs_from_xml #{iksnrs_from_xml} empty #{pis.empty?} keys #{pis.keys}"
        patinfo = nil
        return unless iksnrs_from_xml
        iksnrs_from_xml.each do |iksnr|
          reg = @app.registration(iksnr)
          unless reg
            puts_sync "No reg found for #{iksnr.inspect}"
          else
            unless pis.empty?
              lang = pis.keys.first.to_s
              name = pis.values.first.name
              @updated_pis << "  #{iksnr} #{lang}: #{name}"

              if patinfo and patinfo.pointer and @corrected_pis.index(patinfo.pointer.to_s)
                puts_sync "Already updated #{patinfo.pointer }"
              else
                patinfo ||= store_patinfo(reg, pis)
                puts_sync "update_patinfo.pointer #{iksnr} #{patinfo and patinfo.pointer ? patinfo.pointer : 'nil'}"
              end
              iksnrs_from_xml.each do |iksnr|
                @iksnr_to_pi[iksnr] ||= []
                @iksnr_to_pi[iksnr] << pis
              end if iksnrs_from_xml.size > 0
              refdata = @app.get_refdata_info(iksnr)
              puts_sync("@iksnr_to_pi[iksnr] #{iksnr} has #{@iksnr_to_pi[iksnr].size} entries")
              if @iksnr_to_pi[iksnr].size == 1
                lang = pis.keys.first.to_s
                puts "lang #{lang} name #{name} refdata #{refdata.values.first.collect{|x| [ x[:gtin], x[:name_fr], x[:name_de]] }}"
                reg.each_sequence do |seq|
                  # cut connection to pdf patinfo
                  puts_sync "update_patinfo #{name} iksnr #{iksnr} seq  #{seq.seqnr} update"
                  if !seq.pdf_patinfo.nil? and !seq.pdf_patinfo.empty?
                    seq.pdf_patinfo = ''
                    @app.update(seq.pointer, {:pdf_patinfo => ''}, :text_info)
                    seq.odba_isolated_store
                  end
                  TextInfoPlugin::replace_textinfo(@app, patinfo, seq, :patinfo)
                  @corrected_pis << patinfo.pointer.to_s
                end
              else
                puts "lang #{lang} name #{name} refdata #{refdata.values.first.collect{|x| [ x[:gtin], x[:name_fr], x[:name_de]] }}"
                reg.each_package do |pack|
                  # cut connection to pdf patinfo
                  puts_sync "update_patinfo #{name} iksnr #{iksnr} seq #{pack.seqnr} pack #{pack.ikscd} update"
                  if !pack.pdf_patinfo.nil? and !pack.pdf_patinfo.empty?
                    pack.pdf_patinfo = ''
                    @app.update(pack.pointer, {:pdf_patinfo => ''}, :text_info)
                    pack.odba_isolated_store
                  end
                  TextInfoPlugin::replace_textinfo(@app, patinfo, pack, :patinfo)
                  @corrected_pis << patinfo.pointer.to_s
                end
              end
            else
              puts_sync "update_patinfo #{name} iksnr #{iksnr} store_orphaned"
              store_orphaned iksnr, pis, :orphaned_patinfo
              @unknown_iksnrs.store iksnr, name
            end
          end
        end
      rescue RuntimeError => err
        @failures.push err.message
        puts_sync "update_patinfo RuntimeError #{err.message}"
        []
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
          "Stored #{@updated_fis} Fachinfos",
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
          "#{@nonconforming_content.size} non conforming contents: ",  @nonconforming_content.join("\n"),
          "#{@wrong_meta_tags.size} wrong metatags: ",                 @wrong_meta_tags.join("\n"),          
          "#{@fi_without_atc_code.size} FIs without an ATC-code",      @fi_without_atc_code.join("\n"),
          "#{@fi_atc_code_missmatch.size} FI in HTML != metadata",     @fi_atc_code_missmatch.join("\n"),
        ].join("\n")
      when :fi
        res = [
          "Searched for #{@search_term.join(', ')}",
          "Stored #{@updated_fis} Fachinfos",
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
          "#{@nonconforming_content.size} non conforming contents: ",  @nonconforming_content.join("\n"),
          "#{@wrong_meta_tags.size} wrong metatags: ",                 @wrong_meta_tags.join("\n"),
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
          "#{@nonconforming_content.size} non conforming contents: ",  @nonconforming_content.join("\n"),
          "#{@wrong_meta_tags.size} wrong metatags: ",                 @wrong_meta_tags.join("\n"),
        ].join("\n")
      end
      if @@missing_override.size > 0
        res << "#{Override_file}: Missing overrides are\n"
        res << @@missing_override.join("\n")
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

    def TextInfoPlugin::get_iksnrs_meta_info
      @@iksnrs_meta_info
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
      seq_args = { 
        :composition_text => nil,
        :name_base        => info.title,
        :name_descr       => nil,
        :dose             => nil,
        :sequence_date    => nil,
        :export_flag      => nil,
      }
      # sequence = app.update((registration.pointer + [:sequence, seqNr]).creator, seq_args, :text_plugin)
      sequence = registration.create_sequence(seqNr) unless sequence = registration.sequence(seqNr)
      sequence.name_base = info.title
      app.registrations[iksnr]=registration
      app.registrations.odba_store
      # pointer = reg_pointer + [:sequence, seq.seqnr]
      sequence.create_package(packNr)
      package = sequence.package(packNr)
      part = package.create_part
      res = app.update(sequence.pointer, seq_args, :swissmedic_text_info)
      registration.sequences[seqNr] = sequence
      sequence.fix_pointers
      registration.sequences.odba_store
      registration.odba_store
      LogFile.debug "Updating sequence #{iksnr} seqNr #{seqNr}  #{sequence.pointer} seq_args #{seq_args} registration.sequences #{registration.sequences}"
      registration
    end
    REFDATA_SERVER = DRbObject.new(nil, ODDB::Refdata::RefdataArticle::URI)

    def create_missing_registrations
      @@iksnrs_meta_info ||= {}
      @@iksnrs_meta_info.each do |key, infos|
        first_iksnr = infos.first.authNrs.first
        fi_info = @@iksnrs_meta_info.find{|key, value| key[0] == first_iksnr && key[1] ==  'fi' && key[2] == 'de' }
        fi_info = fi_info[1].first if fi_info
        infos.first.authNrs.each do |iksnr|
          unless @app.registration(iksnr)
            if @options[:iksnrs] && @options[:iksnrs].index(iksnr)
              info = fi_info.clone
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
    
    def identify_eventtargets page, ptrn
      eventtargets = {}
      page.links_with(:href => ptrn).each do |link|
        eventtargets.store link.text, eventtarget(link.href)
      end
      eventtargets
    end
    def search_company name, agent
      search 'rbFirma', name, agent
    end
    def search_fulltext term, agent
      search 'rbFulltext', term, agent
    end
    def search_product name, agent
      search 'rbPraeparat', name, agent
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
    def old_textinfo_news
      begin
        File.readlines(@news_log).collect do |line|
          line.strip
        end
      rescue Errno::ENOENT
        []
      end
    end
    def textinfo_news agent=init_agent
      url = ODDB.config.text_info_newssource \
        or raise 'please configure ODDB.config.text_info_newssource to proceed'
      names = {
        :fi => [],
        :pi => [],
      }
      page = agent.get url
      list = page.search('.//rss/channel/item')
      unless list.empty?
        list.each do |node|
          type = nil
          node.children.each do |element|
            if element.text? and element.text =~ /MonType=(fi|pi)$/
              type = $1.downcase.to_sym
              break
            end
          end
          if type
            names[type] << node.at('title').content
          end
        end
      end
      names
    end
    def import_companies page, agent, target=:both
      @target = target
      form = page.form_with :name => 'frmResulthForm'
      page.links_with(:href => /Linkbutton1/).each do |link|
        if et = eventtarget(link.href)
          @companies.push link.text
          @current_eventtarget = et
          products = submit_event agent, form, et
          import_products products, agent, target
        end
      end
    end
    def import_company names, agent=nil, target=:both
      @target = target
      agent = init_agent if agent.nil?
      @search_term += names.to_a
      names.to_a.each do |name|
        @current_search = [:search_company, name]
        # search for company
        page = search_company name, agent
        # import each company from the result
        import_companies page, agent, target
      end
    end
    def import_fulltext terms, agent=init_agent
      @search_term += terms.to_a
      terms.to_a.each do |term|
        @current_search = [:search_fulltext, term]
        page = search_fulltext term, agent
        import_products page, agent
      end
    end
    def import_name terms, agent=init_agent
      @search_term += terms.to_a
      terms.to_a.each do |term|
        @current_search = [:search_product, term]
        page = search_product term, agent
        import_products page, agent
      end
    end
    def import_news agent=init_agent
      updated = []
      old_news = old_textinfo_news
      news = textinfo_news(agent)
      news.keys.each do |type|
        if update_name_list = true_news(news[type], old_news)
          import_name(update_name_list, agent)
          log_news(news[type])
          type == :fi ? postprocess : nil
          updated.concat update_name_list
        end
      end
      return !updated.empty?
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

    def download_swissmedicinfo_xml
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
    def extract_image(name, type, lang, dist, iksnrs)
      if File.exists?(dist)
        resource_dir = (File.join(ODDB::IMAGE_DIR, type.to_s, lang.to_s))
        FileUtils.mkdir_p(resource_dir)
        html = File.open(dist, 'r:utf-8').read
        if html =~ /<img\s/
          images = Nokogiri::HTML(html).search('//img')
          html = nil
          name_base = File.basename(name.gsub(/®/, '').gsub(/[^A-z0-9]/, '_')).strip
          dir = File.join(resource_dir, name_base + '_files')
          FileUtils.mkdir_p(dir)
          images.each_with_index do |img, i|
            type,src = img.attributes['src'].to_s.split(',')
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
    def parse_and_update(names, type)
      # names eg. { :de => 'Alacyl'}
      iksnrs = []
      infos  = {}
      return [iksnrs,infos] unless @doc
      iksnrs_from_xml = nil
      name  = ''
      dist  = nil
      content = nil
      [:de, :fr].each do |lang|
        next unless names[lang]
        name = names[lang]
        saved = iksnrs_from_xml
        content, styles, title, iksnrs_from_xml = extract_matched_content(name, type, lang)

        unless saved == nil or saved != iksnrs_from_xml
          msg = "parse_and_update1: mismatch in #{iksnr} #{lang} saved #{saved} new #{iksnrs_from_xml}"
        else
          msg = "parse_and_update2: iksnrs_from_xml #{iksnrs_from_xml}"
        end
        msg += " content  #{content.to_s.size} size name #{name}"
        LogFile.debug msg
        puts_sync msg
        unless content
          msg = "parse_and_update3: No content found for name #{name}"
          LogFile.debug msg
          puts_sync msg
        else
          html = Nokogiri::HTML(content.to_s).to_s
          @title  = name
          @format = detect_format(html)
          # save as tmp
          path = File.join(ODDB.config.data_dir, 'html', type, lang.to_s)
          dist = File.join(path, name.gsub(CharsNotAllowedInBasename, '_') + '_swissmedicinfo.html')
          temp = dist + '.tmp'
          FileUtils.makedirs(File.dirname(dist))
          File.open(temp, 'w') { |fh| fh.puts(html) }
          File.open(dist.sub('.html', '.styles'), 'w+') { |fh| fh.puts(styles) }
          content,html = nil,nil
          update = false
          if iksnrs_from_xml.size > 0 && type == 'fachinfo' and @app.registration(iksnrs_from_xml[0]) and not @app.registration(iksnrs_from_xml[0]).fachinfo
            LogFile.debug "parse_and_update4: must add fachinfo for #{iksnrs_from_xml}"
            update = true
          elsif !@options[:reparse] and File.exists?(dist)
            if File.size(dist) != File.size(temp)
              update = true
            else
              @up_to_date_fis += 1 if type == 'fachinfo'
              @up_to_date_pis += 1 if type == 'patinfo'
            end
          else
            update = true
          end
          msg = "parse_#{type} reparse #{@options[:reparse]}dist #{dist} #{File.exists?(dist)} iksnrs_from_xml #{iksnrs_from_xml.inspect} #{File.basename(dist)}, name #{name} #{lang} title #{title}"
          if update
            FileUtils.mv(temp, dist)
            extract_image(name, type, lang, dist, iksnrs_from_xml)
            LogFile.debug "parse_and_update5: calls " + msg
            puts_sync "      Mismatch between title #{title} and name #{name}" unless name.eql?(title)
            infos[lang] = self.send("parse_#{type}", dist, styles)
            File.open(dist.sub('.html', '.yaml'), 'w+') { |fh| fh.puts(infos[lang].to_yaml) } unless defined?(Minitest)
          else
            LogFile.debug "parse_and_update6: no "  + msg
            File.unlink(temp)
          end
        end
      end
      LogFile.debug "#{type} empty? content #{content == nil} #{infos.empty?} iksnrs_from_xml #{iksnrs_from_xml} dist #{dist}"
      unless infos.empty?
        _infos = {}
        [:de, :fr].map do |lang|
          LogFile.debug "_infos #{lang} #{infos[lang].to_s[0..150] } #{infos[lang].class}"
          unless strange?(infos[lang])
            _infos[lang] = infos[lang]
          end
        end
        LogFile.debug "calling update_#{type} #{name}, #{iksnrs_from_xml}"
        self.send("update_#{type}", name, iksnrs_from_xml, _infos, {})
      end
      [iksnrs, infos]
    end
    def import_info(keys, names, state)
      keys.each_pair do |typ, type|
        next if names[:de].nil? or names[:de][typ].nil?
        # This importer expects same order of names in DE and FR, come from swissmedicinfo.
        names.each_pair do |lang, infos|
          infos[typ].each do |name, date|
            iksnrs,infos = parse_and_update({lang => name}, type)
            delete_patinfo iksnrs, lang if infos.empty? and type.eql?('patinfo') and iksnrs.size > 0

            # report
            unless infos.empty?
              info = strange?(infos[lang])
              if info == :nil
                @notfound <<
                  "  NOTFOUND : #{type.capitalize} - #{lang.to_s.upcase} - #{name}"
              elsif info == :invalid
                @invalid <<
                  "  INVALID : #{type.capitalize} - #{lang.to_s.upcase} - #{name}"
              end
            end
            date = (date ? " - #{date}" : '')
            nrs  = (!iksnrs.empty? ? " - #{iksnrs.inspect}" : infos[lang] ? TextInfoPlugin::get_iksnrs_from_string(infos[lang].iksnrs.to_s) : '')
            msg  = "  #{state.to_s.upcase} #{nrs}: #{type.capitalize} - #{lang.to_s.upcase} - #{name}#{date}#{nrs}"
            LogFile.debug "import_info msg #{msg}"
            puts_sync "import_info msg #{msg}"
            unless iksnrs.empty?
              next if name.nil? or name.empty?
              next if !infos.empty? and strange?(infos[lang])
              @skipped << msg
            else
              next if name.nil? or name.empty?
              @updated << msg
            end
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

    def check_swissmedicno_fi_pi(options = {}, patinfo_must_be_deleted = false)
      LogFile.debug "check_swissmedicno_fi_pi found  #{@app.registrations.size} registrations and #{@app.sequences.size} sequences. Options #{options}"
       parse_aips_download(@options)
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
      # Kernel.spawn("xmllint #{is_html ? '--html' : ''} --format --output #{filename} #{filename} 2>/dev/null")
    end
    # return
    def extract_html(meta_info)
      return nil, nil unless meta_info.xml_file && File.exist?(meta_info.xml_file)
      content = IO.read(meta_info.xml_file)
      html = /<content><!\[CDATA\[(.*)\]\]><\/content/mi.match(content)[1]
      html_name = meta_info.xml_file.sub('.xml', '.html')
      path = File.join(ODDB.config.data_dir, 'html', meta_info.type, meta_info.lang)
      html_name = File.join(path, meta_info.title.gsub(CharsNotAllowedInBasename, '_') + '.html')
      same_size = File.exist?(html_name) && File.size(html_name) == html.size
      FileUtils.makedirs(File.dirname(html_name))
      File.open(html_name, 'w+') {|f| f.write html } unless same_size
      m = /<style>(.*)<\/style>/.match(content)
      styles = m ? m[1] : ''
      call_xmllint(html_name, true)
      # puts "#{Time.now}: wrote #{html_name} #{File.size(html_name)} bytes"
      return [ html_name, styles, same_size ]
    end

    def parse_fachinfo(meta_info)
      puts "parse_fachinfo #{meta_info}"
      res = extract_html(meta_info)
      html_name = res[0]
      styles = res[1]
      same_size = res[2]
      update = false
      if meta_info.authNrs.size > 0 && @app.registration(meta_info.authNrs.first) && !@app.registration(meta_info.authNrs.first).fachinfo
        LogFile.debug "parse_fachinfo #{__LINE__}: must add fachinfo for #{meta_info.authNrs}"
        update = true
      elsif !@options[:reparse] && same_size
        @up_to_date_fis += 1
        return
      else
        LogFile.debug "parse_fachinfo #{__LINE__}: must add fachinfo for #{meta_info.authNrs}"
        update = true
      end
      extract_image(meta_info.title, meta_info.type, meta_info.lang, styles, meta_info.authNrs)
      fi = @parser.parse_fachinfo_html(html_name, @format, meta_info.title, styles)
      update_fachinfo_lang(meta_info, { meta_info.lang.to_sym => fi } )
    end

    def parse_patinfo(meta_info)
      puts "parse_patinfo #{meta_info}"
      res = extract_html(meta_info)
      html_name = res[0]
      styles = res[1]
      same_size = res[2]
      if meta_info.authNrs.size > 0 && @app.registration(meta_info.authNrs.first) &&
          ( !@app.registration(meta_info.authNrs.first).packages.first ||
            !@app.registration(meta_info.authNrs.first).packages.first.patinfo)
        LogFile.debug "parse_patinfo #{__LINE__}: must add patinfo for #{meta_info.authNrs}"
        update = true
      elsif !@options[:reparse] && same_size
        @up_to_date_pis += 1
        return
      else
        LogFile.debug "parse_patinfo #{__LINE__}: must add patinfo for #{meta_info.authNrs}"
        update = true
      end
      extract_image(meta_info.title, meta_info.type, meta_info.lang, styles, meta_info.authNrs)
      pi = @parser.parse_patinfo_html(html_name, @format, meta_info.title, styles)
      LogFile.debug "parse_patinfo #{__LINE__}: pi  #{pi.to_s[0..150]}"
      update_patinfo_lang(meta_info, { meta_info.lang.to_sym => pi } )
    end

    def handle_chunk(chunk, dir)
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
      if m =/<authNrs>([^<]+)</.match(chunk) then meta_info.authNrs = m[1].split(', ') end
      if m =/<atcCode>([^<]+)</.match(chunk) then meta_info.atcCode = m[1].split(' ')[0] end
      info = "#{meta_info.iksnr}_#{meta_info.type}_#{meta_info.lang}"
      @@iksnr_lang_type[info] =  meta_info.title unless @@iksnr_lang_type[info]
      outfile = File.join(dir, info + '.xml')
      is_duplicate = false
      if File.exist?(outfile)
        @@iksnrs_from_aips << meta_info.iksnr
        @duplicate_entries << info + ': "' + @@iksnr_lang_type[info] + '"' # was first
        @duplicate_entries << info + ': "' + meta_info.title + '"' # was duplicate
        outfile = File.join(dir,  info + '_' + meta_info.title.gsub(/[^\w]/, '_') + '_problem.xml')
        is_duplicate = true
      end
      File.open(outfile, 'w+') { |f| f.write(chunk) }
      # Tidy it up
      call_xmllint(outfile)
      meta_info.xml_file = outfile
      # puts "#{Time.now}: wrote #{outfile} #{File.size(outfile)} bytes" if is_duplicate
      meta_info
    end

    def report_problematic_names
      filename = 'problematic_fi_pi.lst'
      puts "#{Time.now}: Creating #{filename}"
      File.open('problematic_fi_pi.lst', 'w+') do |file|
        @@iksnrs_from_aips.sort.uniq.each { |iksnr| file.puts iksnr }
        @@iksnrs_from_aips.sort.uniq.each do|iksnr|
          @app.registration(iksnr).packages.each do |pack|
            file.puts "#{iksnr} #{pack.barcode} #{pack.name}"
          end if @app.registration(iksnr)
        end
        @duplicate_entries.sort.uniq.each { |duplicate| file.puts duplicate }
        file.sync = true
        begin
          @@iksnrs_from_aips.sort.uniq.each do |iksnr|
            next if iksnr.to_i == 0
            # puts "#{Time.now}: getting refdatainfo for #{iksnr}"
            # file.puts @app.get_refdata_info(iksnr)
          end
        rescue DRb::DRbConnError => err
          puts "err #{err} in report_problematic_names"
        end
      end
      puts "#{Time.now}: created #{filename}"
      LogFile.debug "created #{filename}"
    end

    def parse_aips_download(target)
      puts "parse_aips_download with target #{target}"
      @@iksnrs_from_aips = []
      @@iksnr_lang_type = {}
      @aips_xml = @options[:xml_file] if @options[:xml_file]
      dirname = File.join(File.dirname(File.dirname(@aips_xml)), 'details')
      FileUtils.rm_rf(dirname, verbose: true)
      FileUtils.makedirs(dirname, verbose: true)
      return unless File.exist?(@aips_xml)
      content = IO.read(@aips_xml)
      puts "#{Time.now}: read #{content.size} bytes"
      @to_parse = []
      content.split('</medicalInformation>').each do |chunk|
        meta_info = handle_chunk(chunk, dirname)
        next unless meta_info
        if meta_info.authNrs.size == 0
          puts_sync "get_meta_info no authNrs found for #{info} with all_numbers #{all_numbers}"
        else
          meta_info.authNrs.each do |iksnr|
            meta_info.iksnr = iksnr
            key = [ iksnr, meta_info.type, meta_info.lang ]
            key_string = "#{iksnr}_#{meta_info.type}_#{meta_info.lang}"
            @@iksnrs_meta_info[key] ||= []
            @@iksnrs_meta_info[key] << meta_info.clone
            reg = @app.registration(iksnr)
            @@iksnrs_meta_info[key].each do |info|
              unless info.authHolder.eql?(reg.company.to_s)
                nrEntries = @@iksnrs_meta_info[key].find_all{ |x| x.authHolder.eql?(reg.company.to_s) }.size
                puts "Mismatching authHolder #{iksnr} meta #{meta_info.authHolder} != db #{reg.company.to_s}. Has #{nrEntries}/#{@@iksnrs_meta_info[key].size} entries"
                if nrEntries >= 1
                  @@iksnrs_meta_info[key].delete_if{ |x| !x.authHolder.eql?(reg.company.to_s) }
                  @duplicate_entries.delete_if{ |x| x.index(key_string) == 0} if nrEntries == 1
                  puts "Mismatching authHolder #{iksnr}. Has now #{@@iksnrs_meta_info[key].size} entries"
                else
                  puts "Could not delete Mismatching authHolder #{iksnr}. Still #{@@iksnrs_meta_info[key].size} entries"
                end
                puts "Mismatching authHolder #{iksnr}. Has #{@duplicate_entries.find_all{ |x| x.index(key_string) == 0}.size } @duplicate_entries"
              end if @@iksnrs_meta_info[key].size > 1
            end if reg
          end
        end
        if target == :both || target.to_s.eql?(meta_info.type)
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
      puts "created #{@@iksnrs_meta_info.size} @@iksnrs_meta_info"
      create_missing_registrations
      report_problematic_names
    end
  public
    def import_swissmedicinfo(target=@options[:target])
      $stdout.sync = true
      @@specify_barcode_to_text_info = {}
      @@specify_barcode_to_text_info = YAML.load(File.read(Override_file)) if File.exist?(Override_file)

      @options[:target] = target
      @options[:target] ||= :both
      threads = []
      if @options[:download] != false
        threads << Thread.new do
          download_swissmedicinfo_xml
        end
      end
      threads.map(&:join)
      parse_aips_download(target)
      GC.start
      @to_parse.sort{|x,y| x.iksnr.to_i <=> y.iksnr.to_i}.each do |meta_info|
        puts "Parsing #{meta_info}"
        GC.start
        already_disabled = GC.disable # to prevent method `method_missing' called on terminated object
        parse_fachinfo(meta_info) if meta_info[:type] == 'fi' ||  meta_info[:type] == 'both'
        parse_patinfo(meta_info) if meta_info[:type] == 'pi' ||  meta_info[:type] == 'both'
        GC.enable unless already_disabled
      end
      File.open('missing_override.lst', 'w+') {|f| f.puts  @@missing_override.join("\n")}
      if @options[:download] != false
        puts_sync "job is done. now postprocess works ..."
        postprocess
      end
      true # report
    end
  end
end
