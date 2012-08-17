#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::CsvExportPlugin -- oddb.org -- 17.08.2012 -- yasaka@ywesee.com
# ODDB::CsvExportPlugin -- oddb.org -- 20.01.2012 -- mhatakeyama@ywesee.com
# ODDB::CsvExportPlugin -- oddb.org -- 26.08.2005 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'oddb2tdat'

module ODDB
	class CsvExportPlugin < Plugin
		EXPORT_SERVER = DRbObject.new(nil, EXPORT_URI)
		EXPORT_DIR = File.join(ARCHIVE_PATH, 'downloads')
    MIGEL_EXPORT_DIR = File.expand_path('../../../migel/data/csv', File.dirname(__FILE__))
    ODDB_RECIPIENTS = [ "produktion@seconag.com", "paul.wiederkehr@pharmasuisse.org" ]
    ODDB_RECIPIENTS_EXTENDED = [ "ouwerkerk@bluewin.ch" ]
		def export_analysis
			ids = @app.analysis_positions.sort_by { |pos|
				pos.code }.collect { |pos| pos.odba_id }
			EXPORT_SERVER.export_analysis_csv(ids, EXPORT_DIR, 'analysis.csv')
		end
		def export_doctors
			ids = @app.doctors.values.collect { |item| item.odba_id }
			EXPORT_SERVER.export_doc_csv(ids, EXPORT_DIR, 'doctors.csv')
		end
    def export_drugs
      @options = { :iconv => 'ISO-8859-1//TRANSLIT//IGNORE', :compression => 'zip'}
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
      encoding = if enc = @options.delete(:iconv) and enc = enc.split('/')
                   enc.first
                 end
      exporter.to_csv_file(keys, path, :packages, encoding)
      @counts = exporter.counts
      EXPORT_SERVER.compress(EXPORT_DIR, name)
      backup = @app.log_group(:bsv_sl).newest_date.strftime("#{export_name}.%Y-%m-%d.csv")
      backup_dir = File.expand_path('../../data/csv', File.dirname(__FILE__))
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
    def export_index_therapeuticus
      @options = { :iconv => 'ISO-8859-1//TRANSLIT//IGNORE' }
      recipients.concat self.class::ODDB_RECIPIENTS
      ids = @app.indices_therapeutici.sort.collect { |code, idx| idx.odba_id }
      files = []
      @file_path = File.join EXPORT_DIR, 'idx_th.csv'
      files.push EXPORT_SERVER.export_idx_th_csv(ids, EXPORT_DIR, 'idx_th.csv')
      ids = @app.packages.sort_by { |pac| pac.ikskey }.collect { |pac| 
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
      input = File.join(EXPORT_DIR, 'oddb.csv')
      output = File.join(EXPORT_DIR, 'oddb.dat')
      @file_path = output
      @options ||= {}
      @options[:compression] = 'zip'
      gem_app = Oddb2tdat.new(input, output, transfer)
      gem_app.run
      @updated_arztpreis = gem_app.updated_prmo
      @total = gem_app.counts[:oddb]
      EXPORT_SERVER.compress(EXPORT_DIR, 'oddb.dat')
    end
    def export_oddb_dat_with_migel(transfer)
      unless transfer and File.exist?(transfer)
        transfer = File.join(EXPORT_DIR, 'transfer.dat')
      end
      input1 = File.join(EXPORT_DIR,       'oddb.csv')
      input2 = File.join(MIGEL_EXPORT_DIR, 'migel_product_de.csv')
      output = File.join(EXPORT_DIR, 'oddb_with_migel.dat')
      @file_path = output
      @options ||= {}
      @options[:compression] = 'zip'
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
      encoding = 'UTF-8'
      exporter.to_csv_file(keys, path, :packages, encoding, :division)
      @total = exporter.total
      @counts = exporter.divisions
      EXPORT_SERVER.compress(EXPORT_DIR, name)
      backup = Date.today.strftime("#{export_name}.%Y-%m-%d.csv")
      backup_dir = File.expand_path('../../data/csv', File.dirname(__FILE__))
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
      encoding = 'UTF-8'
      exporter.to_csv_file(keys, path, :packages, encoding, :flickr_photo)
      @total = exporter.total
      @counts = exporter.flickr_photos
      EXPORT_SERVER.compress(EXPORT_DIR, name)
      backup = Date.today.strftime("#{export_name}.%Y-%m-%d.csv")
      backup_dir = File.expand_path('../../data/csv', File.dirname(__FILE__))
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
        if iconv = @options[:iconv]
          type = [ type, iconv ]
        end
        hash.store(:files, { path => type })
        hash.store(:recipients, recipients)
      end
      hash
    end
    def report
      report = ''
      if @total
        report << sprintf("%-32s %s\n", "total:", @total.to_s)
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
          end
          report << sprintf("%-32s %5i\n", "#{key}:", val)
        end
      end
      if @updated_arztpreis
        report << [
          "Updated ArztPreise (05 PRMO Arztpreis (=Galexis-Basis-Preis) 061 – 066 6 num): #{@updated_arztpreis}",
          "",
          "File: #{@file_path}",
        ].join("\n")
      end
      report
    end
	end
end
