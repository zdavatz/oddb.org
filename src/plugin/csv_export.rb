#!/usr/bin/env ruby
# CsvExportPlugin -- oddb -- 26.08.2005 -- hwyss@ywesee.com

require 'plugin/plugin'

module ODDB
	class CsvExportPlugin < Plugin
		EXPORT_SERVER = DRbObject.new(nil, EXPORT_URI)
		EXPORT_DIR = File.join(ARCHIVE_PATH, 'downloads')
    ODDB_RECIPIENTS = [ "produktion@seconag.com" ]
    ODDB_RECIPIENTS_EXTENDED = [ "metamaxi@postmail.ch" ]
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
      @options = { :iconv => 'ISO-8859-1//TRANSLIT//IGNORE' }
      recipients.concat self.class::ODDB_RECIPIENTS
      _export_drugs 'oddb', [ :rectype, :iksnr, :ikscd, :ikskey, :barcode,
        :bsv_dossier, :pharmacode, :name_base, :galenic_form,
        :most_precise_dose, :size, :numerical_size, :price_exfactory,
        :price_public, :company_name, :ikscat, :sl_entry, :introduction_date,
        :limitation, :limitation_points, :limitation_text, :lppv,
        :registration_date, :expiration_date, :inactive_date, :export_flag,
        :casrn, :generic_type, :has_generic, :deductible, :out_of_trade,
        :c_type, :index_therapeuticus, :narcotic, :vaccine ]
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
      dups = exporter.duplicates
      @counts = exporter.counts
      @counts['duplicates'] = dups.size
      unless(dups.empty?)
        log = Log.new(@@today)
        log.report = sprintf "CSV-Export includes %i duplicates:\n%s",
                             dups.size, dups.join("\n")
        log.notify("CSV-Export includes %i duplicates" % dups.size)
      end
      EXPORT_SERVER.compress(EXPORT_DIR, name)
      backup = @app.log_group(:bsv_sl).newest_date.strftime("#{export_name}.%Y-%m-%d.csv")
      backup_dir = File.expand_path('../../data/csv', File.dirname(__FILE__))
      backup_path = File.join(backup_dir, backup)
      unless(File.exist? backup_path)
        FileUtils.mkdir_p(backup_dir)
        FileUtils.cp(path, backup_path)
      end
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
		def export_migel
			ids = @app.migel_products.sort_by { |product| 
				product.migel_code }.collect { |product| product.odba_id }
			EXPORT_SERVER.export_migel_csv(ids, EXPORT_DIR, 'migel.csv')
		end
		def export_narcotics
			ids = @app.narcotics.values.sort_by { |narcotic| 
				narcotic.substance.to_s }.collect { |narcotic| 
				narcotic.odba_id }
			EXPORT_SERVER.export_narcotics_csv(ids, EXPORT_DIR,
				'narcotics.csv')
		end
    def export_price_history
      ids = @app.packages.select do |pac| pac.has_price? end.collect do |pac|
        pac.odba_id
      end
      EXPORT_SERVER.export_price_history_csv(ids, EXPORT_DIR, 'price_history.csv')
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
      if @counts
        @counts.sort.collect do |key, val|
          report << sprintf("%-32s %5i\n", key, val)
        end
      end
      report
    end
	end
end
