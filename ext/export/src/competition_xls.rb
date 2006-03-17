#!/usr/bin/env ruby
# OdbaExporter -- CompetitionXls -- 07.03.2006 -- hwyss@ywesee.com

require 'spreadsheet/excel'
require 'parseexcel/parser'

module ODDB
	module OdbaExporter
		class CompetitionXls
			def initialize(path, db_path)
				@workbook = Spreadsheet::Excel.new(path)
				@fmt_title = Format.new(:bold=>true)
				@workbook.add_format(@fmt_title)
				@fmt_original = Format.new(:color => 'red')
				@workbook.add_format(@fmt_original)
				@fmt_original_name = Format.new(:bold => true, :color => 'red')
				@workbook.add_format(@fmt_original_name)
				@fmt_generic = Format.new(:color => 'green')
				@workbook.add_format(@fmt_generic)
				@fmt_generic_name = Format.new(:bold => true, :color => 'green')
				@workbook.add_format(@fmt_generic_name)
				@worksheet = @workbook.add_worksheet("Generikaliste")
				@worksheet.format_column(0, 16.0, @fmt_original_name)
				@worksheet.format_column(1..4, 8.0, @fmt_original)
				@worksheet.format_column(5, 16.0, @fmt_generic_name)
				@worksheet.format_column(6..10, 8.0, @fmt_generic)
				@worksheet.format_column(11, 16.0, @fmt_generic)
				@worksheet.format_column(12..15, 8.0, @fmt_generic)
				columns = [
					'Name Original', 'Dosis Original', 'Packungsgrösse Original',
					'Fabrikabgabe-preis Original', 
					'Publikums-preis Original (inkl. MwSt)',
					'Name Generikum', 'Dosis Generikum', 'Packungsgrösse Generikum',
					'Fabrikabgabe-preis Generikum', 
					'Publikums-preis Generikum (inkl. MwSt)', 
					'Pharmacode Generikum', 'Hersteller Generikum',
					'Differenz in CHF', 'Differenz in %', 'Bemerkung', 'In SL?',
				]
				@worksheet.write(0, 0, columns, @fmt_title)
				@app = ODBA.cache.fetch_named('oddbapp', nil)
				@rows = 1
				load_price_db(db_path)
			end
			def close
				@workbook.close
			end
			def export_competition(company)
				originals = []
				owns = {}
				@app.each_package { |pac|
					pac = pac.odba_instance
					if(pac.sl_entry && pac.public? && pac.registration.active?)
						if(pac.company == company)
							owns.store(pac.ikskey, pac)
						elsif(pac.sl_generic_type == :original && !pac.comparables.empty?)
							originals.push(pac)
						end
					end
				}
				originals.sort!
				last_export = nil
				originals.each_with_index { |package, idx|
					cheapest = nil
					generics = package.comparables.select { |pac|
						pac.sl_entry && (pac.sl_generic_type == :generic \
														 || pac.company.odba_instance == company)
					}.sort_by { |pac| 
						[price_public(pac), (pac.company == company) ? 1 : 0 ] } 
					if(cheapest = generics.first)
						owns.delete(cheapest.ikskey)
						export_comparable(package, cheapest)
						last_export = package.iksnr
					end
					if((own = generics.find { |pac| 
						pac.company.odba_instance == company }) && own != cheapest)
						owns.delete(own.ikskey)
						export_comparable(package, own)
						last_export = package.iksnr
					end
					unless((nxt = originals.at(idx.next)) && package.iksnr == nxt.iksnr)
						if(last_export == package.iksnr) ## omit phantom exports
							subs = package.substances.sort
							galform = package.galenic_form
							owns.values.select { |pac| 
								pac.galenic_form.equivalent_to?(galform) \
									&& pac.substances.sort == subs
							}.sort.each { |pac|
								unless(pac.comparables.any? { |comp| 
									(comp.sl_generic_type == :original) && comp.sl_entry })
									export_generic(pac)
									owns.delete(pac.ikskey)
								end
							}
						end
					end
				}
				owns.values.sort.each { |package|
					export_generic(package)
				}
				@rows
			end
			def export_comparable(package, comp)
				write_row(format_row(package, comp))
			end
			def export_generic(package)
				write_row(format_generic(package))
			end
			def export_original(package)
				write_row(format_original(package))
			end
			def format_price(price)
				if(price && price > 0.0)
					sprintf("%4.2f", price.to_f / 100.0)
				end
			end
			def format_generic(generic)
				remarks = 'kein passendes original gefunden'
				Array.new(5, '').concat(_format_generic(nil, generic, remarks))
			end
			def _format_generic(orig, gen, remarks)
				ppub = price_public(gen)
				[
					gen.name_base, gen.dose, gen.comparable_size,
					format_price(price_exfactory(gen)),
					format_price(ppub),
					gen.pharmacode, gen.company, 
					(format_price(price_public(orig) - ppub) if(orig)),
					(sprintf("%1.1f%%", price_difference(orig, gen)) if(orig)),
					remarks, (gen.sl_entry) ? 'Ja' : 'Nein',
				].collect { |item| item.to_s }
			end
			def format_original(original)
				_format_original(original)
			end
			def _format_original(original)
				[
					original.name_base, original.dose, original.comparable_size,
					format_price(price_exfactory(original)),
					format_price(price_public(original)),
				].collect { |item| item.to_s }
			end
			def format_row(original, generic)
				remarks = if(original.comparable_size != generic.comparable_size)
										'unterschiedliche Packungsgrösse'
									end
				_format_original(original).concat(_format_generic(original, 
																													generic, remarks))
			end
			def load_price_db(path)
				@exf_pcd_prices = {}
				@pbl_pcd_prices = {}
				@exf_iks_prices = {}
				@pbl_iks_prices = {}
				if(path)
					parser = Spreadsheet::ParseExcel::Parser.new
					workbook = parser.parse(path)
					worksheet = workbook.worksheet(0)
					worksheet.each(1) { |row|
						pcode = row.at(8).to_s
						ikskey = row.at(10).to_s
						efp = (row.at(15).to_f * 100.0).to_i
						pbp = (row.at(16).to_f * 100.0).to_i
						@exf_pcd_prices.store(pcode, efp)
						@exf_iks_prices.store(ikskey, efp)
						@pbl_pcd_prices.store(pcode, pbp)
						@pbl_iks_prices.store(ikskey, pbp)
					}
				end
			end
			def price_difference(original, generic)
				oprice = price_public(original).to_f
				pprice = price_public(generic).to_f
				osize = original.comparable_size.qty.to_f 
				psize = generic.comparable_size.qty.to_f
				unless ( (oprice <= 0) || (pprice <= 0) || (osize <= 0) || (psize <= 0))
					(( (osize * pprice) / (psize * oprice) ) - 1.0).abs * 100.0
				end
			end
			def price_exfactory(package)
				@exf_pcd_prices[package.pharmacode] \
					|| @exf_iks_prices[package.ikskey] || package.price_exfactory
			end
			def price_public(package)
				@pbl_pcd_prices[package.pharmacode] \
					|| @pbl_iks_prices[package.ikskey] || package.price_public
			end
			def write_row(row)
				@worksheet.write(@rows, 0, row)
				@rows += 1
			end
		end
	end
end
