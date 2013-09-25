#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Exporter -- oddb.org -- 14.05.2013 -- yasaka@ywesee.com
# ODDB::Exporter -- oddb.org -- 20.01.2012 -- mhatakeyama@ywesee.com 
# ODDB::Exporter -- oddb.org -- 30.07.2003 -- hwyss@ywesee.com 

require 'plugin/oddbdat_export'
require 'plugin/fipdf'
require 'plugin/yaml'
require 'plugin/csv_export'
require 'plugin/patinfo_invoicer'
require 'plugin/fachinfo_invoicer'
require 'plugin/download_invoicer'
require 'plugin/ouwerkerk'
require 'plugin/xls_export'
require 'plugin/swissmedic'
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
  private
    def logExport(msg)
      return if defined?(Minitest)
      now = Time.now
      $stdout.puts("#{now}: #{msg}"); $stdout.flush
      LogFile.append('oddb/debug', ' ' + msg, now)
      system("logger #{__FILE__}: #{msg}")
    end
    
    def restart_export_server(sleep_time = 60)
      logExport("restart_export_server. Called from #{caller[0].split(':in ')[0]}")
      EXPORT_SERVER.clear
      sleep(sleep_time)      
      logExport("restart_export_server. Done sleeping #{sleep_time} seconds")
      return sleep 0.1 # to be compatible with return code of old sleep
    end
  public
		# options parameter is needed to be compatible with calls via update_notify_simple
		def initialize(app, options=nil)
			@app = app
		end
    def run
      #
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
        export_yaml
        export_oddbdat
        #mail_notification_stats
      }
      export_sl_pcodes
      #export_yaml
      export_csv
      export_doc_csv
      export_index_therapeuticus_csv
      export_price_history_csv
=begin # inoperable atm.
      run_on_monthday(1) {
        export_fachinfo_pdf
      }
=end
      restart_export_server
      nil
    end
    def export_helper(name)
      EXPORT_SERVER.remote_safe_export(EXPORT_DIR, name) { |path|
        yield path
      }
    end
    def export_all_csv
      export_csv
      export_doc_csv
      export_index_therapeuticus_csv
      export_price_history_csv
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
      safe_export 'oddb2.csv' do
        plug.export_drugs_extended
      end
    end
		def export_analysis_csv
			plug = CsvExportPlugin.new(@app)
			plug.export_analysis
		end
		def export_doc_csv
      safe_export 'doctors.csv' do
        plug = CsvExportPlugin.new(@app)
        plug.export_doctors
      end
		end
    def export_fachinfo_chapter(term, chapters, lang)
      title = 'Fachinfo Chapter Export'
      safe_export title do
        today = Date.today
        chapter_text = chapters.join('-')
        term_text    = term.empty? ? 'all' : term.gsub(/\s/, '-')
        file = today.strftime("fachinfo_chapter_#{chapter_text}_#{term_text}.%Y-%m-%d.csv")
        plug = CsvExportPlugin.new(@app)
        if plug.export_fachinfo_chapter(term, chapters, lang, file)
          if report = plug.report
            log = Log.new(today)
            log.date_str = today.strftime("%d.%m.%Y")
            log.report = report
            path = File.join(EXPORT_DIR, "#{file}.zip")
            log.files = {
              path => ['application/zip']
            }
            log.notify(title)
          end
        end
      end
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
    end
		def export_migel_csv
			plug = CsvExportPlugin.new(@app)
			plug.export_migel
		end
    def report_dose_missing_list(list)
      log = Log.new(@@today)
      log.report = [
        "Warning: Dose data (ODDB::Package.parts, Array of ODDB::Dose instances) is empty.",
        "Message: export_oddbdat succeeded but the following package(s) do not have Dose data.",
        "Package(s):",
        list.collect do |list|
          list[0].to_s + ", " + \
          "http://#{SERVER_NAME}/de/gcc/show/reg/" + list[1].to_s + \
          "/seq/" + list[2].to_s + "/pack/" + list[3].to_s + ".\n"
        end
      ].join("\n")
      log.notify("Warning Export: oddbdat")
    end
		def export_oddbdat
          dose_missing_list = []
      safe_export 'oddbdat' do
        exporter = OdbaExporter::OddbDatExport.new(@app)
        dose_missing_list = exporter.export
        
        exporter.export_fachinfos

        # here to raise warning if package.parts is empty
        if !dose_missing_list.empty?
          report_dose_missing_list(dose_missing_list)
        end
      end
		end
    def export_oddbdat_by_company_name(company_name)
      subj = "oddbdat #{company_name}"
      dose_missing_list = []
      safe_export(subj) do
        exporter = OdbaExporter::OddbDatExport.new(@app)
        dose_missing_list = exporter.export_by_company_name(company_name)

        log = Log.new(@@today)
        log.update_values(exporter.log_info)
        log.notify(subj)

        # here to raise warning if package.parts is empty
        if !dose_missing_list.empty?
          report_dose_missing_list(dose_missing_list)
        end
      end
    end
    def export_oddb2tdat(transfer_file=nil)
      subj = 'oddb2tdat'
      safe_export(subj) do
        plug = CsvExportPlugin.new(@app)
        plug.export_oddb_dat(transfer_file)
        log = Log.new(@@today)
        log.update_values(plug.log_info)
        log.report = plug.report
        log.notify(subj)
      end
    end
    def export_oddb2tdat_with_migel(transfer_file=nil)
      subj = 'oddb2tdat with migel'
      safe_export(subj) do
        plug = CsvExportPlugin.new(@app)
        plug.export_oddb_dat_with_migel(transfer_file)
        log = Log.new(@@today)
        log.update_values(plug.log_info)
        log.report = plug.report
        log.notify(subj)
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
      safe_export 'price_history.yaml' do
        exporter.export_prices
      end
			run_on_weekday(2) {
        # ebooks need fachinfo_now.yaml
        safe_export 'fachinfo_now.yaml' do
          exporter.export_effective_fachinfos
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
		end
    def export_fachinfo_yaml(option='')
      exporter = YamlExporter.new(@app)
      if option =~ /^now$/
        puts
        puts 'option: now  (active fachinfo only)'
        safe_export 'fachinfo_now.yaml' do
          exporter.export_effective_fachinfos
        end
      else
        puts
        puts 'opiton: none (all fachinfo)'
        safe_export 'fachinfo.yaml' do
          exporter.export_fachinfos
        end
      end
    end
    def export_patinfo_yaml
      exporter = YamlExporter.new(@app)
      safe_export 'patinfo.yaml' do
        exporter.export_effective_patinfos
      end
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
    end
    def export_teilbarkeit_csv
      safe_export 'Teilbarkeit Export' do
        today = Date.today
        plug = CsvExportPlugin.new(@app)
        plug.export_teilbarkeit
        if report = plug.report
          log = Log.new(today)
          log.date_str = today.strftime("%d.%m.%Y")
          log.report = report
          file = today.strftime("teilbarkeit.%Y-%m-%d.csv")
          dir = File.expand_path('../../data/csv', File.dirname(__FILE__))
          path = File.join(dir, file)
          log.files = {
            path => ['text/csv', 'UTF-8']
          }
          log.notify('Teilbarkeit Export')
        end
      end
    end
    def export_flickr_photo_csv
      safe_export 'Flickr Ean Export' do
        today = Date.today
        plug = CsvExportPlugin.new(@app)
        plug.export_flickr_photo
        if report = plug.report
          log = Log.new(today)
          log.date_str = today.strftime("%d.%m.%Y")
          log.report = report
          file = today.strftime("flickr_ean_export.%Y-%m-%d.csv")
          dir = File.expand_path('../../data/csv', File.dirname(__FILE__))
          path = File.join(dir, file)
          log.files = {
            path => ['text/csv', 'UTF-8']
          }
          log.notify('Flickr Ean Export')
        end
      end
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
      logExport "safe_export #{subject} starting"
      res = block.call
      logExport "safe_export #{subject} completed"
      res
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
      logExport "safe_export #{subject} failed"
      sleep(30)
    end
	end
end
