#!/usr/bin/env ruby
# SwissmedicPlugin -- oddb.org -- 18.03.2008 -- hwyss@ywesee.com

require 'fileutils'
require 'mechanize'
require 'ostruct'
require 'plugin/plugin'
require 'pp'
require 'util/persistence'
require 'util/today'
require 'swissmedic-diff'

module ODDB
  class SwissmedicPlugin < Plugin
    include SwissmedicDiff::Diff
    GALFORM_P = %r{excipiens\s+(ad|pro)\s+(?<galform>((?!\bpro\b)[^.])+)}
    SCALE_P = %r{pro\s+(?<scale>(?<qty>[\d.,]+)\s*(?<unit>[kcmuµn]?[glh]))}
    def initialize(app=nil, archive=ARCHIVE_PATH)
      super app
      @archive = File.join archive, 'xls'
      FileUtils.mkdir_p @archive
      @latest = File.join @archive, 'Packungen-latest.xls'
    end
    def update(agent=WWW::Mechanize.new, target=get_latest_file(agent))
      if(target)
        diff target, @latest, [:product_group, :atc_class]
        update_registrations @diff.news + @diff.updates, @diff.replacements
        sanity_check_deletions(@diff)
        delete @diff.package_deletions
        deactivate @diff.sequence_deletions
        deactivate @diff.registration_deletions
        FileUtils.cp target, @latest
        @change_flags = @diff.changes.inject({}) { |memo, (iksnr, flags)| 
          memo.store Persistence::Pointer.new([:registration, iksnr]), flags
          memo
        }
      end
    end
    def capitalize(string)
      string.split(/\s+/).collect { |word| word.capitalize }.join(' ')
    end
    def deactivate(deactivations)
      deactivations.each { |row|
        @app.update pointer(row), {:inactive_date => @@today}, :swissmedic
      }
    end
    def delete(deletions)
      deletions.each { |row|
        @app.delete pointer(row)
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
                row.date(column(flag)).strftime('%d.%m.%Y')
      else
        row = diff.newest_rows[iksnr].sort.first.last
        sprintf "%s (%s)", txt, cell(row, column(flag))
      end
    end
    def _known_data(latest, known_regs, known_seqs, known_pacs, newest_rows)
      if(File.exist? latest)
        super
      else
        latest = nil
        @app.registrations.each { |iksnr, reg|
          row = [ iksnr, nil, nil, reg.company_name, reg.product_group,
                  reg.index_therapeuticus, reg.production_science,
                  reg.registration_date, reg.expiration_date ]
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
                  prow[COLUMNS.size] = idx
                  known_pacs.store([iksnr, pacnr, idx], prow)
                } 
              }
            }
          end
        }
      end
    end
    def fix_compositions(skip=3)
      row = nil
      tbook = Spreadsheet.open(@latest)
      tbook.worksheet(0).each(skip) { |row|
        reg = update_registration(row) if row
        seq = update_sequence(reg, row) if reg
        update_composition(seq, row) if seq
      }
    rescue Exception => err
      puts "#{err.class} when fixing #{source_row(row).pretty_inspect}"
      puts err.backtrace[0,10]
    end
    def fix_registrations
      row = nil
      tbook = Spreadsheet::ParseExcel.parse(@latest)
      tbook.worksheet(0).each(3) { |row|
        update_registration(row) if row
      }
    rescue SystemStackError => err
      puts "System Stack Error when fixing #{source_row(row).pretty_inspect}"
      puts err.backtrace[-100..-1]
    end
    def fix_sequences
      row = nil
      tbook = Spreadsheet::ParseExcel.parse(@latest)
      tbook.worksheet(0).each(3) { |row|
        reg = update_registration(row) if row
        seq = update_sequence(reg, row) if reg
      }
    rescue SystemStackError => err
      puts "System Stack Error when fixing #{source_row(row).pretty_inspect}"
      puts err.backtrace[-100..-1]
    end
    def get_latest_file(agent)
      file = agent.get('http://www.swissmedic.ch/files/pdf/Packungen.xls')
      download = file.body
      latest = ''
      if(File.exist? @latest)
        latest = File.read @latest
      end
      if(download[-1] != ?\n)
        download << "\n"
      end
      target = File.join @archive, @@today.strftime('Packungen-%Y.%m.%d.xls')
      if(download != latest)
        File.open(target, 'w') { |fh| fh.puts(download) }
        target
      end
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
          report = sprintf(<<-EOS, salutations[email], date)
%s

Bei den folgenden Produkten wurden Änderungen gemäss Swissmedic %s vorgenommen:
          EOS
          registrations.sort_by { |reg| reg.name_base.to_s }.each { |reg|
            report << sprintf("%s: %s\n%s\n\n", reg.iksnr,
                              resolve_link(reg.pointer), 
                              format_flags(flags[reg.pointer]))
          }
          mail = Log.new(month)
          mail.report = report
          mail.recipients = [email]
          mail.notify("Swissmedic-Journal")
        }
      end
    end
    def pointer(row)
      cmnds = [:registration, :sequence, :package]
      path = cmnds[0, row[0,3].size].zip row
      Persistence::Pointer.new(*path)
    end
    def pointer_from_row(row)
      iksnr = cell(row, column(:iksnr))
      seqnr = (str = cell(row, column(:seqnr))) ? "%02i" % str.to_i : nil
      pacnr = cell(row, column(:ikscd))
      pointer [iksnr, seqnr, pacnr].compact
    end
    def report
      atcless = @app.atcless_sequences.collect { |sequence|
        resolve_link(sequence.pointer)	
      }.sort
      lines = [
        "ODDB::SwissmedicPlugin - Report #{@@today.strftime('%d.%m.%Y')}",
        "Created Packages: #{@diff.news.size}",
        "Updated Packages: #{@diff.updates.size}",
        "Deleted Packages: #{@diff.package_deletions.size} (#{@diff.replacements.size} Replaced)",
        "Deleted Sequences: #{@diff.sequence_deletions.size}",
        "Deactivated Registrations: #{@diff.registration_deletions.size}",
        "Total Sequences without ATC-Class: #{atcless.size}",
        atcless,
      ]
      lines.flatten.join("\n")
    end
    def resolve_link(ptr)
      unless(ptr.is_a? Persistence::Pointer)
        ptr = pointer_from_row(ptr)
      end
      "http://#{SERVER_NAME}/de/gcc/resolve/pointer/#{ptr}"
    end
    def rows_diff(row, other, ignore = [:product_group])
      flags = super(row, other, ignore)
      if(other.first.is_a? String)
        package = @app.registration(cell(row, column(:iksnr))).package(cell(row, column(:ikscd)))
        flags = flags.select { |flag|
          origin = package.data_origin(flag)
          origin ||= package.sequence.data_origin(flag)
          origin ||= package.registration.data_origin(flag)
          origin.nil? || origin == :swissmedic
        }
      end
      flags
    end
    def source_row(row)
      hsh = { :import_date => @@today }
      COLUMNS.each_with_index { |key, idx|
        value = case key
                when :registration_date, :expiry_date
                  row.date(idx)
                when :seqnr
                  sprintf "%02i", row.at(idx).to_i
                else
                  cell(row, idx)
                end
        hsh.store key, value
      }
      hsh
    end
    def update_active_agent(seq, name, part, opts={})
      ptrn = %r{(?ix)
                #{Regexp.escape name}
                (\s*(?<dose>[\d\-.]+(\s*[^\s,]+(\s*[mv]/[mv])?)))?
                (\s*ut\s+(?<chemical>[^\d,]+)
                      \s*(?<cdose>[\d\-.]+(\s*[^\s,]+(\s*[mv]/[mv])?))?)?
               }
      if(match = ptrn.match(part))
        comp = seq.compositions.first
        comp ||= @app.create(seq.pointer + :composition)
        ptr = if(agent = comp.active_agent(name))
                agent.pointer
              else
                (comp.pointer + [:active_agent, name]).creator
              end
        dose = match[:dose].split(/\b\s*(?![.,\d])/, 2) if match[:dose]
        cdose = match[:cdose].split(/\b\s*(?![.,\d])/, 2) if match[:cdose]
        if dose && scale = SCALE_P.match(part)
          unit = dose[1] << '/'
          num = scale[:qty].to_f
          if num <= 1
            unit << scale[:unit]
          else
            unit << scale[:scale]
          end
        end
        args = {
          :substance => name,
          :dose      => dose,
        }
        if(chemical = match[:chemical])
          chemical = capitalize(chemical)
          update_substance chemical
          chemical = nil if chemical.empty?
          args.update(:chemical_substance => chemical,
                      :chemical_dose      => cdose)
        end
        agent = @app.update(ptr, args, :swissmedic)
        [comp, agent]
      end
    end
    def update_company(row)
      name = cell(row, column(:company))
      if(company = @app.company_by_name(name)) 
        company
      else
        ptr = Persistence::Pointer.new(:company).creator
        @app.update ptr, { :name => name }
      end
    end
    def update_composition(seq, row, opts={:create_only => false})
      if opts[:create_only] && !seq.active_agents.empty?
        seq.compositions.first
      elsif(namestr = cell(row, column(:substances)))
        names = namestr.split(/\s*,\s*/).collect { |name| 
          capitalize(name) }
        substances = names.collect { |name|
          update_substance(name)
        }
        comps = []
        agents = []
        composition = cell(row, column(:composition)).gsub(/\n/, ' ')
        names.each { |name|
          comp, agent = update_active_agent(seq, name, composition, opts)
          comps.push comp
          agents.push agent
        }
        comp = comps.compact.first
        unless(agents.empty? || comp.nil?)
          comp.active_agents.dup.each { |act|
            unless agents.include?(act)
              @app.delete act.pointer
            end
          }
        end
        comp
      end
    end
    def update_galenic_form(seq, comp, row, opts={:create_only => false})
      return if comp.galenic_form
      if((german = seq.name_descr) && !german.empty?)
        _update_galenic_form(comp, :de, german)
      elsif(match = GALFORM_P.match(cell(row, column(:composition))))
        _update_galenic_form(comp, :lt, match[:galform].strip)
      end
    end
    def _update_galenic_form(comp, lang, name)
      unless(gf = @app.galenic_form(name))
        ptr = Persistence::Pointer.new([:galenic_group, 1], 
                                       [:galenic_form]).creator

        @app.update(ptr, {lang => name}, :swissmedic)
      end
      @app.update(comp.pointer, { :galenic_form => name }, :swissmedic)
    end
    def update_indication(name)
      name = name.to_s.strip
      unless name.empty?
        if indication = @app.indication_by_text(name)
          indication
        else
          pointer = Persistence::Pointer.new(:indication)
          @app.update(pointer.creator, {:de => name}, :swissmedic)
        end
      end
    end
    def update_package(reg, seq, row, replacements={}, 
                       opts={:create_only => false})
      cd = cell(row, column(:ikscd))
      pidx = cell(row, COLUMNS.size).to_i
      if(cd.to_i > 0)
        args = {
          :ikscat            => cell(row, column(:ikscat)),
          :swissmedic_source => source_row(row),
        }
        package = nil
        ptr = if(package = reg.package(cd))
                return package if opts[:create_only] && pidx == 0
                package.pointer
              else
                args.store :refdata_override, true
                (seq.pointer + [:package, cd]).creator
              end
        if((pacnr = replacements[row]) && (old = reg.package(pacnr)))
          args.update(:pharmacode => old.pharmacode, 
                      :ancestors  => (old.ancestors || []).push(pacnr))
        end
        if(pidx == 0 || package.nil?)
          package = @app.update(ptr, args, :swissmedic)
        end
        part = package.parts[pidx]
        part ||= @app.create(package.pointer + :part)
        args = {
          :size => [cell(row, column(:size)), cell(row, column(:unit))].compact.join(' '),
        }
        if(comform = @app.commercial_form_by_name(cell(row, column(:unit))))
          args.store :commercial_form, comform.pointer
        end
        if !part.composition \
          && (comp = seq.compositions[pidx] || seq.compositions.last)
          args.store :composition, comp.pointer
        end
        @app.update(part.pointer, args, :swissmedic)
      end
    end
    def update_registration(row, opts = {:date => @@today, :create_only => false})
      opts[:date] ||= @@today
      group = cell(row, column(:product_group))
      if(group != 'TAM')
        iksnr = cell(row, column(:iksnr))
        science = cell(row, column(:production_science))
        ptr = if(registration = @app.registration(iksnr))
                return registration if opts[:create_only]
                registration.pointer
              else
                Persistence::Pointer.new([:registration, iksnr]).creator
              end
        expiration = row.date(column(:expiry_date))
        args = { 
          :product_group       => group,
          :index_therapeuticus => cell(row, column(:index_therapeuticus)), 
          :production_science  => science,
          :registration_date   => row.date(column(:registration_date)),
          :expiration_date     => expiration,
          :renewal_flag        => false,
        }
        if(expiration < opts[:date])
          args.store :renewal_flag, true
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
        if(indication = update_indication(cell(row, column(:indication_registration))))
          args.store :indication, indication.pointer
        end
        @app.update ptr, args, :swissmedic
      end
    rescue SystemStackError 
      puts "Stack-Error when importing: #{source_row(row).pretty_inspect}"
      puts err.backtrace[-100..-1]
    end
    def update_registrations(rows, replacements)
      opts = { :create_only => !File.exist?(@latest),
               :date        => @@today, }
      rows.each { |row|
        reg = update_registration(row, opts) if row
        seq = update_sequence(reg, row, opts) if reg
        comp = update_composition(seq, row, opts) if seq
        update_galenic_form(seq, comp, row, opts) if comp
        update_package(reg, seq, row, replacements, opts) if reg
      }
    end
    def update_sequence(registration, row, opts={:create_only => false})
      seqnr = "%02i" % cell(row, column(:seqnr)).to_i
      ptr = if(sequence = registration.sequence(seqnr))
              return sequence if opts[:create_only]
              sequence.pointer
            else
              (registration.pointer + [:sequence, seqnr]).creator
            end
      ## some names use commas for dosage --v
      parts = cell(row, column(:name_base)).split(/\s*,(?!\d)\s*/)
      descr = parts.pop
      base = parts.join(', ')
      base, descr = descr, nil if base.empty?
      args = { 
        :composition_text => cell(row, column(:composition)),
        :name_base        => base,
        :name_descr       => descr,
        :dose             => nil,
      }
      sequence = registration.sequence(seqnr)
			if(sequence.nil? || sequence.atc_class.nil?)
				if(atc = registration.atc_classes.first)
          args.store :atc_class, atc.code
        elsif((key = cell(row, column(:substances))) && !key.include?(?,) \
             && (atc = @app.unique_atc_class(key)))
          args.store :atc_class, atc.code
				end
			end
      if(indication = update_indication(cell(row, column(:indication_sequence))))
        args.store :indication, indication.pointer
      end
      @app.update ptr, args, :swissmedic
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
      deletions.delete_if { |row| table[cell(row,column(:iksnr))] || cell(row,COLUMNS.size).to_i > 0 }
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
