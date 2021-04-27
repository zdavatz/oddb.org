#!/usr/bin/env ruby

# This file is responsible for merging the actual content of the Packungen.xlsx from SwissMedic into the ODDB database.
# Its features include
#   * update/check can be limited to some IKSRN by passing opts[:iksnrs] (only used by jobs/import_swissmedic_only)
#   * create a nice, human readable mail about the changes made
#   * downloads packungen.xlsx and Präparateliste.xlsx from the Swissmedic
#   * leaves exactly one copy of the downloaded packungen.xlxs in the format data/xls/Packungen-2017.09.07.xlsx
#   * leaves exactly one copy of the downloaded Präparateliste.xlxs in the format data/xls/Präparateliste-2017.09.07.xlsx
#   * ignore drugs only for veterinary use
#   * reports missing fachinfos @missing_fis
#   * delete inactive_agents
#   * delete all packages, but not the sequences when a registration is no longer in the swissmedic packungen (means that the registration was revoked)
#   * update all relevant fields, like name, compositions, expiration_date for the corresponding package, sequence and registration
#   * updates existing compositions only if option update_compositions is given
#   * updated galenic_form only if option fix_galenic_form is given
#   * optionally check all package
#   * uses parslet/compositions from oddb2xml gem to create correct fields for compositions, size, unit, etc
#   * atc_code using the best one available (epha, refdata, packungen.xlxs)
#   * check whether the Gültigkeits-datum (column 'J') is present or not
#   * updates the export_flag for packages and sequences as seen by reading data/xls/Präparateliste-latest.xlsx
#   * limit its own memory useage to 16 GB

require 'fileutils'
require 'ostruct'
require 'plugin/plugin'
require 'pp'
require 'util/persistence'
require 'util/today'
require 'swissmedic-diff'
require 'util/logfile'
require 'parslet'
require 'parslet/convenience'

# Some monkey patching needed to avoid an error
module RubyXL
  class Row < OOXMLObject
    def first
       cells[0]
    end
  end
end

module ODDB
  class SwissmedicPlugin < Plugin
    attr_reader :checked_compositions, :updated_agents, :new_agents, :known_sequences
    PREPARATIONS_COLUMNS = [ :iksnr, :seqnr, :name_base, :company, :export_flag,
      :index_therapeuticus, :atc_class, :production_science,
      :sequence_ikscat, :ikscat, :registration_date, :sequence_date,
      :expiry_date, :substances, :composition, :indication_registration, :indication_sequence ]
    include SwissmedicDiff::Diff
    GALFORM_P = %r{excipiens\s+(ad|pro)\s+(?<galform>((?!\bpro\b)[^.])+)}u
    SCALE_P = %r{pro\s+(?<scale>(?<qty>[\d.,]+)\s*(?<unit>[kcmuµn]?[glh]))}u
    $swissmedic_memory_error = nil
    DATE_FORMAT = '%d.%m.%Y'
    BASE_URL = 'https://www.swissmedic.ch'

    def self.get_packages_url
      @@packages_url
    end
    def self.get_preparations_url
      @@gpreparations_url
    end

    def self.get_memory_error
      $swissmedic_memory_error
    end

private
    def date_cell(row, idx)
      return nil unless row[idx]
      row_value = row[idx]
      return nil unless row_value.value
      return SwissmedicDiff::VALUE_UNLIMITED if SwissmedicDiff::REGEXP_UNLIMITED.match(row_value.value.to_s)
      return Date.parse row_value.value.to_s if row_value.is_a?(RubyXL::Cell)
      row_value
    end
public
    def initialize(app=nil, archive=ARCHIVE_PATH)
      doc = Nokogiri::HTML(URI.open(BASE_URL + '/swissmedic/de/home/services/listen_neu.html'))
      @@packages_url = BASE_URL + doc.xpath("//a").find{|x| /Zugelassene Packungen/.match(x.children.text) }.attributes['href'].value
      @@gpreparations_url = BASE_URL + doc.xpath("//a").find{|x| /Erweiterte Arzneimittelliste/.match(x.children.text) }.attributes['href'].value
      @comarketing_url = BASE_URL + doc.xpath("//a").find{|x| /Zugelassene Co-Marketing-Humanarzneimittel/.match(x.children.text) }.attributes['href'].value
      doc = nil
      super app
      @archive = File.join archive, 'xls'
      FileUtils.mkdir_p @archive
      init_stats
    end

    def self.get_memory_error
      $swissmedic_memory_error
    end

    def init_stats
      @recreate_missing = []
      @known_export_registrations = 0
      @known_export_sequences = 0
      @checked_compositions = []
      @deleted_compositions = []
      @new_compositions = {}
      @updated_agents = {}
      @new_agents = {}
      @export_registrations = {}
      @updated_expiration_dates = {}
      @export_sequences = {}
      @skipped_packages = []
      @iksnr_with_wrong_data = []
      @active_registrations_praeparateliste = {}
      @update_time = 0 # minute
      @target_keys = Util::COLUMNS_FEBRUARY_2019
      @empty_compositions = []
      @known_packages = []
      @deletes_packages = []
      @unparsed_compositions = []
    end

    # traces many details of changes. Use it for debugging purposes
    def trace_msg(msg)
      return
      $stdout.puts "#{Time.now.to_s } #{File.basename(caller[0])}: #{msg}"
    end

    def mustcheck(iksnr, opts = {})
      res = true
      idx = -999
      if opts[:update_compositions]
        # LogFile.debug " iksnr #{iksnr} mustcheck #{res} opts #{opts}"
        return true if opts[:iksnrs]&.size==0
        return !!opts[:iksnrs]&.index(iksnr)
      end
      if opts[:iksnrs] == nil or idx = opts[:iksnrs].index(iksnr)
        # LogFile.debug " iksnr #{iksnr} mustcheck #{res} opts #{opts} idx #{idx}"
        return res
      end
      # LogFile.debug " iksnr #{iksnr} mustcheck false opts #{opts} idx #{idx}"
      return false
    end

    def store_found_packages(latest_xslx)
      workbook = Spreadsheet.open(latest_xslx)
      workbook.worksheets[0].each_with_index do
        |row, index|
        break unless row
        iksnr   = "%05i" % cell(row, @target_keys.keys.index(:iksnr)).to_i
        next if iksnr.to_i == 0
        science = cell(row, @target_keys.keys.index(:production_science))
        if (science.eql?('Tierarzneimittel'))
          if (registration = @app.registration(iksnr))
            LogFile.debug("store_found_packages delete Tierarzneimittel #{iksnr}")
            @app.delete_registration(iksnr)
          else
            # LogFile.debug("store_found_packages skip Tierarzneimittel #{iksnr}")
          end
          next
        end
        seqnr   = "%02i" % cell(row, @target_keys.keys.index(:seqnr)).to_i
        packnr  = "%03i" % cell(row, @target_keys.keys.index(:ikscd)).to_i
        key = [iksnr, seqnr, packnr]
        reg = @app.registration(iksnr)
        seq = reg.sequence(seqnr) if reg
        unless reg && seq && seq.package(packnr)
          LogFile.debug "store_found_packages: recreate_missing #{key}"
          @recreate_missing << key
          update_registrations([row], {}, nil)
        end
        pack = seq.package(packnr) if reg && seq && seq.package(packnr)
        if pack && !pack.sequence # eg. we have a missing Ebixa package in database
          LogFile.debug "store_found_packages: fix missing sequence in #{key}"
          pack.sequence = seq
          pack.odba_store
        end
        @known_packages << key
      end
    end

    def verify_packages(file2open)
      @deletes_packages = []
      @missing_fis = []
      if file2open and File.exists?(file2open)
        store_found_packages(file2open)
        @known_packages.sort!.uniq!
        LogFile.debug "verify_packages from #{file2open} #{@app.registrations.size} registrations and #{@known_packages.size}" +
            " @known_packages from #{@known_packages.first} till #{@known_packages.last}"
        @app.registrations.each do
          |iksnr, reg|
          # LogFile.debug "verify_packages check #{iksnr.inspect}. #{@deletes_packages.size} @deletes_packages"
          next if iksnr.eql?('00000')
          next if iksnr.to_s.size != 5
          unless reg.fachinfo
            if @known_packages.find{|x| x[0].to_i == iksnr.to_i}
              # LogFile.debug "verify_packages: Missing fi for #{iksnr}" # There are about 1200 occurrences of this, eg. Testlösung zur Allergiediagnose Teomed
              @missing_fis << iksnr
            end
          end
          reg.active_packages.each do
            |pack|
            found = @known_packages.find { |x| x[0].to_i == pack.iksnr.to_i && x[1].to_i == pack.seqnr.to_i && x[2].to_i == pack.ikscd.to_i}
            unless found
              LogFile.debug "verify_packages delete #{iksnr} #{pack.seqnr} #{pack.ikscd}"
              already_disabled = GC.disable # to prevent method `method_missing' called on terminated object
              pack.sequence.delete_package(pack.ikscd)
              pack.sequence.odba_isolated_store
              @deletes_packages << [pack.iksnr, pack.seqnr, pack.ikscd]
              GC.enable unless already_disabled
              return
            end
          end
        end if @known_packages.size > 0
        LogFile.debug "verify_packages deactivated #{@deletes_packages.size} @deletes_packages"
      end
    end

    def show_memory_useage
      @max_mbytes ||= (16 * 1024) # Good default is 16 GB, afterwards the server slows down a lot
      bytes = File.read("/proc/#{$$}/stat").split(' ').at(22).to_i
      @mbytes = (bytes / (2**20)).to_i
      LogFile.debug("Using #{@mbytes} MB of memory. Limit is #{@max_mbytes}. Swissmedic_do_tracing #{$swissmedic_do_tracing.inspect}")
    end
    def trace_memory_useage
      max_mbytes = 16 * 1024 # Good default is 16 GB, afterwards the server slows down a lot
      while $swissmedic_do_tracing
        show_memory_useage
        startTime = Time.now
        # Check done every second
        0.upto(60) do |idx|
          if @mbytes > @max_mbytes # Exit process if more than @max_mbytes are used to avoid bringing the server down"
            msg = "Aborting as using #{@mbytes} MB of memory > than limit of #{@max_mbytes}"
            LogFile.debug(msg)
            $swissmedic_memory_error = msg
            Thread.main.raise SystemExit
          end
          sleep(1)
          next if (Time.now-startTime).to_i > 60 # report time every 60 seconds,regardless of CPU useage
          break unless $swissmedic_do_tracing
        end
      end
    end

    def check_all_packages(file2open)
      workbook = Spreadsheet.open(file2open)
      Util.check_column_indices(workbook.worksheets[0])
      @target_keys = Util::COLUMNS_FEBRUARY_2019 if @target_keys.is_a?(Array)
      listed_packages = []
      row_nr = 0
      workbook.worksheets[0].each() do
        |row|
        row_nr += 1
        next if row_nr <= 4
        break unless row
        next unless cell(row, 0).to_i > 0
        next if (cell(row, @target_keys.keys.index(:production_science)) == 'Tierarzneimittel')
        iksnr =  cell(row, @target_keys.keys.index(:iksnr)).to_i
        seqnr =  cell(row, @target_keys.keys.index(:seqnr)).to_i
        ikscd =  cell(row, @target_keys.keys.index(:ikscd)).to_i
        already_disabled = GC.disable # to prevent method `method_missing' called on terminated object
        reg = @app.registration("%05i" %iksnr)
        old_date = reg.expiration_date ? reg.expiration_date.strftime(DATE_FORMAT) : nil
        if cell(row, @target_keys.keys.index(:expiry_date)).to_s.match(/unbegrenzt/i)
          puts "Setting unbegrenzt for #{iksnr} #{seqnr} #{ikscd}"
          new_date = nil # Date.new(2099,12,31).strftime(DATE_FORMAT)
        else
          new_date = Date.parse(cell(row, @target_keys.keys.index(:expiry_date))).strftime(DATE_FORMAT)
        end
        unless old_date&.eql?(new_date)
          reg.expiration_date = Date.parse(new_date)
          reg.odba_store
          @updated_expiration_dates[iksnr] = new_date
          LogFile.debug "reg #{iksnr} changed expiration_date #{old_date} -> #{new_date}"
        end
        seq = reg.sequence("%02i" %seqnr) if reg
        pack = seq.package("%03i" %ikscd) if seq
        if iksnr != 0 && !pack
          LogFile.debug("Unable to find pack for #{iksnr}/#{seqnr}/#{ikscd}")
        else
          if reg && seq
            update_package(reg, seq, row)
            seq.packages.odba_store
            seq.odba_store
          else
            LogFile.debug("Unable to find reg/seq for #{iksnr}/#{seqnr}/#{ikscd}")
          end
        end
        GC.enable unless already_disabled
        trace_msg"update finished iksnr #{iksnr} seqnr #{seqnr} check #{reg == nil} #{seq == nil}"
      end
      LogFile.debug "update check done"
    end

    def update(opts = {}, file2open=get_latest_file('Packungen'))
      @@loaded ||= false
      begin
        @@loaded = true
        filename = File.join(File.expand_path(File.dirname(__FILE__)), 'parslet_compositions.rb')
        Kernel::load(filename) # We delay the inclusion to avoid defining a module wide method substance in Parslet
        LogFile.debug("Loaded #{filename}")
      rescue => error
        LogFile.debug("Error loading parslet_compositions.rb #{filename} #{error}")
      end unless @@loaded
      $swissmedic_do_tracing = true
      start_time = Time.new
      threads = []
      threads << Thread.new do trace_memory_useage end
      sleep 0.01 unless threads.last
      if threads.last
        threads.last.priority = threads.last.priority + 1
      end
      @update_comps = (opts and opts[:update_compositions])
      cleanup_active_agents_with_nil if @update_comps || opts[:check]
      init_stats
      msg = "opts #{opts} @update_comps #{@update_comps} update file2open #{file2open.inspect} "
      msg += "#{File.size(file2open)} bytes. " if file2open && File.exists?(file2open)
      msg += "Latest #{@latest_packungen} #{File.size(@latest_packungen)} bytes" if @latest_packungen and File.exists?(@latest_packungen)
      LogFile.debug(msg)
      row_nr = 4
      if @update_comps
        file2open && File.exists?(file2open)
        file2use = file2open if file2open && File.exists?(file2open)
        file2use ||= @latest_packungen if @latest_packungen && File.exists?(@latest_packungen)
        @iksnrs_to_import =[]
        opts[:fix_galenic_form] = true
        last_checked = nil
        LogFile.debug("file2use #{file2use} checked #{file2open} and #{@latest_packungen}")
        workbook = Spreadsheet.open(file2use)
        Util.check_column_indices(workbook.worksheets[0])
        @target_keys = Util::COLUMNS_FEBRUARY_2019 if @target_keys.is_a?(Array)
        workbook.worksheets[0].each() do
          |row|
          row_nr += 1
          next if row_nr <= 4
          break unless row
          next if (cell(row, @target_keys.keys.index(:production_science)) == 'Tierarzneimittel')
          iksnr =  cell(row, @target_keys.keys.index(:iksnr)).to_i
          seqnr =  cell(row, @target_keys.keys.index(:seqnr)).to_i
          to_be_checked = [iksnr, seqnr]
          next if last_checked == to_be_checked
          last_checked = to_be_checked
          to_consider = mustcheck(iksnr, opts)
          # LogFile.debug " update #{row_nr} iksnr #{iksnr} seqnr #{seqnr} #{to_consider} to_be_checked #{to_be_checked}"
          next unless to_consider
          already_disabled = GC.disable # to prevent method `method_missing' called on terminated object
          reg = @app.registration("%05i" %iksnr)
          seq = reg.sequence("%02i" %seqnr) if reg
          update_all_sequence_info(row, reg, seq) if reg and seq
          GC.enable unless already_disabled
          trace_msg "update finished iksnr #{iksnr} seqnr #{seqnr} check #{reg == nil} #{seq == nil}"
        end
        @update_time = ((Time.now - start_time) / 60.0).to_i
      elsif(file2open)
        LogFile.debug(msg)
        msg =  "#{__FILE__}: #{__LINE__} Comparing #{file2open} "
        msg +=  File.exists?(file2open) ? "#{File.size(file2open)} bytes " : " absent" if file2open
        msg += " with #{@latest_packungen} "
        msg +=  File.exists?(@latest_packungen) ? "#{File.size(@latest_packungen)} bytes " : " absent" if @latest_packungen
        LogFile.debug(msg)
        result = diff file2open, @latest_packungen, [:sequence_date]
        # check diff from stored data about date-fields of Registration
        check_date! unless @update_comps
        if @latest_packungen and File.exists?(@latest_packungen)
          LogFile.debug " Compared #{file2open} #{File.size(file2open)} bytes with #{@latest_packungen} #{File.size(@latest_packungen)} bytes"
        else
          LogFile.debug " No latest_packungen #{@latest_packungen} exists"
        end
        LogFile.debug " @update_comps #{@update_comps}. opts #{opts}. Found #{@diff.news.size} news, #{@diff.updates.size} updates, #{@diff.replacements.size} replacements and #{@diff.package_deletions.size} package_deletions"
        LogFile.debug " changes: #{@diff.changes.size}"
        LogFile.debug " first news: #{@diff.news.first.inspect[0..250]}"
        update_registrations(@diff.news + @diff.updates, @diff.replacements, opts)
        sanity_check_deletions(@diff)
        delete(@diff.package_deletions, true)
        # check the case in which there is a sequence or registration in Praeparateliste.xlsx
        # but there is NO sequence or registration in Packungen.xlsx
        #recheck_deletions @diff.sequence_deletions # Do not consider Preaparateliste_mit_WS.xlsx when setting the "deaktiviert am" date.
        #recheck_deletions @diff.registration_deletions # Do not consider Preaparateliste_mit_WS.xlsx when setting the "deaktiviert am" date.
        deactivate @diff.sequence_deletions
        deactivate @diff.registration_deletions
        verify_packages(file2open)
        update_export_flags
        check_all_packages(@latest_packungen) if opts[:check]
        end_time = Time.now - start_time
        @update_time = (end_time / 60.0).to_i
        if File.exists?(file2open) and File.exists?(@latest_packungen) and FileUtils.compare_file(file2open, @latest_packungen)
          LogFile.debug " rm_f #{file2open} after #{@update_time} minutes"
          FileUtils.rm_f(file2open, verbose: true)
        else
          LogFile.debug " cp #{file2open} #{@latest_packungen} after #{@update_time} minutes"
          FileUtils.cp file2open, @latest_packungen, verbose: true
        end
        @change_flags = @diff.changes.inject({}) { |memo, (iksnr, flags)|
          memo.store Persistence::Pointer.new([:registration, iksnr]), flags
          memo
        }
      else
        LogFile.debug("@update_comps #{@update_comps} check_all_packages #{opts[:check]}")
        check_all_packages(@latest_packungen) if opts[:check]
        end_time = Time.now - start_time
        @update_time = (end_time / 60.0).to_i
        LogFile.debug("file2open #{file2open} nothing to do for opts #{opts}")
        false
      end
      LogFile.debug " done. #{@export_registrations.size} export_registrations @update_comps was #{@update_comps} with #{@diff ? "#{@diff.changes.size} changes" : 'no change information'}"
      $swissmedic_do_tracing = false
      threads.map(&:join)
      sleep(1.1)
      threads.map(&:join)
      @update_comps ? true : @diff
    ensure
      $swissmedic_do_tracing = false
    end
    # check diff from overwritten stored-objects by admin
    # about data-fields
    def check_date!
      @diff.newest_rows.values.each do |obj|
        obj.values.each do |row|
          # File used is row.worksheet.workbook.root.filepath
          @target_keys = Util::COLUMNS_FEBRUARY_2019 if @target_keys.is_a?(Array)
          iksnr = "%05i" % cell(row, @target_keys.keys.index(:iksnr)).to_i
          if reg = @app.registration(iksnr.to_s)
            {
              :registration_date => @target_keys.keys.index(:registration_date),
              :expiration_date   =>   @target_keys.keys.index(:expiry_date)
            }.each_pair do |field, i|
              # if future date given
              date = date_cell(row, i)
              reg_value = reg.send(field)
              if date and not reg_value
                @diff.updates << row
                next
              elsif date and reg_value and reg_value.is_a?(Date) and date.start > reg_value.start
                @diff.updates << row
              end
            end
          end
        end
      end
      @diff.updates.uniq!
    end
    def update_export_flags
      initialize_export_registrations # Takes a long time (3 minutes)
      set_all_export_flag_false
      update_export_sequences @export_sequences
      update_export_registrations @export_registrations
    end
    def set_all_export_flag_false
      LogFile.debug "set_all_export_flag_false for #{@app.registrations.size} registrations #{@known_export_registrations.size} known_export_registrations"
      @app.each_registration do |reg|
        # registration export_flag
        if reg.export_flag
          @known_export_registrations += 1
          @app.update(reg.pointer, {:export_flag => false}, :admin)
        end
        # sequence export_flag
        reg.sequences.values.each do |seq|
          next unless seq.is_a? ODDB::Sequence
          if seq.export_flag
            @known_export_sequences += 1
            @app.update seq.pointer, {:export_flag => false}, :admin
          end
        end
      end
      LogFile.debug "set_all_export_flag_false  #{@known_export_registrations.size} known_export_registrations #{@known_export_sequences.size} known_export_sequences done"
    end
    def capitalize(string)
      string.split(/\s+/u).collect { |word| word.capitalize }.join(' ')
    end
    def cell(row, pos)
      if str = super
        str.gsub(/\n\r|\r\n?/u, "\n").gsub(/[ \t]+/u, ' ')
      end
    end
    def recheck_deletions(deletions)
      key_list = []
      deletions.each do |key|
        # check if there is the sequence/registration in the Praeparateliste-latest.xlsx
        # if there is, do not deactivate the sequence/registration
        if @active_registrations_praeparateliste[key[0]]
          key_list << key
        end
      end
      key_list.each do |key|
        deletions.delete(key)
      end
    end
    def deactivate(deactivations)
      deactivations.each { |row|
        iksnr = "%05i" % cell(row, @target_keys.keys.index(:iksnr)).to_i
        seqnr = "%02i" % cell(row, @target_keys.keys.index(:seqnr)).to_i
        LogFile.debug ": deactivate iksnr '#{iksnr}' seqnr #{seqnr} pack #{@target_keys.keys.index(:ikscd)}"
        if row.length == 1 # only in the case of registration_deletions
          @app.update pointer(row), {:inactive_date => @@today, :renewal_flag => nil, :renewal_flag_swissmedic => nil}, :swissmedic
        else # the case of sequence_deletions
          next if defined?(SwissmedicPluginTestXLSX2021)
          @app.update pointer(row), {:inactive_date => @@today}, :swissmedic
        end
      }
    end
    def delete(deletions, is_package_deletion = false)
      LogFile.debug " delete #{deletions.size} items"
      deletions.each_with_index do
        |row, index|
        iksnr = "%05i" % row[0].to_i
        seqnr = "%02i" % row[1].to_i
        packnr = "%03i" % row[2].to_i
        ptr = pointer(row)
        next unless ptr
        unless is_package_deletion
          @app.delete ptr
        else
          object = defined?(SwissmedicPluginTestXLSX2021) ? nil : @app.resolve(ptr)
          next unless object
          if object.is_a?(ODDB::Package)
            found = @app.registration(iksnr)  &&
              @app.registration(iksnr).sequence(seqnr) &&
              @app.registration(iksnr).sequence(seqnr).packages.keys.index(packnr)
            LogFile.debug "(#{index} of #{deletions.size}) iksnr #{iksnr} seqnr #{seqnr} pack #{packnr} found #{found} ptr #{ptr}"
            @app.delete ptr if found
          end
        end
      end
    end
    def describe(diff, iksnr)
      sprintf("%s: %s", iksnr, name(diff, iksnr))
    end
    def describe_flag(diff, iksnr, flag)
      txt = FLAGS.fetch(flag, flag)
      case flag
      when :sequence
      when :replaced_package
        pairs = diff.newest_rows[iksnr].collect { |rep, row|
          if(old = diff.replacements[row])
            [old, rep].join(' -> ')
          end
        }.compact
        sprintf "%s (%s)", txt, pairs.join(',')
      when :registration_date, :expiry_date
        row = diff.newest_rows[iksnr].sort.first.last
        sprintf "%s (%s)", txt,
                date_cell(row, @target_keys.keys.index(flag)).strftime('%d.%m.%Y')
      else
        row = diff.newest_rows[iksnr].sort.first.last
        sprintf "%s (%s)", txt, cell(row, @target_keys.keys.index(flag))
      end
    end
    def known_data(latest)
      data = super
      ## remove Export-Registrations from known data
      data.first.delete_if do |iksnr, row| @export_registrations[iksnr] end
      data
    end
    def _known_data(latest, known_regs, known_seqs, known_pacs, newest_rows)
      if (latest and File.exist? latest)
        super
      else
        latest = nil
        @app.registrations.each do |iksnr, reg|
          row = [ iksnr, nil, nil, reg.company_name,
                  reg.ith_swissmedic || reg.index_therapeuticus,
                  reg.production_science, reg.registration_date,
                  reg.expiration_date ]
          unless reg.inactive? || reg.vaccine
            known_regs.store [iksnr], row
            reg.sequences.each do |seqnr, seq|
              srow = row.dup
              srow[1,2] = [seqnr, seq.name_base]
              known_seqs.store([iksnr, seqnr], srow)
              seq.packages.each do |pacnr, pac|
                pac.parts.each_with_index do |part, idx|
                  prow = srow.dup
                  prow.push pacnr
                  prow[@target_keys.size] = idx
                  known_pacs.store([iksnr, pacnr, idx], prow)
                end
              end
            end
          end
        end
      end
    end
    def get_latest_file(keyword='Keyword must be given!')
      if keyword.eql?('Packungen')
        index_url = ODDB::SwissmedicPlugin.get_packages_url
      elsif keyword.eql?('Präparateliste')
        index_url = ODDB::SwissmedicPlugin.get_preparations_url
      else
        raise "Unknown keyword #{keyword} in get_latest_file"
      end
      target = File.join @archive, @@today.strftime("#{keyword}-%Y.%m.%d.xlsx")
      latest_name = File.join @archive, "#{keyword}-latest.xlsx"
      cmd = "@latest_#{keyword.downcase.gsub(/[^a-zA-Z]/, '_')} = '#{latest_name}'"
      LogFile.debug "index_url #{index_url} cmd #{cmd}"
      eval cmd
      latest_name = File.join @archive, "#{keyword}-latest.xlsx"
      if File.exist?(target) and File.exists?(latest_name) and File.size(target) == File.size(latest_name)
        LogFile.debug " skip writing #{target} as it already exists and is #{File.size(target)} bytes."
        return target
      end

      latest = ''
      if(File.exist? latest_name)
        latest = File.read latest_name
      end
      download = fetch_with_http(index_url)
      if(download[-1] != ?\n)
        download << "\n"
      end
      if(!File.exist?(latest_name) or download.size != File.size(latest_name))
        File.open(target, 'w') { |fh| fh.write(download) ; fh.close}
        msg = "updated download.size is #{download.size} -> #{target} #{File.size(target)}"
        msg += "#{target} now #{File.size(target)} bytes != #{latest_name} #{File.size(latest_name)}" if File.exists?(latest_name)
        LogFile.debug(msg)
        target
      else
        @latest_packungen = latest_name if keyword.downcase.eql?('packungen')
        LogFile.debug " skip writing #{target} as #{latest_name} is #{File.size(latest_name)} bytes. Returning latest_name #{latest_name}"
        nil
      end
    end
    def initialize_export_registrations
      latest_name = File.join @archive, "Präparateliste-latest.xlsx"
      if target_name = get_latest_file('Präparateliste')
        LogFile.debug " cp #{target_name} #{latest_name}"
        FileUtils.cp target_name, latest_name, verbose: true
      end
      seq_indices = {}
      [ :seqnr, :export_flag ].each do |key|
        seq_indices.store key, PREPARATIONS_COLUMNS.index(key)
      end
      reg_indices = {}
      [ :iksnr ].each do |key|
        reg_indices.store key, PREPARATIONS_COLUMNS.index(key)
      end
      iksnr_idx = reg_indices.delete(:iksnr)
      seqnr_idx = seq_indices.delete(:seqnr)
      export_flag_idx = seq_indices.delete(:export_flag)
      workbook = Spreadsheet.open(latest_name)
      row_nr = 0
      workbook.worksheets[0].each() do |row|
        row_nr += 1
        next if row_nr <= 4
        next unless row # Happens at the end of test files from test/test_plugin/swissmedic.rb
        next unless row[export_flag_idx] # Happens at the end of test files from test/test_plugin/swissmedic.rb
          iksnr = "%05i" % cell(row, iksnr_idx).to_i
          seqnr = "%02i" % cell(row, seqnr_idx).to_i
          export = row[export_flag_idx].value
          if export =~ /E/
            data = {}
            @export_sequences[[iksnr, seqnr]] = data
            unless @export_registrations[iksnr]
              data = {}
              @export_registrations.store iksnr, data
            end
          end
      end
      LogFile.debug "initialize_export_registrations #{latest_name} contains #{@export_registrations.size} export_registrations and #{@export_sequences.size} export_sequences"
      @export_registrations
    end
    def mail_notifications
      salutations = {}
      flags = {}
      if((grp = @app.log_group(:swissmedic)) && (log = grp.latest))
        all_flags = log.change_flags
        companies = all_flags.inject({}) { |memo, (pointer, flgs)|
          if((reg = pointer.resolve(@app)) && (cmp = reg.company) \
             && (email = cmp.swissmedic_email))

                                         salutations.store(email, cmp.swissmedic_salutation)
            flags.store(pointer, flgs)
            (memo[email] ||= []).push(reg)
          end
          memo
        }
        month = log.date
        date = month.strftime("%m/%Y")
        companies.each { |email, registrations|
          report = []
          report << salutations[email]
          report << "\n"
          report << "Bei den folgenden Produkten wurden Änderungen gemäss Swissmedic #{date} vorgenommen: \n\n"
          registrations.sort_by { |reg| reg.name_base.to_s }.each { |reg|
            report << sprintf("%s: %s\n%s\n\n", reg.iksnr,
                              resolve_link(reg.pointer),
                              format_flags(flags[reg.pointer]))
          }
          mail = Log.new(month)
          mail.report = report
          mail.recipients = [email, 'swissmedic']
          mail.notify("Good Änderungen gemäss Swissmedic")
        }
      end
    end
    def pointer(row)
      cmnds = [:registration, :sequence, :package]
      path = cmnds[0, row[0,3].size].zip row
      Persistence::Pointer.new(*path)
    end
    def pointer_from_row(row)
      iksnr = "%05i" % cell(row, @target_keys.keys.index(:iksnr)).to_i
      seqnr = (str = cell(row, @target_keys.keys.index(:seqnr))) ? "%02i" % str.to_i : nil
      pacnr = "%03i" % cell(row, @target_keys.keys.index(:ikscd)).to_i
      pointer [iksnr, seqnr, pacnr].compact
    end
    def report
      atcless = @app.atcless_sequences.collect { |sequence|
        defined?(resolve_link) ? resolve_link(sequence.pointer) : "Unable to resolve_link sequence: #{sequence.to_s}"
      }.sort
      lines = [
        "ODDB::SwissmedicPlugin - Report #{@@today.strftime(DATE_FORMAT)}",
        "Total time to update: #{"%.2f" % @update_time} [m]",
      ]
      if @update_comps
        lines += [
                  "Checked compositions: #{@checked_compositions.size}",
                  "New compositions: #{@new_compositions.size}",
                  "Deleted compositions: #{@deleted_compositions.size}",
                  "Updated agents: #{@updated_agents.size}",
                  "New agents: #{@new_agents.size}",
                  "\n\nDeleted compositions were",
                  @deleted_compositions.join("\n"),
                  "\n\nUpdated agents were",
                  @updated_agents.keys.to_a.join("\n"),
                  "\n\nNew compositions were",
                  @new_compositions.keys.to_a.join("\n"),
                  "\n\nNew agents were",
                  @new_agents.keys.to_a.join("\n"),
                 ]
      else
        lines += [
        "Created Packages: #{@diff.news.size}",
        "Re-Created missing Packages: #{@recreate_missing.size}",
        "  " + @recreate_missing.collect{|x| x.join('/')}.join("\n  "),
        "Known, good Packages: #{@known_packages.size - @recreate_missing.size}",
        "Updated Packages: #{@diff.updates.size}",
        "Deleted Packages: #{@diff.package_deletions.size} (#{@diff.replacements.size} Replaced)",
        "Deactivated Sequences: #{@diff.sequence_deletions.size}",
        "Deactivated Registrations: #{@diff.registration_deletions.size}",
        "Updated new Export-Registrations: #{@export_registrations.size - @known_export_registrations}",
        "Updated existing Export-Registrations: #{@known_export_registrations}",
        "Updated new Export-Sequences: #{@export_sequences.size - @known_export_sequences}",
        "Updated existing Export-Sequences: #{@known_export_sequences}",
        "Skipped Packages: #{@skipped_packages.length}",
        "Deleted compositions: #{@deleted_compositions.size} \n  #{@deleted_compositions.join("\n  ")}",
        "Updated agents: #{@updated_agents.size}\n  #{@updated_agents.keys.to_a.join("\n  ")}",
        "Updated compositions: #{@new_compositions.size}\n  #{@new_compositions.keys.to_a.join("\n  ")}",
        "New agents: #{@new_agents.size}\n  #{@new_agents.keys.to_a.join("\n  ")}",
        "Anzahl Sequenzen mit leerem Feld Zusammensetzung: #{@empty_compositions.size}",
        "Total Sequences without ATC-Class: #{atcless.size}",
        atcless,
        "Deleted #{@deletes_packages.size} packages not in Packungen.xlsx",
        " " + @deletes_packages.collect{|x| x.join(' ')}.join("\n"),
        "Unparsed compositions #{@unparsed_compositions.size}:",
        " " + @unparsed_compositions.collect{|x| x.join(' ')}.join("\n"),
        "Updated #{@updated_expiration_dates.size} expiration_dates: \n  #{@updated_expiration_dates.keys.to_a.join("\n  ")}",
      ]
                          end
      unless @iksnr_with_wrong_data.empty?
        lines << ""
        lines << "The following errors were found when parsing Packungen.xlsx:"
        lines << @iksnr_with_wrong_data.join("\n  ")
      end
      unless @skipped_packages.empty? # no expiration date
        skipped = []
        @skipped_packages.each do |row|
          skipped << "\"#{cell(row, @target_keys.keys.index(:company))}, " \
                     "#{cell(row, @target_keys.keys.index(:name_base))}, " \
                     "#{"%05i" % cell(row, @target_keys.keys.index(:iksnr)).to_i}\""
        end
        lines << ""
        lines << "There is no Gültigkeits-datum (column 'J') of the following"
        lines << "Swissmedic Registration (Company, Product, Numbers):"
        lines << "[" + skipped.join(',') + "]"
      end
      if @empty_compositions.size > 0
        lines << ""
        lines << "Folgende Sequenzen haben keinen Eintrag in der Kolonne 'P':"
        @empty_compositions.each{ |content| lines << "  " + content if content}
      end
      lines.flatten.join("\n")
    end
    def resolve_link(ptr)
      if ptr.is_a?(Persistence::Pointer)
        if reg = @app.resolve(ptr) and reg.is_a?(ODDB::Registration)
          "#{root_url}/de/gcc/show/reg/#{reg.iksnr}"
        elsif seq = @app.resolve(ptr) and seq.is_a?(ODDB::Sequence)
          "#{root_url}/de/gcc/show/reg/#{seq.iksnr}/seq/#{seq.seqnr}"
        elsif pac = @app.resolve(ptr) and pac.is_a?(ODDB::Package)
          "#{root_url}/de/gcc/show/reg/#{pac.iksnr}/seq/#{pac.seqnr}/pack/#{pac.ikscd}"
        end
      else
        return "no pointer for nil " unless ptr
        ptr = pointer_from_row(ptr)
        "#{root_url}/de/gcc/resolve/pointer/#{ptr}"
      end
    end
    #def rows_diff(row, other, ignore = [:product_group, :atc_class, :sequence_date])
    def rows_diff(row, other,ignore = [:atc_class, :sequence_date])
      row_keys = @target_keys
      flags = super(row, other, ignore)
      if other.first.is_a?(String) \
        && (reg = @app.registration("%05i" % cell(row, row_keys.index(:iksnr)).to_i)) \
        && (package = reg.package(cell(row, row_keys.index(:ikscd))))
        flags = flags.select { |flag|
          origin = package.data_origin(flag)
          origin ||= package.sequence.data_origin(flag)
          origin ||= reg.data_origin(flag)
          origin.nil? || origin == :swissmedic
        }
      end
      flags
    end
    def source_row(row)
      hsh = { :import_date => @@today }
      @target_keys.each_with_index { |key, idx|
        value = case key
                when :registration_date, :expiry_date, :sequence_date
                   date_cell(row, @target_keys.keys.index(key))
                when :seqnr
                  sprintf "%02i", row[idx].to_i
                when :iksnr
                  sprintf "%05i", row[idx].to_i
                when :ikscd
                  sprintf "%03i", row[idx].to_i
                else
                  cell(row, idx)
                end
        hsh.store key, value
      }
      hsh
    end

    # updateds the agent (aka substance) and the component in the database
    # returns ODBA objects [component, agent]
    # similar to handle in bsv pugin
    def update_active_agent(seq, composition, parsed_substance)
      active = parsed_substance.is_active_agent
      from = 'unknown'
      args = {}
      agent = nil
      substance = update_substance(parsed_substance.name)

      dose = ODDB::Dose.new(parsed_substance.qty, parsed_substance.unit)
      if active
        ptr = if (agent = composition.active_agent(parsed_substance.name))
          from = 'active_agent'
          LogFile.debug("update_active_agent #{seq.iksnr}/#{seq.seqnr} #{parsed_substance.name}  #{active} dose #{dose} agent.pointer #{agent.pointer}")
          agent.pointer
        else
          from = "creator active_agent"
          ptr = composition.pointer + [:active_agent, parsed_substance.name]
          agent = @app.update ptr.creator, :dose => dose, :substance => substance.oid
          LogFile.debug("update_active_agent #{seq.iksnr}/#{seq.seqnr} #{parsed_substance.name}  #{active} dose #{dose} #{ptr}")
          ptr
        end
      else
        ptr = if (agent = composition.inactive_agent(parsed_substance.name))
          from = 'inactive_agent'
          LogFile.debug("update_inactive_agent #{seq.iksnr}/#{seq.seqnr} #{parsed_substance.name}  #{active} dose #{dose} agent.pointer #{agent.pointer}")
          agent.pointer
        else
          from = "creator inactive_agent"
          ptr = composition.pointer + [:inactive_agent, parsed_substance.name]
          agent = @app.update ptr.creator, :dose => dose, :substance => substance.oid
          LogFile.debug("update_inactive_agent #{seq.iksnr}/#{seq.seqnr} #{parsed_substance.name}  #{active} dose #{dose} #{ptr}")
          ptr
        end
      end
      args[:substance]        = parsed_substance.name
      args[:dose]             = dose
      args[:more_info]        = parsed_substance.more_info
      if parsed_substance.chemical_substance
        chemical_dose = ODDB::Dose.new(parsed_substance.chemical_substance.qty, parsed_substance.chemical_substance.unit)
        args[:chemical_dose]      = chemical_dose
        args[:chemical_substance] = parsed_substance.chemical_substance.name
      end
      if args.size == 0 or (args.size == 1 and args[:dose])
        @updated_agents.delete(agent)
      else
        msg = "#{from} ptr #{ptr.inspect} oid #{composition.oid} #{composition.active_agents.size} args #{args} parsed_substance #{parsed_substance}"
        trace_msg("update_active_agent update #{seq.iksnr}/#{seq.seqnr} #{msg}")
        if /creator/i.match(from)
          @new_agents["#{seq.iksnr}/#{seq.seqnr}"] = msg
        else
          @updated_agents["#{seq.iksnr}/#{seq.seqnr}" ] = msg
        end
        agent = @app.update(ptr, args, :swissmedic)
      end
      agent
    end

    def remove_active_agents_that_are_nil(composition)
                          iksnr = composition.sequence.iksnr
                          seqnr = composition.sequence.seqnr
       oids2remove = composition.active_agents.find_all { |x| x.substance == nil} if composition.active_agents
       oids2remove.each{ |substance|
                        LogFile.debug("remove_active_agents_that_are_nil #{iksnr}/#{seqnr} composition.oid #{composition.oid} #{composition.active_agents.size} active_agents. #{substance} active? #{substance.is_active_agent} substance.oid #{substance.oid} substance.pointer #{substance.pointer}")
                        @app.delete(substance.pointer) if substance.pointer
                        composition.delete_active_agent(substance.oid, substance.is_active_agent)
                        composition.odba_store
                        LogFile.debug("remove_active_agents_that_are_nil #{iksnr}/#{seqnr} composition.oid #{composition.oid} has now #{composition.active_agents.size} active_agents")
                      }
    end

    def update_company(row)
      name = cell(row, @target_keys.keys.index(:company))
      ## an ngram-similarity of 0.8 seems to be a good choice here.
      #  0.7 confuses Arovet AG with Provet AG
      args = { :name => name, :business_area => 'ba_pharma' }
      if(company = @app.company_by_name(name, 0.8))
        @app.update company.pointer, args, :swissmedic
      else
        ptr = Persistence::Pointer.new(:company).creator
        @app.update ptr, args
      end
    end

    def create_composition_in_sequence(sequence)
      component_in_db = sequence.create_composition
      sequence.fix_pointers # needed for make unit tests pass. Should not do any harm on the real database
      LogFile.debug("create_composition_in_sequence component_in_db.pointer #{component_in_db.pointer.inspect} size #{sequence.compositions.size}")
      component_in_db
    end

    def update_compositions(sequence, row, opts={:create_only => false}, composition_text, parsed_comps)
      GC.start
      comps = []
      if !@update_comps && opts[:create_only] && !sequence.active_agents.empty?
        trace_msg("update_compositions create_only")
        sequence.compositions
      elsif(namestr = cell(row, @target_keys.keys.index(:substances)))
        res = []
        iksnr = "%05i" % cell(row, @target_keys.keys.index(:iksnr)).to_i
        seqnr = "%02i" % cell(row, @target_keys.keys.index(:seqnr)).to_i
        if (sequence.seqnr != seqnr)
          LogFile.debug("update_compositions: iksnr #{iksnr} #{seqnr} mismatch between #{sequence.seqnr.inspect} and #{seqnr.inspect}")
          return
        end
        if (sequence.iksnr != iksnr)
          LogFile.debug("update_compositions: iksnr #{iksnr} #{seqnr} mismatch between #{sequence.iksnr.inspect} and #{iksnr.inspect}")
          return
        end
        trace_msg("update_compositions: iksnr #{iksnr} #{sequence.seqnr}/#{seqnr} sequence #{sequence} opts #{opts}") # if $VERBOSE
        names = namestr.split(/\s*,(?!\d|[^(]+\))\s*/u).collect { |name| capitalize(name) }.uniq
        substances = names.collect { |name| update_substance(name) }
        unless composition_text
          @empty_compositions << "iksnr #{iksnr} seqnr #{seqnr}"
          return []
        end
        if sequence.composition_text != composition_text
          msg = "iksnr #{iksnr} seqnr #{seqnr} composition_text #{sequence.composition_text} -> #{composition_text}"
          trace_msg("#{msg}")
          sequence.composition_text = composition_text
          sequence.odba_store
        end

        # First a sanity check
        sequence.compositions.each {|comp2check| remove_active_agents_that_are_nil(comp2check)}

        # now we delete all composition where the source is no longer the same as actual
        sequence.compositions.each_with_index do |comp, comp_idx|
          found = parsed_comps.find{ |x| x.source.eql?(comp.source) }
          unless found
            msg = "iksnr #{iksnr} seqnr #{seqnr} comp_idx #{comp_idx} comp.oid #{comp.oid}"
            LogFile.debug("delete_composition #{msg} comp.pointer #{comp.pointer}")
            @deleted_compositions << msg
            sequence.delete_composition(comp.oid)
            sequence.odba_store
            @app.delete comp.pointer if comp and comp.pointer
          end
        end

        # now update the sequence with all the parsed components
        parsed_comps.each_with_index do |parsed_comp, comp_idx|
          active_agents = []
          inactive_agents = []
          msg = "iksnr #{iksnr} seqnr #{seqnr} comp_idx #{comp_idx}"
          LogFile.debug("update_compositions #{msg} parsed_comp #{parsed_comp}")
          @checked_compositions << msg
          composition_in_db = nil
          parsed_comp.substances.each_with_index { |substance, parsed_idx|
            components_in_db = sequence.compositions.find_all{|value| composition_in_db = value if (value and value.source.eql?(parsed_comp.source)) }
            if components_in_db.size == 0
              composition_in_db = create_composition_in_sequence(sequence)
              LogFile.debug("#{sequence.iksnr}/#{sequence.seqnr} created composition oid #{composition_in_db.oid} source #{parsed_comp.source[0..50]}")
            elsif components_in_db.size == 1 # normal case
              composition_in_db = components_in_db.first
              LogFile.debug("#{sequence.iksnr}/#{sequence.seqnr} using oid #{composition_in_db.oid} source #{parsed_comp.source[0..50]}")
            else
              composition_in_db = components_in_db.first
              components_in_db[2..-1].each{ |composition|
                LogFile.debug("#{sequence.iksnr}/#{sequence.seqnr} deleting oid #{composition.oid} source #{parsed_comp.source[0..50]}")
                sequence.compositions.delete composition
                sequence.compositions.odba_store
              }
            end
            next if defined?(MiniTest) and not composition_in_db # for unknown reasons we we cannot create the pointer when running under MiniTest
            args = {
                    :source => parsed_comp.source,
                    :label => parsed_comp.label,
                    :corresp => parsed_comp.corresp,
                    }
            @app.update(composition_in_db.pointer, args, :swissmedic)
            updated_agent = update_active_agent(sequence, composition_in_db, substance)
            if substance.is_active_agent
              active_agents.push updated_agent
            else inactive_agents.push updated_agent
            end
            comps.push composition_in_db
            @new_compositions[ "#{iksnr}/#{seqnr} #{comp_idx}" ] = args
            composition_in_db.odba_store
            sequence.compositions.odba_store
            sequence.odba_store
          }
          if (composition_in_db == nil)
            composition_in_db = create_composition_in_sequence(sequence)
            args = {
                    :source => parsed_comp.source,
                    :label => parsed_comp.label,
                    :corresp => parsed_comp.corresp,
                    }
            @app.update(composition_in_db.pointer, args,:swissmedic)
            @new_compositions[ "#{iksnr}/#{seqnr} #{comp_idx}" ] = args
            composition_in_db.odba_store
            sequence.odba_store
          elsif not (parsed_comps.size == 1 && composition_in_db.substances.empty?)
            composition_in_db.active_agents.dup.each_with_index { |act, act_idx|
              unless active_agents.include?(act.odba_instance)
                trace_msg("update_compositions delete_active_agent #{comp_idx} act_idx #{act_idx} #{act.pointer.inspect} #{act.substance.inspect}")
                composition_in_db.delete_active_agent(act.substance)
              end if act and act.substance
            }
            composition_in_db.inactive_agents.dup.each_with_index { |act, act_idx|
              unless inactive_agents.include?(act.odba_instance)
                trace_msg("update_compositions delete_inactive_agent #{comp_idx} act_idx #{act_idx} #{act.pointer.inspect} #{act.substance.inspect}")
                composition_in_db.delete_inactive_agent(act.substance)
              end if act and act.substance
            } if composition_in_db.inactive_agents and composition_in_db.inactive_agents.is_a?(Array)
            composition_in_db.active_agents.replace active_agents.compact
            if composition_in_db.inactive_agents
              composition_in_db.inactive_agents.replace inactive_agents.compact
            else
              composition_in_db.inactive_agents = inactive_agents.compact
            end
            composition_in_db.odba_store
            sequence.odba_store
          end
        end
      end
      sequence.odba_store
      comps
    end
    def update_export_sequences export_sequences
      export_sequences.delete_if do |(iksnr, seqnr), data|
        if (reg = @app.registration(iksnr)) && (seq = reg.sequence(seqnr))
          data.update :export_flag => true
          @app.update seq.pointer, data, :swissmedic
          false
        else
          true
        end
      end
    end
    def update_export_registrations export_registrations
      export_registrations.delete_if do |iksnr, data|
        if reg = @app.registration(iksnr)
          # if all the export_flags of sequence are true,
          # then the export_flag of registration is set to true
          if reg.sequences.values.map{|seq| seq.export_flag ? true : false}.uniq == [true]
            data.update :export_flag => true, :inactive_date => nil
            @app.update reg.pointer, data, :swissmedic
            false
          else
            data.update :export_flag => false
            @app.update reg.pointer, data, :swissmedic
            true
          end
        else
          true
        end
      end
    end
    def update_galenic_form(seq, comp, row, opts={})
      # LogFile.debug " update_galenic_form #{seq.seqnr} gf #{comp.galenic_form} fix ? #{opts[:fix_galenic_form].inspect}"
      opts = {:create_only => false}.merge opts
      return if comp.galenic_form && !opts[:fix_galenic_form]
      if((german = seq.name_descr) && !german.empty?)
        _update_galenic_form(comp, :de, german)
      elsif(match = GALFORM_P.match(comp.source.to_s))
        _update_galenic_form(comp, :lt, match[:galform].strip)
      else
        LogFile.debug " update_galenic_form don't know how to update the galenic form. #{seq.name_descr.inspect} or source #{comp.source.to_s}"
      end
    end
    def _update_galenic_form(comp, lang, name)
      # remove counts and doses from the name - this is assuming name looks
      # (in the worst case) something like this: "10 Filmtabletten"
      # or: "Infusionsemulsion, 1875ml"
      parts = name.split(/\s*,(?!\d|[^(]+\))\s*/u)
      unless name = parts.first[/[^\d]{3,}/]
       name = parts.last[/[^\d]{3,}/]
      end
      name.strip! if name

      unless(gf = @app.galenic_form(name))
        ptr = Persistence::Pointer.new([:galenic_group, 1],
                                       [:galenic_form]).creator

        LogFile.debug " _update_galenic_form ptr #{ptr} name #{name}"
        @app.update(ptr, {lang => name}, :swissmedic)
      end
      # LogFile.debug " _update_galenic_form comp.pointer name #{name} #{comp.inspect[0..250]}"
      @app.update(comp.pointer, { :galenic_form => name }, :swissmedic)
    end
    def update_indication(name)
      name = name.to_s.strip
      unless name.empty?
        if indication = @app.indication_by_text(name)
          indication
        else
          pointer = Persistence::Pointer.new(:indication)
          LogFile.debug " update_indication pointer #{pointer} name #{name}"
          @app.update(pointer.creator, {:de => name}, :swissmedic)
        end
      end
    end
    def update_package(reg, seq, row, replacements={},
                       opts={:create_only => false})
      iksnr = "%05i" % cell(row, @target_keys.keys.index(:iksnr)).to_i
      seqnr ="%02i" % cell(row, @target_keys.keys.index(:seqnr)).to_i
      if (seq.seqnr != seqnr)
        LogFile.debug("iksnr #{iksnr} #{seqnr} mismatch between #{seq.seqnr.inspect}/#{seqnr.inspect}")
        return
      end
      if (seq.iksnr != iksnr || reg.iksnr != iksnr)
        LogFile.debug("iksnr #{iksnr} #{seqnr} mismatch between #{reg.iksnr.inspect}/#{seq.iksnr.inspect}#{iksnr.inspect}")
        return
      end
      ikscd = sprintf('%03i', cell(row, @target_keys.keys.index(:ikscd)).to_i)
      unless seq.pointer
        LogFile.debug("problem '#{row[@target_keys.keys.index(:iksnr)]}' ikscd #{ikscd} sequence with pointer")
        return
      end
      # LogFile.debug "#{iksnr}/#{seqnr}/#{ikscd} #{replacements.size} replacements"
      pidx = cell(row, row.size).to_i
      if(ikscd.to_i > 0)
        args = {
          :ikscat            => cell(row, @target_keys.keys.index(:ikscat)),
          :swissmedic_source => source_row(row),
        }
        package = nil
        ptr = if(package = reg.package(ikscd))
                return package if opts[:create_only] && pidx == 0
                package.pointer
              else
                args.store :refdata_override, true
                (seq.pointer + [:package, ikscd]).creator
              end
        if((pacnr = replacements[row]) && (old = reg.package(pacnr)))
          args.update(:pharmacode => old.pharmacode,
                      :ancestors  => (old.ancestors || []).push(pacnr))
        end
        if package.nil? && ptr.is_a?(Persistence::Pointer)
            package = @app.update(ptr, args, :swissmedic)
        elsif package.nil?
            package = seq.create_package(ikscd)
            LogFile.debug "create #{iksnr}/#{seqnr}/#{ikscd} ptr #{ptr} package #{package} in #{seq.pointer} #{seq.packages.keys}"
            seq.packages[ikscd] = package
            seq.fix_pointers
            seq.packages.odba_store
            seq.odba_store
        end
        @app.update(ptr, args, :swissmedic)
        if !package.parts or package.parts.empty? or !package.parts[pidx]
          part = package.create_part
          package.parts[pidx] = part
          package.parts.odba_store
          package.odba_store
          LogFile.debug "create part.oid #{part.oid} part.pointer #{part.pointer}"
        else
          part = package.parts[pidx]
        end
        part.size =  [cell(row, @target_keys.keys.index(:size)), cell(row, @target_keys.keys.index(:unit))].compact.join(' ')
        if package.sequence and package.sequence.seqnr != seq.seqnr
          LogFile.debug "iksnr '#{row[@target_keys.keys.index(:iksnr)]}' ikscd #{ikscd} should correct seqnr #{package.sequence.seqnr} -> #{seq.seqnr}?"
        end
        if(comform = @app.commercial_form_by_name(cell(row, @target_keys.keys.index(:unit))))
          args.store :commercial_form, comform.pointer
        end
        if !part.composition \
          && (comp = seq.compositions[pidx] || seq.compositions.last)
          args.store :composition, comp.pointer
        end
        unless seq.packages[ikscd]
          LogFile.debug "fix seq.packages #{iksnr}/#{seqnr}/#{ikscd} expiration_date #{args[:expiration_date]}"
          seq.packages.store(ikscd, package)
          seq.packages.odba_store
          seq.odba_store
        end
        part.odba_store
      end
    end
    def update_registration(row, opts = {})
      GC.start
      first_day = Date.new(@@today.year, @@today.month, 1)
      opts = {:date => first_day, :create_only => false}.update(opts)
      opts[:date] ||= first_day
      group = cell(row, @target_keys.keys.index(:production_science))
      unless (group.eql?('Tierarzneimittel'))
        iksnr = "%05i" % cell(row, @target_keys.keys.index(:iksnr)).to_i
        science = cell(row, @target_keys.keys.index(:production_science))
        ptr = if(registration = @app.registration(iksnr))
                return registration if opts[:create_only]
                registration.pointer
              else
                Persistence::Pointer.new([:registration, iksnr]).creator
              end
        if row[@target_keys.keys.index(:expiry_date)] && row[@target_keys.keys.index(:expiry_date)].value && SwissmedicDiff::REGEXP_UNLIMITED.match(row[@target_keys.keys.index(:expiry_date)].value.to_s)
          expiration = nil
        else
          expiration = date_cell(row, @target_keys.keys.index(:expiry_date))
          if expiration.nil?
            @skipped_packages << row
            return nil
          end
        end
        reg_date = date_cell(row, @target_keys.keys.index(:registration_date))
        vaccine = if science =~ /Blutprodukte/ or science =~ /Impfstoffe/
                    true
                  else
                    nil
                  end
        args = {
          :ith_swissmedic      => cell(row, @target_keys.keys.index(:index_therapeuticus)),
          :production_science  => science,
          :vaccine             => vaccine,
          :registration_date   => reg_date,
          :expiration_date     => expiration,
          :renewal_flag        => false,
          :renewal_flag_swissmedic => false,
          :inactive_date       => nil,
          :export_flag         => nil,
        }
        if expiration && (expiration < opts[:date])
          args.store :renewal_flag, true
          args.store :renewal_flag_swissmedic, true
        end
        case science
        when "Anthroposophika"
          args.store :complementary_type, 'anthroposophy'
        when "Homöopathika"
          args.store :complementary_type, 'homeopathy'
        when "Phytotherapeutika"
          args.store :complementary_type, 'phytotherapy'
        end
        if(company = update_company(row))
          args.store :company, company.pointer
        end
        if(indication = update_indication(cell(row, @target_keys.keys.index(:indication_registration))))
          args.store :indication, indication.pointer
        end

        LogFile.debug("update_registration #{iksnr} args #{args}")
        reg = @app.update ptr, args, :swissmedic
        unless @app.registrations[iksnr]
          LogFile.debug "update_registration fix registration #{iksnr}"
          @app.registrations.store(iksnr, reg)
          @app.registrations.odba_store
        end
        reg
      end
    rescue SystemStackError => err
      puts "Stack-Error when importing: #{source_row(row).pretty_inspect}"
      puts err.backtrace[-100..-1]
      nil
    end
    def update_excipiens_in_composition(seq, parsed_compositions)
      unless seq.is_a?(ODDB::Sequence)
        trace_msg("skip update_excipiens_in_composition as #{seq.class} is not a ODDB::Sequence")
        return
      end
      unless seq.iksnr
        trace_msg("skip update_excipiens_in_composition seq.iknsr is false")
        trace_msg("#{seq.inspect}")
        return
      end
      iksnr = "%05i" % seq.iksnr.to_i
      seq.compositions.each_with_index {
        |db_composition, idx|
          parsed_composition = nil
          parsed_composition = parsed_compositions&.find {|parse_comp| parse_comp.source.eql?(db_composition.source)}
          if parsed_composition&.excipiens
            # excipiens = ActiveAgent.new(parsed_composition.excipiens.name, false)
            # substance = update_substance(parsed_composition.excipiens.name)
            excipiens = update_substance(parsed_composition.excipiens.name)
            LogFile.debug("#{iksnr} #{seq.seqnr} excipiens #{excipiens.class} excipiens.oid #{excipiens ? excipiens.oid : 'nil'} for #{parsed_composition.excipiens.name}")
            if parsed_composition.excipiens.qty or parsed_composition.excipiens.unit
              # TODO::howto handle this ?excipiens.dose = Dose.new(parsed_composition.excipiens.qty, parsed_composition.excipiens.unit)
            end
            excipiens.more_info = parsed_composition.excipiens.more_info
            db_composition.add_excipiens(excipiens)
            LogFile.debug("#{iksnr} #{seq.seqnr} update_excipiens_in_composition idx #{idx}: excipiens #{excipiens.inspect} from #{parsed_composition.excipiens}")
            db_composition.odba_store
            seq.odba_store
          end
      }
    end
    def update_all_sequence_info(row, reg, seq, opts=nil, replacements=nil)
      composition_text   = cell(row, @target_keys.keys.index(:composition))
      active_agents_text = cell(row, @target_keys.keys.index(:substances))
      begin
        parsed_comps = ParseUtil.parse_compositions(composition_text, active_agents_text)
        comps = update_compositions(seq, row, opts, composition_text, parsed_comps)
        comps.each_with_index do |comp, idx|
          update_galenic_form(seq, comp, opts)
        end if comps
      rescue => error
        @unparsed_compositions << "#{seq.iksnr}: #{composition_text}"
      end
      update_package(reg, seq, row, replacements, opts) if replacements
      update_excipiens_in_composition(seq, parsed_comps)
    end

   def update_registrations(rows, replacements, opts=nil)
      opts ||= { :create_only => @latest_packungen ? !File.exist?(@latest_packungen) : false,
               :date        => @@today, }
      nr_rows = rows.size
      rows.each_with_index do |row, idx|
        iksnr = "%05i" % cell(row, @target_keys.keys.index(:iksnr)).to_i
        seqnr = "%02i" % cell(row, @target_keys.keys.index(:seqnr)).to_i
        next if iksnr.eql?('00000')
        to_consider =  mustcheck(iksnr, opts)
        next unless row
        next unless mustcheck(iksnr, opts)
        LogFile.debug("update #{idx}/#{nr_rows} iksnr #{iksnr} seqnr #{seqnr} #{to_consider} opts #{opts}. #{replacements.size} replacements")
        already_disabled = GC.disable # to prevent method `method_missing' called on terminated object
        reg = update_registration(row, opts) if row
        LogFile.debug("update #{idx}/#{nr_rows} iksnr #{iksnr} seqnr #{seqnr} reg #{reg} from app #{@app.registration(iksnr)}")
        reg ||= @app.registration(iksnr)
        seq = update_sequence(reg, row, opts) if reg
        update_all_sequence_info(row, reg, seq, opts, replacements) if seq
        if !reg && !reg.sequences[seqnr]
          LogFile.debug "update_registration fix sequence #{iksnr}/#{seqnr}"
          reg.sequences.store(seqnr, seq)
          reg.sequences.odba_store
          reg.odba_store
        end
        GC.enable unless already_disabled
      end
      true
    end
    def update_sequence(registration, row, opts={:create_only => false})
      # remove sequence '00'/package '000' which might have been created when importing via AipsDownload.xml
      seqnr = "%02i" % cell(row, @target_keys.keys.index(:seqnr)).to_i
      if registration.sequence('00')
        ptr = registration.sequence('00').pointer
        if ptr
          trace_msg("delete sequence('00') seqnr #{seqnr} ptr #{ptr}")
          registration.sequence('00').delete_package('000')
          registration.delete_sequence('00')
        end
      end
      ptr = if(sequence = registration.sequence(seqnr))
              return sequence if opts[:create_only]
              sequence.pointer
            else
              (registration.pointer + [:sequence, seqnr]).creator
            end
      ## some names use commas for dosage
      unless cell(row, @target_keys.keys.index(:name_base))
        msg = "Empty column C for #{cell(row, @target_keys.keys.index(:iksnr))} #{cell(row, @target_keys.keys.index(:seqnr))}"
        trace_msg("#{__FILE__}: #{__LINE__}: #{msg}")
        @iksnr_with_wrong_data << msg
        return nil
      end
      parts = cell(row, @target_keys.keys.index(:name_base)).split(/\s*,(?!\d|[^(]+\))\s*/u)
      base = parts.shift
      ## some names have dosage data before the galenic form
      # ex. 'Ondansetron-Teva, 4mg, Filmtabletten'
      if /[\d\s][m]?[glL]\b/.match(parts.first)
        base << ', ' << parts.shift
      end
      descr = unless parts.empty?
                parts.join(', ')
              else
                nil
              end
      if ctext = cell(row, @target_keys.keys.index(:composition))
        ctext = ctext.gsub(/\r\n?/u, "\n")
      end

      seq_date = date_cell(row, @target_keys.keys.index(:sequence_date))
      atc_class = cell(row, @target_keys.keys.index(:atc_class))
      args = {
        :composition_text => ctext,
        :name_base        => base,
        :name_descr       => descr,
        :dose             => nil,
        :atc_class        => atc_class,
        :sequence_date    => seq_date,
        :export_flag      => nil,
      }
      sequence = registration.sequence(seqnr)
      if(sequence.nil? || sequence.atc_class.nil?)
        if(!registration.atc_classes.nil? and
           atc = registration.atc_classes.first)
          args.store :atc_class, atc.code
        elsif((key = cell(row, @target_keys.keys.index(:substances))) && !key.include?(?,) \
             && (atc = @app.unique_atc_class(key)))
          args.store :atc_class, atc.code
        elsif(code = cell(row, @target_keys.keys.index(:atc_class)))
          args.store :atc_class, code
        end
      end
      if(indication = update_indication(cell(row, @target_keys.keys.index(:indication_sequence))))
        args.store :indication, indication.pointer
      end
      res = @app.update ptr, args, :swissmedic
      trace_msg "#{__FILE__}: #{__LINE__}: res #{res} == #{sequence}? #{registration.iksnr} seqnr #{sequence ? sequence.seqnr : 'nil'} args #{args}"
      res
    end
    def update_substance(name)
      name.strip!
      unless name.empty?
        substance = @app.substance(name)
        if(substance.nil?)
          substance = @app.update(Persistence::Pointer.new(:substance).creator,
                                  {:lt => name}, :swissmedic)
        end
        substance
      end
    end
    def sanity_check_deletions(diff)
      table = diff.registration_deletions.inject({}) { |memo, (iksnr,_)|
        memo.store(iksnr, true)
        memo
      }
      ## if we deactivate a registration, we need to keep its sequences
      #  so we have a name to report.
      _sanity_check_deletions(diff.sequence_deletions, table)
      ## we could delete remaining packages, but for now we'll keep them
      #  as the last active state.
      _sanity_check_deletions(diff.package_deletions, table)
    end
    def _sanity_check_deletions(deletions, table)
      deletions.compact.delete_if {|row| table[cell(row,@target_keys.keys.index(:iksnr))] || cell(row, row.size).to_i > 0 }
    end
    def _sort_by(sort, iksnr, flags)
      case sort
      when :name
        [name(@diff, iksnr), iksnr]
      when :registration
        iksnr
      else
        weight = if(flags.include? :new)
                   0
                 elsif(flags.include? :delete)
                   1
                 else
                   2
                 end
        [weight, iksnr]
      end
    end
    def count_active_agents_with_nil_is_active
      res = @app.active_sequences.collect{|s| s.compositions.collect{|c| c.active_agents.find_all {|x| x.is_active_agent == nil} }}
      res.flatten.size
    end
    def cleanup_active_agents_with_nil(sequences = @app.active_sequences)
      @@corrected = []
      nr_seq = 0
      sequences.each do |sequence|
        nr_seq += 1
        LogFile.debug "at #{sequence.iksnr}/#{sequence.seqnr}: #{nr_seq}" if nr_seq % 300 == 1
        sequence.compositions.each do |composition|

          # Check for error in active_agents
          wrong_active_agents = composition.active_agents.find_all do |x|
            x.is_active_agent == nil ||  x.is_active_agent == false || x.is_a?(InactiveAgent)
          end
          if wrong_active_agents.size > 0
            LogFile.debug "#{sequence.iksnr}/#{sequence.seqnr}:  #{composition.pointer}: Must correct is #{wrong_active_agents.size} agents. Has  #{composition.active_agents.size} active_agents"
            wrong_active_agents.each do |wrong_agent|
              @@corrected << wrong_agent.pointer
              LogFile.debug "Deleting wrong_active_agent odba_store #{wrong_agent.pointer} is #{wrong_agent.oid} #{wrong_agent.to_s}"
              composition.delete_active_agent(wrong_agent)
              wrong_agent.odba_delete
              composition.odba_store
            end
            LogFile.debug "#{sequence.iksnr}/#{sequence.seqnr}: #{composition.pointer}: has now #{composition.active_agents.size} active_agents"
          end

          # Check for error in inactive_agents
          wrong_inactive_agents = composition.inactive_agents.find_all do |x|
            x.is_active_agent == nil ||  x.is_active_agent == true || x.is_a?(ActiveAgent)
          end
          if wrong_inactive_agents.size > 0
            LogFile.debug "#{sequence.iksnr}/#{sequence.seqnr}:  #{composition.pointer}: Must correct is #{wrong_inactive_agents.size} agents. Has  #{composition.inactive_agents.size} inactive_agents"
            wrong_inactive_agents.each do |wrong_agent|
              @@corrected << wrong_agent.pointer
              LogFile.debug "Deleting wrong_inactive_agent odba_store #{wrong_agent.pointer} is #{wrong_agent.oid} #{wrong_agent.to_s}"
              composition.delete_inactive_agent(wrong_agent)
              wrong_agent.odba_delete
              composition.odba_store
            end
            LogFile.debug "#{sequence.iksnr}/#{sequence.seqnr}: #{composition.pointer}: has now #{composition.inactive_agents.size} inactive_agents"
          end
        end
      end
      LogFile.debug "Corrected #{@@corrected.size} of #{@app.active_sequences.size} active_sequences. Deleted active_agents\n#{@@corrected.join("\n")}"
      nr_nil = count_active_agents_with_nil_is_active
      unless nr_nil == 0
        LogFile.debug "Should have 0 and not #{count_active_agents_with_nil_is_active} active_agents with nil is_active_agent"
      else
        LogFile.debug "Everything seems to be okay count_active_agents_with_nil_is_active is 0"
      end
      @@corrected
    end
  end
end

