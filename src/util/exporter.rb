#!/usr/bin/env ruby
# Exporter -- oddb -- 30.07.2003 -- hwyss@ywesee.com 

require 'plugin/oddbdat_export'
require 'plugin/fipdf'
require 'plugin/yaml'
require 'util/log'
require 'util/logfile'

module ODDB
	class Exporter
		def initialize(app)
			@app = app
		end
		def run
			mail_download_stats
			mail_feedback_stats
			export_yaml
			GC.start
			export_oddbdat
			GC.start
		end
		def export_oddbdat
			OddbDatExport.new(@app).run
		end
		def export_yaml
			YamlExporter.new(@app).run
		end
		def export_pdf
			FiPDFExporter.new(@app).run
		end
		def mail_download_stats
			run_on_weekday(0) { 
				mail_stats('download')
			}
		end
		def mail_feedback_stats
			run_on_weekday(0) { 
				mail_stats('feedback')
			}
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
