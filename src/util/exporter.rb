#!/usr/bin/env ruby
# Exporter -- oddb -- 30.07.2003 -- hwyss@ywesee.com 

require 'plugin/oddbdat_export'
require 'plugin/fipdf'
require 'plugin/yaml'
require 'plugin/csv_export'
require 'plugin/patinfo_invoicer'
require 'plugin/download_invoicer'
require 'plugin/ouwerkerk'
require 'plugin/xls_export'
require 'util/log'
require 'util/logfile'

module ODDB
	class Exporter
		EXPORT_SERVER = DRbObject.new(nil, EXPORT_URI)
		EXPORT_DIR = File.expand_path('../../data/downloads',
																	File.dirname(__FILE__))
		FileUtils.mkdir_p(EXPORT_DIR)
		class SessionStub
			attr_accessor :language, :flavor, :lookandfeel
			alias :default_language :language
		end
		def initialize(app)
			@app = app
		end
		def run
			mail_patinfo_invoices
			run_on_monthday(1) {
				mail_download_invoices
			}
			run_on_monthday(15) {
				mail_download_invoices
			}
			run_on_weekday(0) { 
				mail_download_stats
				mail_feedback_stats
				#mail_notification_stats
			}
			export_sl_pcodes
			export_yaml
			export_oddbdat
			export_csv
			export_doc_csv
		rescue StandardError => e
			EXPORT_SERVER.clear
			log = Log.new(Date.today)
			log.report = [
				"Error: #{e.class}",
				"Message: #{e.message}",
				"Backtrace:",
				e.backtrace.join("\n"),
			].join("\n")
			log.notify("Error: Export")
			nil
		end
		def export_csv
			keys = [ :iksnr, :ikscd, :barcode, :pharmacode, :name_base,
				:galenic_form, :most_precise_dose, :size, :numerical_size,
				:price_exfactory, :price_public, :company_name, :ikscat,
				:sl_entry, :introduction_date, :limitation,
				:limitation_points, :limitation_text, :registration_date,
				:expiration_date, :inactive_date, :export_flag, :casrn ]
			session = SessionStub.new
			session.language = 'de'
			session.flavor = 'gcc'
			session.lookandfeel = LookandfeelBase.new(session)
			model = @app.atc_classes.values.sort_by { |atc| atc.code }
			name = 'oddb.csv'
			path = File.join(EXPORT_DIR, name)
			exporter = View::Drugs::CsvResult.new(model, session)
			exporter.to_csv_file(keys, path)
			EXPORT_SERVER.compress(EXPORT_DIR, name)
			EXPORT_SERVER.clear
			sleep(30)
		rescue
			puts $!.message
			puts $!.backtrace
			raise
		end
		def export_doc_csv
			plug = CsvExportPlugin.new(@app)
			plug.export_doctors
			EXPORT_SERVER.clear
			sleep(30)
		end
		def export_generics_xls
			plug = XlsExportPlugin.new(@app)
			plug.export_generics
			EXPORT_SERVER.clear
			sleep(30)
		end
		def export_meddrugs_xls(date = Date.today)
			plug = OuwerkerkPlugin.new(@app)
			plug.export_xls
			name = 'meddrugs-update.xls'
			path = File.join(EXPORT_DIR, name)
			FileUtils.cp(plug.file_path, path)
			EXPORT_SERVER.compress(EXPORT_DIR, name)
			plug
		end
		def export_migel_csv
			plug = CsvExportPlugin.new(@app)
			plug.export_migel
			EXPORT_SERVER.clear
			sleep(30)
		end
		def export_narcotics_csv
			plug = CsvExportPlugin.new(@app)
			plug.export_narcotics
			EXPORT_SERVER.clear
			sleep(30)
		end
		def export_oddbdat
			exporter = OdbaExporter::OddbDatExport.new(@app)
			exporter.export
			EXPORT_SERVER.clear
			sleep(30)
			run_on_weekday(1) {
				exporter.export_fachinfos
				EXPORT_SERVER.clear
				sleep(30)
			}
		end
		def export_pdf
			FiPDFExporter.new(@app).run
		end
		def export_sl_pcodes
			path = File.expand_path('../../data/txt/sl_pcodes.txt', 
				File.dirname(__FILE__))
			File.open(path, 'w') { |fh|
				@app.each_package { |pac|
					if(pac.sl_entry && pac.pharmacode)
						fh.puts(pac.pharmacode)
					end
				}
			}
		end
		def export_yaml
			exporter = YamlExporter.new(@app)
			exporter.export
			exporter.export_atc_classes
			exporter.export_narcotics
			run_on_weekday(2) {
				exporter.export_fachinfos
			}
			run_on_weekday(3) {
				exporter.export_patinfos
			}
			run_on_weekday(4) {
				exporter.export_doctors
			}
			EXPORT_SERVER.clear
			sleep(30)
		end
		def mail_download_stats
			mail_stats('download')
		end
		def mail_download_invoices
			DownloadInvoicer.new(@app).run
		end
		def mail_feedback_stats
			mail_stats('feedback')
		end
		def mail_notification_stats
			file = @app.notification_logger.create_csv(@app)
			headers = {
				:filename => 'notifications.csv',
				:mime_type => 'text/csv',
				:subject => 'Täglicher CSV-Export der Notifications', 
			}
			Log.new(Date.today).notify_attachment(file, headers)
		end
		def mail_patinfo_invoices
			PatinfoInvoicer.new(@app).run
		end
		def mail_stats(key)
			date = Date.today
			if(date.mday < 8)
				date = date << 1
			end
			log = Log.new(date)
			begin
				log.report = File.read(LogFile.filename(key, date))
			rescue StandardError => e
				log.report = ([
					"Nothing to Report.",
					nil, 
					e.class,
					e.message 
				] + e.backtrace).join("\n")
			end
			log.notify("#{key.capitalize}-Statistics")
		end
		def run_on_monthday(day, &block)
			if(Date.today.day == day)
				block.call
			end
		end
		def run_on_weekday(day, &block)
			if(Date.today.wday == day)
				block.call
			end
		end
	end
end
