#!/usr/bin/env ruby
# Exporter -- oddb -- 30.07.2003 -- hwyss@ywesee.com 

require 'plugin/oddbdat_export'
require 'plugin/fipdf'
require 'plugin/yaml'
require 'util/log'
require 'util/logfile'

module ODDB
	class Exporter
		EXPORT_SERVER = DRbObject.new(nil, EXPORT_URI)
		def initialize(app)
			@app = app
		end
		def run
			run_on_weekday(0) { 
				mail_download_stats
				mail_feedback_stats
				mail_notification_stats
			}
			export_yaml
			export_oddbdat
			EXPORT_SERVER.clear
		rescue StandardError => e
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
		def export_oddbdat
			exporter = OdbaExporter::OddbDatExport.new(@app)
			exporter.export
			run_on_weekday(1) {
				exporter.export_fachinfos
			}
		end
		def export_yaml
			exporter = YamlExporter.new(@app)
			exporter.export
			exporter.export_atc_classes
			run_on_weekday(2) {
				exporter.export_fachinfos
			}
			run_on_weekday(3) {
				exporter.export_patinfos
			}
		end
		def export_pdf
			FiPDFExporter.new(@app).run
		end
		def mail_download_stats
			mail_stats('download')
		end
		def mail_feedback_stats
			mail_stats('feedback')
		end
		def mail_notification_stats
			file = @app.notification_logger.create_csv(@app)
			headers = {
				:filename => 'notifications.csv',
				:mime_type => 'text/csv',
				:subject => 'CSV-Export der Notifications', 
			}
			Log.new(Date.today).notify_attachment(file, headers)
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
		def run_on_weekday(day, &block)
			if(Date.today.wday == day)
				block.call
			end
		end
	end
end
