#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'
require 'mechanize'
require 'ostruct'
require 'plugin/plugin'
require 'pp'
require 'util/persistence'
require 'util/today'
require 'swissmedic-diff'
require 'util/logfile'

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
    attr_reader :checked_compositions, :updated_agents, :new_agents
    PREPARATIONS_COLUMNS = [ :iksnr, :seqnr, :name_base, :company, :export_flag,
      :index_therapeuticus, :atc_class, :production_science,
      :sequence_ikscat, :ikscat, :registration_date, :sequence_date,
      :expiry_date, :substances, :composition, :indication_registration, :indication_sequence ]
    include SwissmedicDiff::Diff
    GALFORM_P = %r{excipiens\s+(ad|pro)\s+(?<galform>((?!\bpro\b)[^.])+)}u
    SCALE_P = %r{pro\s+(?<scale>(?<qty>[\d.,]+)\s*(?<unit>[kcmuµn]?[glh]))}u
private
    def date_cell(row, idx)
      return nil unless row[idx]
      row_value = row[idx]
      return nil unless row_value.value
      return row_value.value.to_date if row_value.is_a?(RubyXL::Cell)
      row_value
    end
public
    def initialize(app=nil, archive=ARCHIVE_PATH)
      super app
      @index_url = 'https://www.swissmedic.ch/arzneimittel/00156/00221/00222/00230/index.html?lang=de'
      trace_msg("SwissmedicPlugin @index_url #{@index_url}")
      @archive = File.join archive, 'xls'
      FileUtils.mkdir_p @archive
      init_stats
    end

    def init_stats
      @known_export_registrations = 0
      @known_export_sequences = 0
      @checked_compositions = []
      @deleted_compositions = []
      @new_compositions = {}
      @updated_agents = {}
      @new_agents = {}
      @export_registrations = {}
      @export_sequences = {}
      @skipped_packages = []
      @iksnr_with_wrong_data = []
      @active_registrations_praeparateliste = {}
      @update_time = 0 # minute
      @target_keys ||= {}
      @empty_compositions = []
    end

    # traces many details of changes. Use it for debugging purposes
    def trace_msg(msg)
      $stdout.puts Time.now.to_s + ': ' + msg if false
    end

    def debug_msg(msg)
      if defined?(MiniTest) then $stdout.puts Time.now.to_s + ': ' + msg; $stdout.flush; return end
      if not defined?(@checkLog) or not @checkLog
        name = LogFile.filename('oddb/debug/', Time.now)
        FileUtils.makedirs(File.dirname(name))
        @checkLog = File.open(name, 'a+')
        $stdout.puts "Opened #{name}"
      end
      @checkLog.puts("#{Time.now}: #{msg}")
      @checkLog.flush
    end

    def mustcheck(iksnr, opts = {})
      res = true
      unless opts[:update_compositions]
        # debug_msg "#{__FILE__}:#{__LINE__} iksnr #{iksnr} mustcheck #{res} opts #{opts}"
        return res
      end
      if opts[:iksnrs] == nil or opts[:iksnrs].size == 0 or opts[:iksnrs].index(iksnr)
        # debug_msg "#{__FILE__}:#{__LINE__} iksnr #{iksnr} mustcheck #{res} opts #{opts}"
        return res
      end
      # debug_msg "#{__FILE__}:#{__LINE__} iksnr #{iksnr} mustcheck false opts #{opts}"
      return false
    end

    def set_target_keys(workbook)
      @target_keys = get_column_indices(workbook).keys
    end

    def update(opts = {}, agent=Mechanize.new, target=get_latest_file(agent))
      require 'plugin/parslet_compositions' # We delay the inclusion to avoid defining a module wide method substance in Parslet
      init_stats
      @update_comps = (opts and opts[:update_compositions])
      msg = "#{__FILE__}:#{__LINE__} opts #{opts} @update_comps #{@update_comps} update target #{target.inspect}"
      msg += " #{File.size(target)} bytes. " if target
      msg += "Latest #{@latest_packungen} #{File.size(@latest_packungen)} bytes" if @latest_packungen and File.exists?(@latest_packungen)
      debug_msg(msg)
      start_time = Time.new
      if @update_comps
        opts[:fix_galenic_form] = true
        row_nr = 4
        last_checked = nil
        file2open = target if target and File.exists?(target)
        file2open ||= @latest_packungen if @latest_packungen and File.exists?(@latest_packungen)
        unless file2open and File.exists?(file2open)
          debug_msg "#{__FILE__}:#{__LINE__} unable to open #{file2open}. Checked #{target} and #{@latest_packungen}"
        else
          debug_msg("file2open #{file2open} checked #{target} and #{@latest_packungen}")
          @target_keys = get_column_indices(Spreadsheet.open(file2open)).keys
          Spreadsheet.open(file2open).worksheet(0).each() do
            |row|
            row_nr += 1
            next if row_nr <= 4
            break unless row
            next if (cell(row, @target_keys.index(:production_science)) == 'Tierarzneimittel')
            iksnr =  cell(row, @target_keys.index(:iksnr)).to_i
            seqnr =  cell(row, @target_keys.index(:seqnr)).to_i
            to_be_checked = [iksnr, seqnr]
            next if last_checked == to_be_checked
            last_checked = to_be_checked
            to_consider = mustcheck(iksnr, opts)
            # next if not iksnr == 488 and not iksnr == 46489
            # next unless to_consider
            # debug_msg"#{__FILE__}:#{__LINE__} update #{row_nr} iksnr #{iksnr} seqnr #{seqnr} #{to_consider}"
            already_disabled = GC.disable # to prevent method `method_missing' called on terminated object
            reg = @app.registration("%05i" %iksnr)
            seq = reg.sequence("%02i" %seqnr) if reg
            update_all_sequence_info(row, reg, seq) if reg and seq
            GC.enable unless already_disabled
            trace_msg"#{__FILE__}:#{__LINE__} update finished iksnr #{iksnr} seqnr #{seqnr} check #{reg == nil} #{seq == nil}"
          end
          @update_time = ((Time.now - start_time) / 60.0).to_i
        end
      elsif(target)
        debug_msg(msg)
        msg =  "#{__FILE__}: #{__LINE__} Comparing #{target} "
        msg +=  File.exists?(target) ? "#{File.size(target)} bytes " : " absent" if target
        msg += " with #{@latest_packungen} "
        msg +=  File.exists?(@latest_packungen) ? "#{File.size(@latest_packungen)} bytes " : " absent" if @latest_packungen
        debug_msg msg
        start_time = Time.new
        initialize_export_registrations agent
        @target_keys = get_column_indices(Spreadsheet.open(target)).keys
        result = diff target, @latest_packungen, [:atc_class, :sequence_date]
        # check diff from stored data about date-fields of Registration
        check_date! unless @update_comps
        if @latest_packungen and File.exists?(@latest_packungen)
          debug_msg "#{__FILE__}:#{__LINE__} Compared #{target} #{File.size(target)} bytes with #{@latest_packungen} #{File.size(@latest_packungen)} bytes"
        else
          debug_msg "#{__FILE__}:#{__LINE__} No latest_packungen #{@latest_packungen} exists"
        end
        debug_msg "#{__FILE__}:#{__LINE__} @update_comps #{@update_comps}. Found #{@diff.news.size} news, #{@diff.updates.size} updates, #{@diff.replacements.size} replacements and #{@diff.package_deletions.size} package_deletions"
        debug_msg "#{__FILE__}:#{__LINE__} changes: #{@diff.changes.inspect}"
        debug_msg "#{__FILE__}:#{__LINE__} first news: #{@diff.news.first.inspect[0..250]}"
        update_registrations @diff.news + @diff.updates, @diff.replacements, opts
        set_all_export_flag_false
        update_export_sequences @export_sequences
        update_export_registrations @export_registrations
        sanity_check_deletions(@diff)
        delete(@diff.package_deletions, true)
        # check the case in which there is a sequence or registration in Praeparateliste.xlsx
        # but there is NO sequence or registration in Packungen.xlsx
        #recheck_deletions @diff.sequence_deletions # Do not consider Preaparateliste_mit_WS.xlsx when setting the "deaktiviert am" date.
        #recheck_deletions @diff.registration_deletions # Do not consider Preaparateliste_mit_WS.xlsx when setting the "deaktiviert am" date.
        deactivate @diff.sequence_deletions
        deactivate @diff.registration_deletions
        end_time = Time.now - start_time
        @update_time = (end_time / 60.0).to_i
        if File.exists?(target) and File.exists?(@latest_packungen) and FileUtils.compare_file(target, @latest_packungen)
          debug_msg "#{__FILE__}: #{__LINE__} rm_f #{target} after #{@update_time} minutes"
          FileUtils.rm_f(target, :verbose => true)
        else
          debug_msg "#{__FILE__}: #{__LINE__} cp #{target} #{@latest_packungen} after #{@update_time} minutes"
          FileUtils.cp target, @latest_packungen, :verbose => true
        end
        @change_flags = @diff.changes.inject({}) { |memo, (iksnr, flags)|
          memo.store Persistence::Pointer.new([:registration, iksnr]), flags
          memo
        }
      else
        debug_msg "#{__FILE__}:#{__LINE__} update return false as target is #{target.inspect}"
        false
      end
      debug_msg(msg = "#{__FILE__}:#{__LINE__} done. @update_comps was #{@update_comps} with #{@diff ? "#{@diff.changes.size} changes" : 'no change information'}")
      @update_comps ? true : @diff
    end
    # check diff from overwritten stored-objects by admin
    # about data-fields
    def check_date!
      @diff.newest_rows.values.each do |obj|
        obj.values.each do |row|
          # File used is row.worksheet.workbook.root.filepath
          iksnr = row[@target_keys.index(:iksnr)]
          if reg = @app.registration(iksnr.to_s)
            {
              :registration_date => @target_keys.index(:registration_date),
              :expiration_date   =>   @target_keys.index(:expiry_date)
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
    def set_all_export_flag_false
      @app.each_registration do |reg|
        # registration export_flag
        @known_export_registrations += 1 if reg.export_flag
        @app.update reg.pointer, {:export_flag => false}, :admin
        # sequence export_flag
        reg.sequences.values.each do |seq|
          next unless seq.is_a? ODDB::Sequence
          @known_export_sequences += 1 if seq.export_flag
          @app.update seq.pointer, {:export_flag => false}, :admin
        end
      end
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
        iksnr = row[@target_keys.index(:iksnr)]
        seqnr = "%02i" % cell(row, @target_keys.index(:seqnr)).to_i
        debug_msg "#{__FILE__}: #{__LINE__}: deactivate iksnr '#{iksnr}' seqnr #{seqnr} pack #{@target_keys.index(:ikscd)}"
        if row.length == 1 # only in the case of registration_deletions
          @app.update pointer(row), {:inactive_date => @@today, :renewal_flag => nil, :renewal_flag_swissmedic => nil}, :swissmedic
        else # the case of sequence_deletions
          @app.update pointer(row), {:inactive_date => @@today}, :swissmedic
        end
      }
    end
    def delete(deletions, is_package_deletion = false)
      debug_msg "#{__FILE__}:#{__LINE__} delete #{deletions.size} items"
      deletions.each {
        |row|
        iksnr  = row[@target_keys.index(:iksnr)]
        seqnr  = "%02i" % cell(row, @target_keys.index(:seqnr)).to_i
        packnr = row[@target_keys.index(:ikscd)]
        debug_msg "#{__FILE__}: #{__LINE__}: delete iksnr #{iksnr.inspect} seqnr #{seqnr} pack #{packnr.inspect}"
        ptr = pointer(row)
        next unless ptr
        unless is_package_deletion
          @app.delete ptr
        else
          object = @app.resolve(ptr)
          debug_msg "#{__FILE__}:#{__LINE__} delete object #{object.inspect}"
          next unless object
          @app.delete ptr if object.is_a?(ODDB::Package) and
            @app.registration(iksnr).sequence(seqnr) and
            @app.registration(iksnr).sequence(seqnr).packages.keys.index(packnr)
        end
      }
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
                date_cell(row, @target_keys.index(flag)).strftime('%d.%m.%Y')
      else
        row = diff.newest_rows[iksnr].sort.first.last
        sprintf "%s (%s)", txt, cell(row, @target_keys.index(flag))
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
        @app.registrations.each { |iksnr, reg|
          row = [ iksnr, nil, nil, reg.company_name,
                  reg.ith_swissmedic || reg.index_therapeuticus,
                  reg.production_science, reg.registration_date,
                  reg.expiration_date ]
          unless reg.inactive? || reg.vaccine
            known_regs.store [iksnr], row
            reg.sequences.each { |seqnr, seq|
              srow = row.dup
              srow[1,2] = [seqnr, seq.name_base]
              known_seqs.store([iksnr, seqnr], srow)
              seq.packages.each { |pacnr, pac|
                pac.parts.each_with_index { |part, idx|
                  prow = srow.dup
                  prow.push pacnr
                  prow[@target_keys.size] = idx
                  known_pacs.store([iksnr, pacnr, idx], prow)
                }
              }
            }
          end
        }
      end
    end
    def get_latest_file(agent, keyword='Packungen', extension = '.xlsx')
      target = File.join @archive, @@today.strftime("#{keyword}-%Y.%m.%d.xlsx")
      latest_name = File.join @archive, "#{keyword}-latest"+extension
      cmd = "@latest_#{keyword.downcase.gsub(/[^a-zA-Z]/, '_')} = '#{latest_name}'"
      debug_msg "#{__FILE__}: #{__LINE__} cmd #{cmd}"
      eval cmd
      latest_name = File.join @archive, "#{keyword}-latest"+extension
      if File.exist?(target) and File.exists?(latest_name) and File.size(target) == File.size(latest_name)
        debug_msg "#{__FILE__}:#{__LINE__} skip writing #{target} as it already exists and is #{File.size(target)} bytes."
        return target
      end
      page = agent.get @index_url
      links = page.links.select do |link|
        ptrn = keyword.gsub /[^A-Za-z]/u, '.'
        /#{ptrn}/iu.match link.attributes['title']
      end
      link = links.first or raise "could not identify url to #{keyword}.xlsx"
      file = agent.get(link.href)
      download = file.body

      if extension == '.xlsx'
        latest_xls = latest_name.sub('.xlsx', '.xls')
        if File.exist?(latest_xls)
          latest_name = latest_xls
        end
      end
      latest = ''
      if(File.exist? latest_name)
        latest = File.read latest_name
      end
      if(download[-1] != ?\n)
        download << "\n"
      end
      if(!File.exist?(latest_name) or download.size != File.size(latest_name))
        File.open(target, 'w') { |fh| fh.puts(download) }
        msg = "#{__FILE__}:#{__LINE__} updated download.size is #{download.size} -> #{target} #{File.size(target)}"
        msg += "#{target} now #{File.size(target)} bytes != #{latest_name} #{File.size(latest_name)}" if File.exists?(latest_name)
        debug_msg(msg)
        target
      else
        @latest_packungen = latest_name if keyword.downcase.eql?('packungen')
        debug_msg "#{__FILE__}:#{__LINE__} skip writing #{target} as #{latest_name} is #{File.size(latest_name)} bytes. Returning latest_name #{latest_name}"
        nil
      end
    end
    def initialize_export_registrations(agent)
      latest_name = File.join @archive, "Präparateliste-latest.xlsx"
      if target_name = get_latest_file(agent, 'Präparateliste')
        debug_msg "#{__FILE__}: #{__LINE__} cp #{target_name} #{latest_name}"
        FileUtils.cp target_name, latest_name, :verbose => true
      end
      seq_indices = {}
      [ :seqnr, :export_flag ].each do |key|
        seq_indices.store key, PREPARATIONS_COLUMNS.index(key)
      end
      reg_indices = {}
      [ :iksnr ].each do |key|
        reg_indices.store key, PREPARATIONS_COLUMNS.index(key)
      end
      Spreadsheet.open(target_name) do |workbook|
        iksnr_idx = reg_indices.delete(:iksnr)
        seqnr_idx = seq_indices.delete(:seqnr)
        export_flag_idx = seq_indices.delete(:export_flag)
        workbook.worksheet(0).each(rows_to_skip(workbook)) do |row|
          iksnr = "%05i" % row[iksnr_idx].to_i
          seqnr = row[seqnr_idx]
          export = row[export_flag_idx]
          if export =~ /E/
            data = {}
            @export_sequences[[iksnr, seqnr]] = data
            unless @export_registrations[iksnr]
              data = {}
              @export_registrations.store iksnr, data
            end
          end
        end
      end
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
      iksnr = "%05i" % cell(row, @target_keys.index(:iksnr)).to_i
      seqnr = (str = cell(row, @target_keys.index(:seqnr))) ? "%02i" % str.to_i : nil
      pacnr = "%03i" % cell(row, @target_keys.index(:ikscd)).to_i
      pointer [iksnr, seqnr, pacnr].compact
    end
    def report
      atcless = @app.atcless_sequences.collect { |sequence|
        defined?(resolve_link) ? resolve_link(sequence.pointer) : "Unable to resolve_link sequence: #{sequence.to_s}"
      }.sort
      lines = [
        "ODDB::SwissmedicPlugin - Report #{@@today.strftime('%d.%m.%Y')}",
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
        "Updated Packages: #{@diff.updates.size}",
        "Deleted Packages: #{@diff.package_deletions.size} (#{@diff.replacements.size} Replaced)",
        "Deactivated Sequences: #{@diff.sequence_deletions.size}",
        "Deactivated Registrations: #{@diff.registration_deletions.size}",
        "Updated new Export-Registrations: #{@export_registrations.size - @known_export_registrations}",
        "Updated existing Export-Registrations: #{@known_export_registrations}",
        "Updated new Export-Sequences: #{@export_sequences.size - @known_export_sequences}",
        "Updated existing Export-Sequences: #{@known_export_sequences}",
        "Skipped Packages: #{@skipped_packages.length}",
        "Deleted compositions: #{@deleted_compositions.join("\n")}",
        "Updated agents: #{@updated_agents.keys.to_a.join("\n")}",
        "Updated compositions: #{@new_compositions.keys.to_a.join("\n")}",
        "New agents: #{@new_agents.keys.to_.join("\n")}",
        "Anzahl Sequenzen mit leerem Feld Zusammensetzung: #{@empty_compositions.size}",
        "Total Sequences without ATC-Class: #{atcless.size}",
        atcless,
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
          skipped << "\"#{cell(row, @target_keys.index(:company))}, " \
                     "#{cell(row, @target_keys.index(:name_base))}, " \
                     "#{"%05i" % cell(row, @target_keys.index(:iksnr)).to_i}\""
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
          "http://#{SERVER_NAME}/de/gcc/show/reg/#{reg.iksnr}"
        elsif seq = @app.resolve(ptr) and seq.is_a?(ODDB::Sequence)
          "http://#{SERVER_NAME}/de/gcc/show/reg/#{seq.iksnr}/seq/#{seq.seqnr}"
        elsif pac = @app.resolve(ptr) and pac.is_a?(ODDB::Package)
          "http://#{SERVER_NAME}/de/gcc/show/reg/#{pac.iksnr}/seq/#{pac.seqnr}/pack/#{pac.ikscd}"
        end
      else
        return "no pointer for nil " unless ptr
        ptr = pointer_from_row(ptr)
        "http://#{SERVER_NAME}/de/gcc/resolve/pointer/#{ptr}"
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
                   date_cell(row, @target_keys.index(key))
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
    def update_active_agent(seq, component_in_db, substance)
      from = 'unknown'
      args = {}
      agent = nil
      update_substance(substance.name)

      ptr = if (agent = component_in_db.active_agent(substance.name))
        from = 'active_agent'
        agent.pointer
      else # agent = component_in_db.create_active_agent(substance.name, substance.is_active_agent)
        from = "creator active_agent? #{substance.is_active_agent}"
        (component_in_db.pointer + [:active_agent, substance.name, substance.is_active_agent]).creator
      end
      dose = ODDB::Dose.new(substance.qty, substance.unit)
      args[:substance]        = substance.name
      args[:dose]             = ODDB::Dose.new(substance.qty, substance.unit)
      args[:more_info]        = substance.more_info
      args[:is_active_agent]  = substance.is_active_agent
      if substance.chemical_substance
        update_substance(substance.chemical_substance.name)
        args[:chemical_dose]      = ODDB::Dose.new(substance.chemical_substance.qty, substance.chemical_substance.unit)
        args[:chemical_substance] = substance.chemical_substance.name
      end
      if args.size == 0 or (args.size == 1 and args[:dose])
        debug_msg("#{__FILE__}:#{__LINE__} update_active_agent delete_@updated_agents #{seq.iksnr}/#{seq.seqnr} agent.oid #{agent.oid} args #{args} dose #{agent.dose.to_s.downcase} == #{dose.to_s.downcase}")
        @updated_agents.delete(agent)
      else
        msg = "#{from} ptr #{ptr.inspect} #{component_in_db.active_agents.size} args #{args} substance #{substance}"
        msg += "\nagent.oid #{agent.oid} agent.substance '#{agent.substance.to_s}' " if agent
        trace_msg("#{__FILE__}:#{__LINE__} update_active_agent update #{seq.iksnr}/#{seq.seqnr} #{msg}")
        if /creator/i.match(from)
          @new_agents["#{seq.iksnr}/#{seq.seqnr}"] = msg
        else
          @updated_agents["#{seq.iksnr}/#{seq.seqnr}" ] = msg
        end
        agent = @app.update(ptr, args, :swissmedic)
      end
      component_in_db.odba_store
      [component_in_db, agent]
    end

    def remove_active_agents_that_are_nil(composition)
                          iksnr = composition.sequence.iksnr
                          seqnr = composition.sequence.seqnr
       oids2remove = composition.active_agents.find_all { |x| x.substance == nil} if composition.active_agents
       # debug_msg("#{__FILE__}:#{__LINE__} remove_active_agents_that_are_nil #{iksnr}/#{seqnr} oid #{composition.oid} oids2remove #{oids2remove}")
       oids2remove.each{ |substance|
                        debug_msg("#{__FILE__}:#{__LINE__} remove_active_agents_that_are_nil #{iksnr}/#{seqnr} composition.oid #{composition.oid} #{composition.active_agents.size} active_agents. substance.oid #{substance.oid} substance.pointer #{substance.pointer}")
                        @app.delete(substance.pointer) if substance.pointer
                        composition.delete_active_agent(substance.oid)
                        composition.odba_store
                        debug_msg("#{__FILE__}:#{__LINE__} remove_active_agents_that_are_nil #{iksnr}/#{seqnr} composition.oid #{composition.oid} has now #{composition.active_agents.size} active_agents")
                      }
    end

    def update_company(row)
      name = cell(row, @target_keys.index(:company))
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
      sequence.fix_pointers # needed for make unit tests pass. Should not do any harm on the real database
      component_in_db = @app.create(sequence.pointer + :composition)
      debug_msg("#{__FILE__}:#{__LINE__} create_composition_in_sequence component_in_db.pointer #{component_in_db.pointer.inspect} size #{sequence.compositions.size}")
      component_in_db
    end

    def update_compositions(sequence, row, opts={:create_only => false}, composition_text, parsed_comps)
      comps = []
      if !@update_comps && opts[:create_only] && !sequence.active_agents.empty?
        trace_msg("#{__FILE__}:#{__LINE__} update_compositions create_only")
        sequence.compositions
      elsif(namestr = cell(row, @target_keys.index(:substances)))
        res = []
        iksnr = "%05i" % cell(row, @target_keys.index(:iksnr)).to_i
        seqnr ="%02i" % cell(row, @target_keys.index(:seqnr)).to_i
        if (sequence.seqnr != seqnr)
          debug_msg("#{__FILE__}:#{__LINE__} update_compositions: iksnr #{iksnr} #{seqnr} mismatch between #{sequence.seqnr.inspect} and #{seqnr.inspect}")
          # require 'pry'; binding.pry
          return
        end
        if (sequence.iksnr != iksnr)
          debug_msg("#{__FILE__}:#{__LINE__} update_compositions: iksnr #{iksnr} #{seqnr} mismatch between #{sequence.iksnr.inspect} and #{iksnr.inspect}")
          # require 'pry'; binding.pry
          return
        end
        trace_msg("#{__FILE__}:#{__LINE__} update_compositions: iksnr #{iksnr} #{sequence.seqnr}/#{seqnr} sequence #{sequence} opts #{opts}") # if $VERBOSE
        names = namestr.split(/\s*,(?!\d|[^(]+\))\s*/u).collect { |name| capitalize(name) }.uniq
        substances = names.collect { |name| update_substance(name) }
        unless composition_text
          @empty_compositions << "iksnr #{iksnr} seqnr #{seqnr}"
          return []
        end
        if sequence.composition_text != composition_text
          msg = "iksnr #{iksnr} seqnr #{seqnr} composition_text #{sequence.composition_text} -> #{composition_text}"
          trace_msg("#{__FILE__}:#{__LINE__} #{msg}")
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
            debug_msg("#{__FILE__}:#{__LINE__} delete_composition #{msg} comp.pointer #{comp.pointer}")
            @deleted_compositions << msg
            sequence.delete_composition(comp.oid)
            sequence.odba_store
            @app.delete comp.pointer if comp and comp.pointer
          end
        end

        # now update the sequence with all the parsed components
        parsed_comps.each_with_index do |parsed_comp, comp_idx|
          agents = []
          msg = "iksnr #{iksnr} seqnr #{seqnr} comp_idx #{comp_idx}"
          debug_msg("#{__FILE__}:#{__LINE__} update_compositions #{msg} parsed_comp #{parsed_comp}")
          @checked_compositions << msg
          component_in_db = nil
          parsed_comp.substances.each_with_index { |substance, parsed_idx|
            components_in_db = sequence.compositions.find_all{|value| component_in_db = value if (value and value.source.eql?(parsed_comp.source)) }
            if components_in_db.size == 0
              component_in_db = create_composition_in_sequence(sequence)
              debug_msg("#{__FILE__}: #{__LINE__} #{sequence.iksnr}/#{sequence.seqnr} created composition #{component_in_db.oid} source #{parsed_comp.source[0..50]}")
            elsif components_in_db.size == 1 # normal case
              component_in_db = components_in_db.first
              debug_msg("#{__FILE__}: #{__LINE__} #{sequence.iksnr}/#{sequence.seqnr} using #{component_in_db.oid} source #{parsed_comp.source[0..50]}")
            else
              component_in_db = components_in_db.first
              components_in_db[2..-1].each{ |composition|
                debug_msg("#{__FILE__}: #{__LINE__} #{sequence.iksnr}/#{sequence.seqnr} deleting #{composition.oid} source #{parsed_comp.source[0..50]}")
                sequence.compositions.delete composition
                sequence.compositions.odba_store
              }
            end
            next if defined?(MiniTest) and not component_in_db # for unknown reasons we we cannot create the pointer when running under MiniTest
            args = {
                    :source => parsed_comp.source,
                    :label => parsed_comp.label,
                    :corresp => parsed_comp.corresp,
                    }
            @app.update(component_in_db.pointer, args, :swissmedic)
            updated_comp, updated_agent = update_active_agent(sequence, component_in_db, substance)
            agents.push updated_agent
            comps.push updated_comp
            @new_compositions[ "#{iksnr}/#{seqnr} #{comp_idx}" ] = args
            component_in_db.odba_store
            sequence.odba_store
          }
          if (component_in_db == nil)
            component_in_db = create_composition_in_sequence(sequence)
            args = {
                    :source => parsed_comp.source,
                    :label => parsed_comp.label,
                    :corresp => parsed_comp.corresp,
                    }
            @app.update(component_in_db.pointer, args,:swissmedic)
            @new_compositions[ "#{iksnr}/#{seqnr} #{comp_idx}" ] = args
            component_in_db.odba_store
            sequence.odba_store
          elsif not (parsed_comps.size == 1 && component_in_db.substances.empty?)
            component_in_db.active_agents.dup.each_with_index { |act, atc_idx|
              unless agents.include?(act.odba_instance)
                trace_msg("#{__FILE__}:#{__LINE__} update_compositions delete_agent #{comp_idx} atc_idx #{atc_idx} #{act.pointer.inspect} #{act.substance.inspect}")
                component_in_db.delete_active_agent(act.substance)
              end if act and act.substance
            }
            trace_msg("#{__FILE__}:#{__LINE__} update_compositions iksnr #{iksnr} seqnr #{seqnr} comp_idx #{comp_idx} #{component_in_db.class} #{component_in_db.active_agents.size} active_agents replace by #{agents.size} agents #{component_in_db.active_agents.first.class} #{component_in_db.active_agents} by #{agents.first.class} #{agents}")
            component_in_db.active_agents.replace agents.compact
            component_in_db.odba_store
            sequence.odba_store
          end
        end
      end
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
      # debug_msg "#{__FILE__}:#{__LINE__} update_galenic_form #{seq.seqnr} gf #{comp.galenic_form} fix ? #{opts[:fix_galenic_form].inspect}"
      opts = {:create_only => false}.merge opts
      return if comp.galenic_form && !opts[:fix_galenic_form]
      if((german = seq.name_descr) && !german.empty?)
        _update_galenic_form(comp, :de, german)
      elsif(match = GALFORM_P.match(comp.source.to_s))
        _update_galenic_form(comp, :lt, match[:galform].strip)
      else
        debug_msg"#{__FILE__}:#{__LINE__} update_galenic_form don't know how to update the galenic form. #{seq.name_descr.inspect} or source #{comp.source.to_s}"
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

        debug_msg "#{__FILE__}:#{__LINE__} _update_galenic_form ptr #{ptr} name #{name}"
        @app.update(ptr, {lang => name}, :swissmedic)
      end
      debug_msg "#{__FILE__}:#{__LINE__} _update_galenic_form comp.pointer #{comp.inspect} name #{name}"
      @app.update(comp.pointer, { :galenic_form => name }, :swissmedic)
    end
    def update_indication(name)
      name = name.to_s.strip
      unless name.empty?
        if indication = @app.indication_by_text(name)
          indication
        else
          pointer = Persistence::Pointer.new(:indication)
          debug_msg "#{__FILE__}:#{__LINE__} update_indication pointer #{pointer} name #{name}"
          @app.update(pointer.creator, {:de => name}, :swissmedic)
        end
      end
    end
    def update_package(reg, seq, row, replacements={},
                       opts={:create_only => false})
      iksnr = "%05i" % cell(row, @target_keys.index(:iksnr)).to_i
      seqnr ="%02i" % cell(row, @target_keys.index(:seqnr)).to_i
      if (seq.seqnr != seqnr)
        debug_msg("#{__FILE__}:#{__LINE__} update_package: iksnr #{iksnr} #{seqnr} mismatch between #{seq.seqnr.inspect}/#{seqnr.inspect}")
        # require 'pry'; binding.pry
        return
      end
      if (seq.iksnr != iksnr || reg.iksnr != iksnr)
        debug_msg("#{__FILE__}:#{__LINE__} update_package: iksnr #{iksnr} #{seqnr} mismatch between #{reg.iksnr.inspect}/#{seq.iksnr.inspect}#{iksnr.inspect}")
        # require 'pry'; binding.pry
        return
      end
      ikscd = sprintf('%03i', cell(row, @target_keys.index(:ikscd)).to_i)
      unless seq.pointer
        debug_msg "#{__FILE__}: #{__LINE__}: update_package problem '#{row[@target_keys.index(:iksnr)]}' ikscd #{ikscd} sequence with pointer"
        return
      end
      pidx = cell(row, row.size).to_i
      if(ikscd.to_i > 0)
        args = {
          :ikscat            => cell(row, @target_keys.index(:ikscat)),
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
        if package.nil? and ptr.is_a?(Persistence::Pointer)
          package = @app.create(ptr)
        end
        @app.update(ptr, args, :swissmedic)
        if !package.parts or package.parts.empty? or !package.parts[pidx]
          part = @app.create((ptr + [:part]).creator)
          debug_msg "#{__FILE__}:#{__LINE__} update_package create part #{part.oid} part.pointer #{part.pointer}"
        else
          part = package.parts[pidx]
        end
        args = {
          :size => [cell(row, @target_keys.index(:size)), cell(row, @target_keys.index(:unit))].compact.join(' '),
        }
        if package.sequence and package.sequence.seqnr != seq.seqnr
          debug_msg "#{__FILE__}: #{__LINE__}: update_package iksnr '#{row[@target_keys.index(:iksnr)]}' ikscd #{ikscd} should correct seqnr #{package.sequence.seqnr} -> #{seq.seqnr}?"
        end
        if(comform = @app.commercial_form_by_name(cell(row, @target_keys.index(:unit))))
          args.store :commercial_form, comform.pointer
        end
        if !part.composition \
          && (comp = seq.compositions[pidx] || seq.compositions.last)
          args.store :composition, comp.pointer
        end
        @app.update(part.pointer, args, :swissmedic)
      end
    end
    def update_registration(row, opts = {})
      first_day = Date.new(@@today.year, @@today.month, 1)
      opts = {:date => first_day, :create_only => false}.update(opts)
      opts[:date] ||= first_day
      group = cell(row, @target_keys.index(:production_science))
      if(group != 'Tierarzneimittel')
        iksnr = "%05i" % cell(row, @target_keys.index(:iksnr)).to_i
        science = cell(row, @target_keys.index(:production_science))
        ptr = if(registration = @app.registration(iksnr))
                return registration if opts[:create_only]
                registration.pointer
              else
                Persistence::Pointer.new([:registration, iksnr]).creator
              end
        expiration = date_cell(row, @target_keys.index(:expiry_date))
        if expiration.nil?
          @skipped_packages << row
          return nil
        end
        reg_date = date_cell(row, @target_keys.index(:registration_date))
        vaccine = if science =~ /Blutprodukte/ or science =~ /Impfstoffe/
                    true
                  else
                    nil
                  end
        args = {
          :ith_swissmedic      => cell(row, @target_keys.index(:index_therapeuticus)),
          :production_science  => science,
          :vaccine             => vaccine,
          :registration_date   => reg_date,
          :expiration_date     => expiration,
          :renewal_flag        => false,
          :renewal_flag_swissmedic => false,
          :inactive_date       => nil,
          :export_flag         => nil,
        }
        if(expiration < opts[:date])
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
        if(indication = update_indication(cell(row, @target_keys.index(:indication_registration))))
          args.store :indication, indication.pointer
        end

        trace_msg "#{__FILE__}:#{__LINE__} update_package #{iksnr} args  #{args}"
        @app.update ptr, args, :swissmedic
        @app.registration(iksnr)
      end
    rescue SystemStackError => err
      puts "Stack-Error when importing: #{source_row(row).pretty_inspect}"
      puts err.backtrace[-100..-1]
      nil
    end
    def update_excipiens_in_composition(seq, parsed_compositions)
      unless seq.is_a?(ODDB::Sequence)
        trace_msg("#{__FILE__}:#{__LINE__} skip update_excipiens_in_composition as #{seq.class} is not a ODDB::Sequence")
        return
      end
      unless seq.iksnr
        trace_msg("#{__FILE__}:#{__LINE__} skip update_excipiens_in_composition seq.iknsr is false")
        trace_msg("#{__FILE__}:#{__LINE__} #{seq.inspect}")
        return
      end
      iksnr = "%05i" % seq.iksnr.to_i
      seq.compositions.each_with_index {
        |db_composition, idx|
          parsed_composition = parsed_compositions.find {|parse_comp| parse_comp.source.eql?(db_composition.source)}
          if parsed_composition and parsed_composition.excipiens
            excipiens = ActiveAgent.new(parsed_composition.excipiens.name, false)
            substance = update_substance(parsed_composition.excipiens.name)
            debug_msg("#{__FILE__}:#{__LINE__} #{iksnr} #{seq.seqnr} substance #{substance.class} for #{parsed_composition.excipiens.name}")
            # require 'pry'; binding.pry if substance and not substance.is_a?(ODDB::Substance)
            excipiens.substance = substance
            if parsed_composition.excipiens.qty or parsed_composition.excipiens.unit
              excipiens.dose = Dose.new(parsed_composition.excipiens.qty, parsed_composition.excipiens.unit)
            end
            excipiens.more_info = parsed_composition.excipiens.more_info
            db_composition.add_excipiens(excipiens)
            debug_msg("#{__FILE__}:#{__LINE__} #{iksnr} #{seq.seqnr} update_excipiens_in_composition idx #{idx}: excipiens #{excipiens.inspect} from #{parsed_composition.excipiens}")
            # args = {:excipiens => excipiens }
            # res = @app.update db_composition, args, :swissmedic
            db_composition.odba_store
            seq.odba_store
          end
      }
    end
    def update_all_sequence_info(row, reg, seq, opts=nil, replacements=nil)
      composition_text   = cell(row, @target_keys.index(:composition))
      active_agents_text = cell(row, @target_keys.index(:substances))
      parsed_comps = ParseUtil.parse_compositions(composition_text, active_agents_text)
      comps = update_compositions(seq, row, opts, composition_text, parsed_comps)
      comps.each_with_index do |comp, idx|
        update_galenic_form(seq, comp, opts)
      end if comps
      update_package(reg, seq, row, replacements, opts) if replacements
      update_excipiens_in_composition(seq, parsed_comps)
    end

    def update_registrations(rows, replacements, opts=nil)
      opts ||= { :create_only => @latest_packungen ? !File.exist?(@latest_packungen) : false,
               :date        => @@today, }
      rows.each { |row|
        iksnr = "%05i" % cell(row, @target_keys.index(:iksnr)).to_i
        seqnr = "%02i" % cell(row, @target_keys.index(:seqnr)).to_i
        next if iksnr.eql?('00000')
        to_consider =  mustcheck(iksnr, opts)
        next unless row
        next unless mustcheck(iksnr, opts)
        trace_msg("#{__FILE__}:#{__LINE__} update iksnr #{iksnr} seqnr #{seqnr} #{to_consider}")
        already_disabled = GC.disable # to prevent method `method_missing' called on terminated object
        reg = update_registration(row, opts) if row
        if reg
          seq = update_sequence(reg, row, opts) if reg
          if seq
            update_all_sequence_info(row, reg, seq, opts, replacements)
          end
        end
        GC.enable unless already_disabled
      }
    end
    def update_sequence(registration, row, opts={:create_only => false})
      # remove sequence '00'/package '000' which might have been created when importing via AipsDownload.xml
      seqnr = "%02i" % cell(row, @target_keys.index(:seqnr)).to_i
      if registration.sequence('00')
        ptr = registration.sequence('00').pointer
        if ptr
          trace_msg("#{__FILE__}:#{__LINE__} delete sequence('00') seqnr #{seqnr} ptr #{ptr}")
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
      unless cell(row, @target_keys.index(:name_base))
        msg = "Empty column C for #{cell(row, @target_keys.index(:iksnr))} #{cell(row, @target_keys.index(:seqnr))}"
        trace_msg("#{__FILE__}: #{__LINE__}: #{msg}")
        @iksnr_with_wrong_data << msg
        return nil
      end
      parts = cell(row, @target_keys.index(:name_base)).split(/\s*,(?!\d|[^(]+\))\s*/u)
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
      if ctext = cell(row, @target_keys.index(:composition))
        ctext = ctext.gsub(/\r\n?/u, "\n")
      end
      sequence = registration.sequence(seqnr)

      seq_date = date_cell(row, @target_keys.index(:sequence_date))
      args = {
        :composition_text => ctext,
        :name_base        => base,
        :name_descr       => descr,
        :dose             => nil,
        :sequence_date    => seq_date,
        :export_flag      => nil,
      }
      if(sequence.nil? || sequence.atc_class.nil?)
        if(!registration.atc_classes.nil? and
           atc = registration.atc_classes.first)
          args.store :atc_class, atc.code
        elsif((key = cell(row, @target_keys.index(:substances))) && !key.include?(?,) \
             && (atc = @app.unique_atc_class(key)))
          args.store :atc_class, atc.code
        elsif(code = cell(row, @target_keys.index(:atc_class)))
          args.store :atc_class, code
        end
      end
      if(indication = update_indication(cell(row, @target_keys.index(:indication_sequence))))
        args.store :indication, indication.pointer
      end
      res = @app.update ptr, args, :swissmedic
      trace_msg "#{__FILE__}: #{__LINE__}: res #{res} == #{sequence}? #{registration.iksnr} seqnr #{sequence ? sequence.seqnr : 'nil'} args #{args}"
      res
    end
    def update_substance(name)
      name.strip!
      trace_msg "#{__FILE__}: #{__LINE__}: update_substance #{name}"
      unless name.empty?
        substance = @app.substance(name)
        if(substance.nil?)
          substance = @app.update(Persistence::Pointer.new(:substance).creator, {:lt => name}, :swissmedic)
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
      deletions.compact.delete_if {|row| table[cell(row,@target_keys.index(:iksnr))] || cell(row, row.size).to_i > 0 }
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
  end
end

