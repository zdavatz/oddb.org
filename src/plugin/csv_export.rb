#!/usr/bin/env ruby
# CsvExportPlugin -- oddb -- 26.08.2005 -- hwyss@ywesee.com

require 'plugin/plugin'

module ODDB
	class CsvExportPlugin < Plugin
		EXPORT_SERVER = DRbObject.new(nil, EXPORT_URI)
		EXPORT_DIR = File.join(ARCHIVE_PATH, 'downloads')
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
      recipients << "peter.tobler@seconag.com"
      keys = [ :rectype, :iksnr, :ikscd, :ikskey, :barcode, :bsv_dossier,
        :pharmacode, :name_base, :galenic_form, :most_precise_dose, :size,
        :numerical_size, :price_exfactory, :price_public, :company_name,
        :ikscat, :sl_entry, :introduction_date, :limitation,
        :limitation_points, :limitation_text, :lppv, :registration_date,
        :expiration_date, :inactive_date, :export_flag, :casrn, :generic_type,
        :has_generic, :deductible, :out_of_trade, :c_type ]
      session = SessionStub.new(@app)
      session.language = 'de'
      #session.flavor = 'gcc'
      session.lookandfeel = LookandfeelBase.new(session)
      model = @app.atc_classes.values.sort_by { |atc| atc.code }
      name = 'oddb.csv'
      @file_path = path = File.join(EXPORT_DIR, name)
      exporter = View::Drugs::CsvResult.new(model, session)
      exporter.to_csv_file(keys, path, :packages)
      EXPORT_SERVER.compress(EXPORT_DIR, name)
      backup = @app.log_group(:bsv_sl).newest_date.strftime("oddb.%Y-%m-%d.csv")
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
    def log_info
      hash = super
      if @file_path
        hash.update({
          :files			=> { @file_path => "text/csv"},
          :recipients => recipients,
        })
      end
      hash
    end
	end
end
