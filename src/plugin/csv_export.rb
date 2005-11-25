#!/usr/bin/env ruby
# CsvExportPlugin -- oddb -- 26.08.2005 -- hwyss@ywesee.com

require 'plugin/plugin'

module ODDB
	class CsvExportPlugin < Plugin
		EXPORT_SERVER = DRbObject.new(nil, EXPORT_URI)
		EXPORT_DIR = File.join(ARCHIVE_PATH, 'downloads')
		def export_doctors
			ids = @app.doctors.values.collect { |item| item.odba_id }
			EXPORT_SERVER.export_doc_csv(ids, EXPORT_DIR, 'doctors.csv')
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
	end
end
