#!/usr/bin/env ruby
# OdbaExporter::GenericXls -- oddb -- 22.11.2005 -- hwyss@ywesee.com

require 'util/oddbapp'
require 'util/loggroup'
require 'util/log'
require 'spreadsheet/excel'

module ODDB
	module OdbaExporter
		class GenericXls
			FLAGS = {
				:address					=> 'neue Herstelleradresse',
				:comment					=> 'neue Bemerkung',
				:composition			=> 'veränderte Zusammensetzung',
				:delete						=> 'Registration läuft aus',
				:expirydate				=> 'Registration verlängert',
				:ikscat						=> 'neue Abgabekategorie',
				:indication				=> 'neue Indikation',
				:new							=> 'neue Registration',
				:price_rise				=> 'Preiserhöhung',
				:price_cut				=> 'Preissenkung',
				:productname			=> 'neue Produktbezeichnung',
				:sequence					=> 'veränderte Handelsform',
				:sl_entry_delete	=> 'aus SL gelöscht',
				:sl_entry					=> 'neu in SL',
			}
			def initialize(path)
				@workbook = Spreadsheet::Excel.new(path)
				fmt_default = Format.new(:bg_color => 0x7FFF)
				@workbook.instance_variable_set('@format', fmt_default)
				fmt_title = Format.new(:bold=>true, :bg_color => 0x7FFF)
				@workbook.add_format(fmt_title)
				@worksheet = @workbook.add_worksheet("Generikaliste")
				columns = [
					'Basename Original', 'Basename Original erweitert',
					'EAN-Code Original', 'Pharmacode  Original', 
					'Bezeichnung Original', 'Dosierung Original', 
					'Packungsgrösse Original', 'Fabrikabgabe-preis Original', 
					'Publikums-preis Original (inkl. MwSt)', 
					'Zulassungsinhaberin', 'Kat.', 'SL', 'Reg.Dat.', 
					'EAN-Code Generikum', 'Pharmacode Generikum',
					'Bezeichnung Generikum', 'Dosierung Generikum',
					'Packungsgrösse Generikum', 'Fabrikabgabe-preis Generikum',
					'Publikums-preis Generikum (inkl. MwSt)',
					'Zulassungsinhaberin', 'Kat.', 'SL', 'Reg.Dat.', 'Bemerkung',
				]
				@worksheet.write(0, 0, columns, fmt_title)
				app = ODBA.cache.fetch_named('oddbapp', nil)
				smj_grp = app.log_group(:swissmedic_journal)
				smj_log = smj_grp.latest
				@smj_flags = smj_log.change_flags
				bsv_grp = app.log_group(:bsv_sl)
				bsv_log = bsv_grp.latest
				@bsv_flags = bsv_log.change_flags
				@rows = 1
			end
			def close
				@workbook.close
			end
			def export_comparable(package, comp)
				row = format_row(package, comp)
				@worksheet.write(@rows, 0, row)
				@rows += 1
			end
			def export_comparables(package)
				package.comparables.sort.each { |comp| 
					if(comp.registration.generic?)
						export_comparable(package, comp)
					end
				}
				@rows
			end
			def format_price(price)
				if(price && price > 0.0)
					sprintf("%4.2f", price.to_f / 100.0)
				end
			end
			def format_row(package, comparable)
				[
					package.basename, 
					sprintf("%s %s/%i", package.basename, 
						package.dose, package.comparable_size),
					package.barcode.to_s, package.pharmacode, 
					package.name, package.dose, 
					package.comparable_size, 
					format_price(package.price_exfactory),
					format_price(package.price_public), package.company_name,
					package.ikscat, (package.sl_entry ? 'SL' : nil),
					package.registration_date,
					comparable.barcode, comparable.pharmacode,
					comparable.name, comparable.dose, 
					comparable.comparable_size, 
					format_price(comparable.price_exfactory),
					format_price(comparable.price_public), 
					comparable.company_name,
					comparable.ikscat, (comparable.sl_entry ? 'SL' : nil),
					comparable.registration_date, remarks(package, comparable)
				].collect { |item| item.to_s }
			end
			def remarks(package, comparable)
				[
					_remarks(package, 'Original'),
					_remarks(comparable, 'Generikum'),
				].compact.join(' ')
			end
			def _remarks(package, title)
				flags = []
				if(smj_flags = @smj_flags[package.registration.pointer])
					flags += smj_flags
				end
				if(bsv_flags = @bsv_flags[package.pointer])
					flags += bsv_flags
				end
				unless(flags.empty?)
					'' << title << ': ' << flags.collect { |flag|
						FLAGS[flag]
					}.join(', ')
				end
			end
		end
	end
end
