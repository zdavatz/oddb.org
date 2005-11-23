#!/usr/bin/env ruby
# XlsExportPlugin -- oddb -- 22.11.2005 -- hwyss@ywesee.com

require 'plugin/plugin'

module ODDB
	class XlsExportPlugin < Plugin
		EXPORT_SERVER = DRbObject.new(nil, EXPORT_URI)
		EXPORT_DIR = File.join(ARCHIVE_PATH, 'downloads')
		def export_generics
			ids = @app.registrations.values.inject([]) { |pacs, reg|
				if(reg.active? && reg.original?)
					reg.each_package { |pac|
						if(pac.active? && !pac.comparables.empty?)
							pacs << pac
						end
					}
				end
				pacs
			}.sort.collect { |pac| pac.odba_id }
			EXPORT_SERVER.export_generics_xls(ids, 
				EXPORT_DIR, 'generics.xls')
		end
	end
end
