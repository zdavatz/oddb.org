#!/usr/bin/env ruby
# OuwerkerkPlugin -- oddb -- 18.06.2003 -- hwyss@ywesee.com 

require 'date'
require 'plugin/plugin'
require 'spreadsheet/excel'

module ODDB
	class OuwerkerkPlugin < Plugin
		RECIPIENTS = [
			#'matthijs.ouwerkerk@just-medical.com',
		]
		NUMERIC_FLAGS = {
			:new							=>	1,
			:del							=>	2,
			:productname			=>	3, 
			:address					=>	4,
			:ikscat						=>	5,
			:composition			=>	6, 
			:indication				=>	7,
			:sequence					=>	8, 
			:expirydate				=>	9,
			:sl_entry					=>	10,
			:price						=>	11,
			:price_exfactory	=>	11, #legacy
			:price_public			=>	11, #legacy
			:comment					=>	12,
		}
		def initialize(app)
			super
			date = Date.today
			@file_name = date.strftime("med-drugs-%Y%m%d.xls")
			@file_path = File.expand_path("xls/#{@file_name}", self::class::ARCHIVE_PATH)
		end
		def export_package(pack, row, pac_flags)
			if(flags = pac_flags[pack.pointer.to_s])
				row[0] += flags
			end
			row[0] = row[0].collect { |flg| 
				self::class::NUMERIC_FLAGS[flg] 
			}.uniq.sort
			row[2] = pack.ikscd
			row[10] = pack.ikscat
			row[13] = pack.size
			if(price = pack.price_exfactory)
				row[16] = price / 100.0
			end
			if(price = pack.price_public)
				row[17] = price / 100.0
			end
			row[23] = pack.pharmacode
			row[24] = (pack.sl_entry.nil?) ? 'keine' : 'SL'
			row
		end
		def export_registration(reg, row, pac_flags)
			rows = []
			row[1] = reg.iksnr
			if(ind = reg.indication)
				row[6] = ind.de
			end
			row[7] = reg.export_flag
			if(company = reg.company)
				row[12] = reg.company.name
				row[19] = reg.company.url
			end
			reg.sequences.each_value { |seq|
				seqrow = row.dup
				rows += export_sequence(seq, seqrow, pac_flags)
			}
			rows
		end
		def export_registrations
			if(lgrp = @app.log_group(:swissmedic_journal))
				@smj = lgrp.latest
			end
			if(lgrp = @app.log_group(:bsv_sl))
				@bsv = lgrp.latest
			end
			registrations = @smj.nil? ? {} : @smj.change_flags
			packages = @bsv.nil? ? {} : @bsv.change_flags

			# Hash-Table lookups fail for p1 == p2, if p1.id != p2.id
			# we can work around that problem using the serialized form p1.to_s
			pointer_table = {}
			reg_flags = {}
			pac_flags = {}
			registrations.each { |pointer, flags| 
				key = pointer.to_s
				pointer_table.store(key, pointer)
				reg_flags.store(key, flags)
			}
			packages.each { |pointer, flags|
				ptr = pointer.parent.parent
				key = ptr.to_s
				reg_flags[key] ||= []
				pointer_table.store(key, ptr)
				pac_flags.store(pointer.to_s, flags)
			}

			rows = []
			reg_flags.each { |ptr_str, flags|
				reg = pointer_table[ptr_str].resolve(@app)
				rows += export_registration(reg, [flags], pac_flags)
			}
			rows.delete_if { |row| row.first.empty? }
			rows.sort_by { |row| 
				[ 
					row.first, 
					row.at(4).to_s, 
					row.at(1).to_i, 
					row.at(3).to_i, 
					row.at(2).to_i 
				] 
			}.collect { |row|
				row[0] = row.first.join(',')
				row
			}
		end
		def export_sequence(seq, row, pac_flags)
			rows = []
			row[3,2] = [
				seq.seqnr,
				seq.name,
			]
			if(dose = seq.dose)
				row[8,2] = [
					dose.qty,
					dose.unit,
				]
			end
			row[11] = seq.active_agents.size
			if(galform = seq.galenic_form)
				row[14] = galform.de
			end
			row[15] = seq.composition_text
			if(atc = seq.atc_class)
				row[21] = atc.code
			end
			seq.packages.each_value { |pack| 
				prow = row.dup
				rows << export_package(pack, prow, pac_flags)
			}
			rows
		end
		def export_xls
			rows = export_registrations
			dir = File.dirname(@file_path)
			Dir.mkdir(dir) unless File.exists?(dir)
			workbook = Spreadsheet::Excel.new(@file_path)
			fmt_title = Format.new(:bold=>true)
			english = Format.new(:bold=>true,:color=>"green")
			german = Format.new(:bold=>true,:color=>"red")
			workbook.add_format(fmt_title)
			workbook.add_format(english)
			workbook.add_format(german)
			worksheet = workbook.add_worksheet("med-drugs update")
			worksheet.write(0, 0, title(), fmt_title)
			en = [ 
				'group', 'IKSNo', 'CD', 'sequence', 'product', 'customization',
				'usage', 'Export', 'dosage', 'unit', 'selling group',
				'No. of active substances', 'company', 'package', 'galenic',
				'composition', 'price exfactory', 'public prize', 'URL product',
				'URL company', 'Position', 'ATC code', 'info', 'pharma code', 'list',
			]
			worksheet.write(1, 0, en, english)
			de = [
				'Kategorie', 'Zul.-Nr.', 'CD', 'SEQNR', 'Präparatename', 'Handelsform',
				'Heilmittelcode', 'Export', 'DOSIS', 'Einheit', 'Abgabe-kategorie',
				'Wirkstoff-anzahl', 'Vertriebsname', 'Packungsgrösse', 'Gal. Form',
				'Zusammensetzung', 'Preis ex fac', 'Preis pub', 'Link Produkt',
				'Link Firma', 'Position', 'ATC Nummer', 'info', 'Pharmacode', 'Liste',
			]
			worksheet.write(2, 0, de, german)
			rows.each_with_index { |row, idx|
				worksheet.write(idx+3, 0, row)
			}
			workbook.close
		end
		def log_info
			hash = super
			if @file_path
				hash.store(:files, { @file_path => "application/vnd.ms-excel"}) 
			end
			hash.store(:date_str, date_str)
			hash
		end
		def title
			@title ||= "med-drugs update #{date_str}"
		end
		alias :report :title
		private
		def date_str
			[
				@smj.date.strftime("Swissmedic %m/%Y"),
				(@bsv.date.strftime("SL %m/%Y") unless @bsv.nil?),
			].compact.join(" - ")
		end
		def merged_flags(*args)
		end
	end
end
