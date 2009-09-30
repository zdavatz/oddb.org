#!/usr/bin/env ruby
# Exporter -- oddb -- 30.07.2003 -- hwyss@ywesee.com 

require 'plugin/oddbdat_export'
require 'plugin/fipdf'
require 'plugin/yaml'
require 'plugin/csv_export'
require 'plugin/patinfo_invoicer'
require 'plugin/fachinfo_invoicer'
require 'plugin/download_invoicer'
require 'plugin/ouwerkerk'
require 'plugin/xls_export'
require 'util/log'
require 'util/logfile'
require 'util/schedule'

module ODDB
	class Exporter
    include Util::Schedule
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
      mail_fachinfo_log
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
      export_index_therapeuticus_csv
      export_price_history_csv
      run_on_monthday(1) {
        export_fachinfo_pdf
      }
      nil
    end
    def export_helper(name)
      EXPORT_SERVER.remote_safe_export(EXPORT_DIR, name) { |path|
        yield path
      }
    end
		def export_competition_xls(company, db_path=nil)
			plug = XlsExportPlugin.new(@app)
			plug.export_competition(company, db_path)
			plug
		end
    def export_csv
      plug = CsvExportPlugin.new(@app)
      safe_export 'oddb.csv' do
        plug.export_drugs
      end
      safe_export 'oddb.csv' do
        plug.export_drugs_extended
      end
      EXPORT_SERVER.clear
      sleep(30)
    end
		def export_analysis_csv
			plug = CsvExportPlugin.new(@app)
			plug.export_analysis
			EXPORT_SERVER.clear
			sleep(30)
		end
		def export_doc_csv
      safe_export 'doctors.csv' do
        plug = CsvExportPlugin.new(@app)
        plug.export_doctors
      end
      EXPORT_SERVER.clear
      sleep(30)
		end
    def export_fachinfo_pdf(langs = [:de, :fr])
      plug = FiPDFExporter.new(@app)
      langs.each { |lang|
        name = "fachinfos_#{lang}.pdf"
        safe_export name do
          path = File.join(EXPORT_DIR, name)
          plug.write_pdf(lang, path)
          EXPORT_SERVER.compress(EXPORT_DIR, name)
        end
      }
    end
		def export_generics_xls
			plug = XlsExportPlugin.new(@app)
			plug.export_generics
			plug
		end
		def export_swissdrug_xls(date = @@today, opts={})
			plug = OuwerkerkPlugin.new(@app, "swissdrug update")
			plug.export_xls opts
			name = 'swissdrug-update.xls'
			path = File.join(EXPORT_DIR, name)
			FileUtils.cp(plug.file_path, path)
			EXPORT_SERVER.compress(EXPORT_DIR, name)
			plug
		end
    def export_index_therapeuticus_csv
      safe_export 'index_therapeuticus' do
        plug = CsvExportPlugin.new(@app)
        plug.export_index_therapeuticus
      end
      EXPORT_SERVER.clear
      sleep(30)
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
      safe_export 'oddbdat' do
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
		end
		def export_pdf
			FiPDFExporter.new(@app).run
		end
		def export_sl_pcodes
      safe_export 'sl_pcodes.txt' do
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
		end
    def export_patents_xls
      plug = XlsExportPlugin.new(@app)
      plug.export_patents
      plug
    end
		def export_yaml
			exporter = YamlExporter.new(@app)
      safe_export 'oddb.yaml' do
        exporter.export
      end
      safe_export 'atc.yaml' do
        exporter.export_atc_classes
      end
      safe_export 'interactions.yaml' do
        exporter.export_interactions
      end
      safe_export 'narcotics.yaml' do
        exporter.export_narcotics
      end
      safe_export 'price_history.yaml' do
        exporter.export_prices
      end
			run_on_weekday(2) {
        safe_export 'fachinfo.yaml' do
          exporter.export_fachinfos
        end
			}
			run_on_weekday(3) {
        safe_export 'patinfo.yaml' do
          exporter.export_patinfos
        end
			}
			run_on_weekday(4) {
        safe_export 'doctors.yaml' do
          exporter.export_doctors
        end
			}
			EXPORT_SERVER.clear
			sleep(30)
		end
		def mail_download_stats
      safe_export 'Mail Download-Statistics' do
        mail_stats('download')
      end
		end
		def mail_download_invoices
      safe_export 'Mail Download-Invoices' do
        DownloadInvoicer.new(@app).run
      end
		end
		def mail_fachinfo_log(day = @@today)
      safe_export 'Mail Fachinfo-Invoices' do
        plug = FachinfoInvoicer.new(@app)
        plug.run(day)
        if report = plug.report
          log = Log.new(day)
          log.date_str = day.strftime("%d.%m.%Y")
          log.report = report
          log.notify("Fachinfo-Uploads")
        end
      end
		end
		def mail_feedback_stats
      safe_export 'Mail Feedback-Statistics' do
        mail_stats('feedback')
      end
		end
		def mail_notification_stats
			file = @app.notification_logger.create_csv(@app)
			headers = {
				:filename => 'notifications.csv',
				:mime_type => 'text/csv',
				:subject => 'Täglicher CSV-Export der Notifications', 
			}
			Log.new(@@today).notify_attachment(file, headers)
		end
		def mail_patinfo_invoices
      safe_export 'Mail Patinfo-Invoices' do
        PatinfoInvoicer.new(@app).run
      end
		end
    def export_price_history_csv
      safe_export 'price_history.csv' do
        plug = CsvExportPlugin.new(@app)
        plug.export_price_history
      end
      EXPORT_SERVER.clear
      sleep(30)
    end
		def mail_stats(key)
			date = @@today
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
    def mail_swissmedic_notifications
      SwissmedicPlugin.new(@app).mail_notifications
    end
    def safe_export subject, &block
      block.call
		rescue StandardError => e
      EXPORT_SERVER.clear rescue nil
			log = Log.new(@@today)
			log.report = [
				"Error: #{e.class}",
				"Message: #{e.message}",
				"Backtrace:",
				e.backtrace.join("\n"),
			].join("\n")
			log.notify("Error Export: #{subject}")
      sleep(30)
    end
	end
end
