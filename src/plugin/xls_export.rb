#!/usr/bin/env ruby
# XlsExportPlugin -- oddb -- 22.11.2005 -- hwyss@ywesee.com

require 'plugin/plugin'

module ODDB
	class XlsExportPlugin < Plugin
		EXPORT_SERVER = DRbObject.new(nil, EXPORT_URI)
		EXPORT_DIR = File.join(ARCHIVE_PATH, 'downloads')
		def export_competition(company)
			ids = public_package_ids(company.registrations)
			dir = File.join(ARCHIVE_PATH, "xls")
			file = "#{company.name}.Preisvergleich.xls".tr(' ', '_')
			@file_path = File.join(dir, file)
			@recipient = company.competition_email
			EXPORT_SERVER.export_competition_xls(ids, dir, file)
		end
		def export_generics
			#regs = @app.registrations.values.select { |reg| reg.original? }
			#ids = public_package_ids(regs)
			EXPORT_SERVER.export_generics_xls(EXPORT_DIR, 'generics.xls')
		end
		def public_package_ids(registrations)
			registrations.inject([]) { |pacs, reg|
				if(reg.active?)
					reg.each_package { |pac|
						if(pac.public? && !pac.comparables.empty?)
							pacs << pac
						end
					}
				end
				pacs
			}.sort.collect { |pac| pac.odba_id }
		end
		def log_info
			hash = super
			if @file_path
				hash.update({
					:files			=> { @file_path => "application/vnd.ms-excel"},
					:recipients => [@recipient],
				})
			end
			hash
		end
		def report
			@file_path.to_s
		end
	end
end
