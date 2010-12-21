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
				@fmt_title = Spreadsheet::Format.new(:bold=>true)
				@fmt_original = Spreadsheet::Format.new(:color => 'red')
				@fmt_original_name = Spreadsheet::Format.new(:bold => true, :color => 'red')
				@fmt_generic = Spreadsheet::Format.new(:color => 'green')
				@fmt_generic_name = Spreadsheet::Format.new(:bold => true, :color => 'green')
				@worksheet = @workbook.add_worksheet("Generikaliste")
				@worksheet.format_column(0, 24.0, @fmt_original_name)
				@worksheet.format_column(1..3, 4.0, @fmt_original)
				@worksheet.format_column(4, 24.0, @fmt_original_name)
				@worksheet.format_column(5..12, 4.0, @fmt_original)
				@worksheet.format_column(13..14, 4.0, @fmt_generic)
				@worksheet.format_column(15, 24.0, @fmt_generic_name)
				@worksheet.format_column(16..23, 4.0, @fmt_generic)
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
				@worksheet.write(0, 0, columns, @fmt_title)
				@app = ODBA.cache.fetch_named('oddbapp', nil)
				smj_grp = @app.log_group(:swissmedic_journal)
				smj_log = smj_grp.latest
				@smj_flags = smj_log.change_flags
				bsv_grp = @app.log_group(:bsv_sl)
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
			def export_generic(package)
				row = Array.new(13, '').concat(format_generic(package))\
					.push(_remarks(package, 'Generikum').to_s)
				@worksheet.write(@rows, 0, row)
				@rows += 1
			end
			def export_generics
				originals = []
				generics = []
				comparables = []
				@app.each_package { |pac|
					if(pac.public? && pac.registration.active? && !pac.basename.nil? && pac.comparables.select{|pack| pack.basename.nil?}.empty?)
						if(pac.registration.original? && (comps = pac.comparables) \
							 && !comps.empty?)
							originals.push(pac)
							comparables.concat(comps)
						elsif(pac.registration.generic?)
							generics.push(pac)
						end
					end
				}
                # Check Packages
                # Some packages cannot be compared if package basename is nil
                nilpackages = originals.select{|pac| pac.basename.nil?}.map{|pac| [pac.company_name, pac.barcode]}
                unless nilpackages.empty? 
                  error_message = "Package basename is nil. The package is not comparable.\n\n"
                  error_message << "Package (company, EAN code): " << nilpackages.join(", ") << "\n"
                  raise StandardError, error_message
                end

				originals.sort.each { |pac| export_comparables(pac) }
				@rows += 1 # leave a space in the xls
				(generics - comparables).sort.each { |pac| export_generic(pac) }
				@rows
			end
			def format_original(package)
				preprocess_fields [
					package.basename, 
					sprintf("%s %s/%i", package.basename, 
						package.dose, package.comparable_size),
					package.barcode, package.pharmacode, 
					package.name, package.dose, 
					package.comparable_size, 
					format_price(package.price_exfactory),
					format_price(package.price_public), package.company_name,
					package.ikscat, (package.sl_entry ? 'SL' : nil),
					package.registration_date,
				]
			end
			def format_generic(comparable)
				preprocess_fields [
					comparable.barcode, comparable.pharmacode,
					comparable.name, comparable.dose, 
					comparable.comparable_size, 
					format_price(comparable.price_exfactory),
					format_price(comparable.price_public), 
					comparable.company_name,
					comparable.ikscat, (comparable.sl_entry ? 'SL' : nil),
					comparable.registration_date,
				]
			end
			def format_price(price)
				if(price && price > 0.0)
					sprintf("%4.2f", price.to_f)
				end
			end
			def format_row(package, comparable)
				fields = format_original(package).concat(format_generic(comparable))
				fields.push(remarks(package, comparable))
			end
			def preprocess_fields(fields)
				fields.collect { |item| 
					(item.is_a?(Date)) ? item.strftime('%d.%m.%Y') : item.to_s }
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
