#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::CsvExportPlugin -- oddb.org -- 21.12.2012 -- yasaka@ywesee.com
# ODDB::CsvExportPlugin -- oddb.org -- 20.01.2012 -- mhatakeyama@ywesee.com
# ODDB::CsvExportPlugin -- oddb.org -- 26.08.2005 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'oddb2tdat'
require 'model/package'
require 'model/atcclass'
require 'util/workdir'

module ODDB
	class CsvExportPlugin < Plugin
		EXPORT_SERVER = DRbObject.new(nil, EXPORT_URI)
    MIGEL_EXPORT_DIR = File.join(ODDB::PROJECT_ROOT, 'migel/data/csv')
    ODDB_RECIPIENTS          = ['oddb']
    ODDB_RECIPIENTS_DAT      = ['oddb_dat']
    ODDB_RECIPIENTS_EXTENDED = ['oddb_dat_extended']
		def export_doctors
			ids = @app.doctors.values.collect { |item| item.odba_id }
			EXPORT_SERVER.export_doc_csv(ids, EXPORT_DIR, 'doctors.csv')
		end
    def export_drugs
      @options = {:compression => 'zip'}
      recipients.concat self.class::ODDB_RECIPIENTS
      _export_drugs 'oddb', [ :rectype, :iksnr, :ikscd, :ikskey, :barcode,
        :bsv_dossier, :pharmacode, :name_base, :galenic_form,
        :most_precise_dose, :size, :numerical_size, :price_exfactory,
        :price_public, :company_name, :ikscat, :sl_entry, :introduction_date,
        :limitation, :limitation_points, :limitation_text, :lppv,
        :registration_date, :expiration_date, :inactive_date, :export_flag,
        :casrn, :generic_type, :has_generic, :deductible, :out_of_trade,
        :c_type, :index_therapeuticus, :ith_swissmedic, :narcotic, :vaccine, :renewal_flag_swissmedic]
    end
    def export_drugs_extended
      @options = { :compression => 'zip' }
      recipients.concat self.class::ODDB_RECIPIENTS_EXTENDED
      _export_drugs 'oddb2', [ :rectype, :iksnr, :ikscd, :ikskey, :barcode,
        :bsv_dossier, :pharmacode, :name_base, :galenic_form_de, :galenic_form_fr,
        :most_precise_dose, :size, :numerical_size_extended, :price_exfactory,
        :price_public, :company_name, :ikscat, :sl_entry, :introduction_date,
        :limitation, :limitation_points, :limitation_text, :lppv,
        :registration_date, :expiration_date, :inactive_date, :export_flag,
        :casrn, :generic_type, :has_generic, :deductible, :out_of_trade,
        :c_type, :route_of_administration, :galenic_group_de,
        :galenic_group_fr ]
    end
    def _export_drugs(export_name, keys)
      session = SessionStub.new(@app)
      session.language = 'de'
      session.lookandfeel = LookandfeelBase.new(session)
      model = @app.atc_classes.values.sort_by { |atc| atc.code }
      name = "#{export_name}.csv"
      @file_path = path = File.join(EXPORT_DIR, name)
      exporter = View::Drugs::CsvResult.new(model, session)
      exporter.to_csv_file(keys, path, :packages)
      @counts = exporter.counts
      EXPORT_SERVER.compress(EXPORT_DIR, name)
      backup = @app.log_group(:bsv_sl).newest_date.strftime("#{export_name}.%Y-%m-%d.csv")
      backup_dir = File.join(ODDB::WORK_DIR, 'csv')
      backup_path = File.join(backup_dir, backup)
      unless(File.exist? backup_path)
        FileUtils.mkdir_p(backup_dir)
      end
      FileUtils.cp(path, backup_path)
    rescue
      puts $!.message
      puts $!.backtrace
      raise
    end
    def export_fachinfo_chapter(term, chapters, lang, file)
      start = Time.new.to_i
      recipients.concat self.class::ODDB_RECIPIENTS_EXTENDED
      @model  = []
      @counts = {}
      packages = @app.active_packages_has_fachinfo
      packages.each do |pack|
        doc = pack.fachinfo.description(lang)
        found = false
        _model = {
          :package  => pack,
          :chapters => []
        }
        chapters.each do |chapter|
          key = "fi_#{chapter}"
          @counts[key] = 0 unless @counts[key]
          if doc.respond_to?(chapter)
            desc = doc.send(chapter).to_s
            text = ''
            if term.empty?
              text = desc
              @counts[key] += 1
              found = true
            elsif desc.match(/#{term}/i) and
                  text = desc.scan(/.*\n?.*#{term}.*\n?.*/i).join("\n")
              @counts[key] += 1
              found = true
            end
            _model[:chapters] << {
              :chapter => chapter,
              :matched => text
            }
          end
        end
        if found # at least term is found in 1 chapter
          @model << _model
        end
      end
      if @model.empty?
        puts
        puts "does not found any chapter/description"
        return false
      end
      i = 0
      @model = @model.sort_by{ |m| [m[:package].name_base, i += 1] }
      @session = SessionStub.new(@app)
      @session.language    = lang
      @session.lookandfeel = LookandfeelBase.new(@session)
      @file_path = path = File.join(EXPORT_DIR, file)
      exporter = View::Drugs::CsvResult.new(@model, @session)
      keys = [ # th
        :barcode, :pharmacode, :name_base,
      ]
      exporter.to_csv_file(keys, path, :fachinfos, :fachinfo_chapter)
      @total = exporter.total
      @target_packages = packages.length
      @notes  = {
        'Term'     => term,
        'Lang'     => lang,
        'Chapters' => chapters.join(','),
      }
      EXPORT_SERVER.compress(EXPORT_DIR, file)
      backup_dir = File.join(ODDB::WORK_DIR, 'csv')
      backup_path = File.join(backup_dir, file)
      unless(File.exist? backup_path)
        FileUtils.mkdir_p(backup_dir)
      end
      FileUtils.cp(path, backup_path)
      @time = Time.new.to_i - start
      return true
    rescue
      puts $!.message
      puts $!.backtrace
      raise
    end

    def export_ddd_csv
      @options = { }
      recipients.concat ['log']
      FileUtils.makedirs(EXPORT_DIR)
      @file_path = File.join EXPORT_DIR, 'ddd.csv'
      CSV.open(@file_path, "w", col_sep: ';', encoding: 'UTF-8') do |csv|
        csv << [:iksnr,
                :package,
                :pharmacode,
                :description,
                :atc_code,
                :available_roas,
                :ddd_roa,
                :ddd_dose,
                :package_roa,
                :package_dose,
                :galenic_forms,
                :price_public,
                :ddd_price,
                :calculation,
                :variant,
               ]
        @app.active_packages.sort{|x,y| [x.iksnr.to_i, x.ikscd.to_i] <=> [y.iksnr.to_i, y.ikscd.to_i]}.each do |package|
          next unless package.price_public # Skip drugs not in SL list
          next unless package.atc_class && package.atc_class.ddds.size > 0
          ddd_price, calculation, variant = package.ddd_price_calc_variant
          csv << [package.iksnr,
                  package.ikscd,
                  package.pharmacode,
                  package.name,
                  package.atc_class ? package.atc_class.code : nil,
                  package.atc_class.ddds.keys.join(','), # available_roas
                  package.ddd ? package.ddd.administration_route : nil,
                  package.ddd ? package.ddd.dose.to_s : nil,
                  package.dose ? package.dose.to_s : nil,
                  package.galenic_group ? package.galenic_group.route_of_administration : nil,
                  package.galenic_forms.collect{|x| x.to_s}.join(','),
                  package.price_public ? package.price_public.to_s : nil,
                  ddd_price,
                  calculation,
                  variant,
                ]
        end
        @file_path
      end
    end
    def export_index_therapeuticus
      FileUtils.makedirs(EXPORT_DIR)
      @options = { }
      recipients.concat self.class::ODDB_RECIPIENTS
      ids = @app.indices_therapeutici.sort.collect { |code, idx| idx.odba_id }
      files = []
      @file_path = File.join EXPORT_DIR, 'idx_th.csv'
      files.push EXPORT_SERVER.export_idx_th_csv(ids, EXPORT_DIR, 'idx_th.csv')
      ids = @app.packages.compact.sort_by { |pac| pac.ikskey.to_s }.collect { |pac|
        pac.odba_id }
      files.push EXPORT_SERVER.export_ean13_idx_th_csv(ids, EXPORT_DIR,
                                                       'ean13_idx_th.csv')
      EXPORT_SERVER.compress_many(EXPORT_DIR, 'index_therapeuticus', files)
    end
    def export_price_history
      ids = @app.packages.select do |pac| pac.has_price? end.collect do |pac|
        pac.odba_id
      end
      EXPORT_SERVER.export_price_history_csv(ids, EXPORT_DIR, 'price_history.csv')
    end
    def export_oddb_dat(transfer)
      unless transfer and  File.exist?(transfer)
        transfer = File.join(EXPORT_DIR, 'transfer.dat')
      end
      recipients.concat self.class::ODDB_RECIPIENTS_DAT
      input = File.join(EXPORT_DIR, 'oddb.csv')
      output = File.join(EXPORT_DIR, 'oddb.dat')
      @file_path = output
      @options ||= {}
      @options[:compression] = 'zip'
      gem_app = Oddb2tdat.new(input, output, transfer)
      gem_app.run
      @updated_arztpreis = gem_app.updated_prmo
      @total = "#{gem_app.counts[:oddb]}(Medis)"
      EXPORT_SERVER.compress(EXPORT_DIR, 'oddb.dat')
    end
    def export_oddb_dat_with_migel(transfer)
      unless transfer and File.exist?(transfer)
        transfer = File.join(EXPORT_DIR, 'transfer.dat')
      end
      recipients.concat self.class::ODDB_RECIPIENTS_DAT
      input1 = File.join(EXPORT_DIR,       'oddb.csv')
      input2 = File.join(MIGEL_EXPORT_DIR, 'migel_product_de.csv')
      output = File.join(EXPORT_DIR, 'oddb_with_migel.dat')
      @file_path = output
      @options ||= {}
      @options[:compression] = 'zip'
      FileUtils.makedirs(File.dirname(output))
      gem_app = Oddb2tdat.new(input1, output, input2, transfer) # see help of oddb2tdat gem
      gem_app.target.push(:migel)
      gem_app.run
      @updated_arztpreis = gem_app.updated_prmo
      all_rows = gem_app.counts[:oddb] + gem_app.counts[:migel]
      @total = "#{gem_app.counts[:migel]}(MiGel) / #{all_rows} (Total)"
      EXPORT_SERVER.compress(EXPORT_DIR, 'oddb_with_migel.dat')
    end
    def export_teilbarkeit
      recipients.concat self.class::ODDB_RECIPIENTS_EXTENDED
      export_name = 'teilbarkeit'
      keys = [
        :barcode, :pharmacode, :name_base,
        :divisable, :dissolvable, :crushable, :openable, :notes,
        :source,
      ]
      session = SessionStub.new(@app)
      session.language = 'de'
      session.lookandfeel = LookandfeelBase.new(session)
      # not use atc_class
      model = @app.sequences.values.select { |seq| (div = seq.division and !div.empty?) }
      name = "#{export_name}.csv"
      @file_path = path = File.join(EXPORT_DIR, name)
      exporter = View::Drugs::CsvResult.new(model, session)
      exporter.to_csv_file(keys, path, :packages, :division)
      @total = exporter.total
      @counts = exporter.divisions
      EXPORT_SERVER.compress(EXPORT_DIR, name)
      backup = Date.today.strftime("#{export_name}.%Y-%m-%d.csv")
      backup_dir = File.join(ODDB::WORK_DIR, 'csv')
      backup_path = File.join(backup_dir, backup)
      unless(File.exist? backup_path)
        FileUtils.mkdir_p(backup_dir)
      end
      FileUtils.cp(path, backup_path)
    rescue
      puts $!.message
      puts $!.backtrace
      raise
    end
    def export_flickr_photo
      recipients.concat self.class::ODDB_RECIPIENTS_EXTENDED
      export_name = 'flickr_ean_export'
      keys = [
        :flickr_photo_id, :barcode, :iksnr, :seqnr,
      ]
      session = SessionStub.new(@app)
      session.language = 'de'
      session.lookandfeel = LookandfeelBase.new(session)
      # not use atc_class
      model = @app.packages.values.select { |pack| pack.has_flickr_photo? }
      name = "#{export_name}.csv"
      @file_path = path = File.join(EXPORT_DIR, name)
      exporter = View::Drugs::CsvResult.new(model, session)
      exporter.to_csv_file(keys, path, :packages, :flickr_photo)
      @total = exporter.total
      @counts = exporter.flickr_photos
      EXPORT_SERVER.compress(EXPORT_DIR, name)
      backup = Date.today.strftime("#{export_name}.%Y-%m-%d.csv")
      backup_dir = File.join(ODDB::WORK_DIR, 'csv')
      backup_path = File.join(backup_dir, backup)
      unless(File.exist? backup_path)
        FileUtils.mkdir_p(backup_dir)
      end
      FileUtils.cp(path, backup_path)
    rescue
      puts $!.message
      puts $!.backtrace
      raise
    end
    def log_info
      hash = super
      if @file_path
        @options ||= {}
        path = @file_path
        type = "text/csv"
        if comp = @options[:compression]
          path = @file_path + "." << comp
          type = "application/#{comp}"
        end
        hash.store(:files, { path => type })
        hash.store(:recipients, recipients)
      end
      hash
    end
    def report
      report = ''
      if @total
        report << sprintf("%-32s %5i\n", "Anzahl:", @total.to_i)
      end
      if @counts
        @counts.sort.collect do |key, val|
          case key
          # teilbarkeit
          when /^notes$/    ; key = 'has_notes'
          when /^openable$/ ; key = 'can be opened'
          when /^source$/   ; key = 'have a source'
          # flickr
          when /^barcode$/  ; key = 'EAN-Codes'
          when /^flickr_photo_id$/ ; key = 'Flickr-IDs'
          when /^iksnr$/    ; key = 'Registration Numbers'
          when /^seqnr$/    ; key = 'Sequence Numbers'
          else
            if @session
              key = @session.lookandfeel.lookup(key)
            end
          end
          report << sprintf("%-32s %5i\n", "#{key}:", val)
        end
      end
      if @target_packages
        report << "\n"
        report << sprintf("%-32s %5i\n", "Packages:", "#{@target_packages.to_i}")
        report << "\n"
        @notes.sort.collect do |key, val|
          report << sprintf("%-32s %s\n", "#{key}:", val)
        end
        report << "\n"
        report << sprintf("%-32s %s\n", "File:", @file_path.to_s)
      end
      if @updated_arztpreis
        report << [
          "Updated ArztPreise (05 PRMO Arztpreis (=Galexis-Basis-Preis) 061 – 066 6 num): #{@updated_arztpreis}",
          "",
          "File: #{@file_path}",
        ].join("\n")
      end
      if @time
        report << "\n"
        report << sprintf("%-32s %s\n", "Duration:", "#{(@time / 60).to_s} min.")
      end
      report
    end
	end
end
