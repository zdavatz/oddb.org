#!/usr/bin/env ruby
# XlsExportPlugin -- oddb -- 22.11.2005 -- hwyss@ywesee.com

require 'plugin/plugin'

module ODDB
	class XlsExportPlugin < Plugin
		EXPORT_SERVER = DRbObject.new(nil, EXPORT_URI)
		EXPORT_DIR = File.join(ARCHIVE_PATH, 'downloads')
		RECIPIENTS = ['andre.dubied@ksb.ch']
		def export_competition(company, db_path=nil)
			dir = File.join(ARCHIVE_PATH, "xls")
			file = "#{company.name}.Preisvergleich.xls".tr(' ', '_')
			@file_path = File.join(dir, file)
			@recipients = [company.competition_email]
			EXPORT_SERVER.export_competition_xls(company.odba_id, dir, file, db_path)
		end
		def export_generics
			name = 'generics.xls'
			@file_path = File.join(EXPORT_DIR, name)
			EXPORT_SERVER.export_generics_xls(EXPORT_DIR, name)
		end
		def log_info
			hash = super
			if @file_path
				hash.update({
					:files			=> { @file_path => "application/vnd.ms-excel"},
					:recipients => recipients,
				})
			end
			hash
		end
		def report
			@file_path.to_s
		end
	end
end
