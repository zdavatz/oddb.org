#!/usr/bin/env ruby
# OdbaExporter -- CompetitionXls -- 07.03.2006 -- hwyss@ywesee.com

require 'spreadsheet/excel'

module ODDB
	module OdbaExporter
		class CompetitionXls
			def initialize(path)
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
				@rows = 1
			end
			def close
				@workbook.close
			end
			def export_competition(packages)
				packages.inject([]) { |sortable, package|
					comps = package.comparables.reject { |pac| 
						pac.price_exfactory.to_i == 0 
					}.sort_by { |pac| 
						pac.price_exfactory
					}
					origs, others = comps.partition { |pac| pac.registration.original? }
					generics = [package]
					if((cheapest = others.first) \
						 && cheapest.price_exfactory <= package.price_exfactory)
						generics.push(cheapest)
					end
					origs.each { |original|
						sortable.push([original, generics])
					}
					sortable
				}.sort.each { |original, generics|
					generics.each { |generic|
						export_comparable(original, generic)
					}
				}
				@rows
			end
			def export_comparable(package, comp)
				row = format_row(package, comp)
				@worksheet.write(@rows, 0, row)
				@rows += 1
			end
			def format_price(price)
				if(price && price > 0.0)
					sprintf("%4.2f", price.to_f / 100.0)
				end
			end
			def format_row(original, generic)
				remarks = if(original.comparable_size != generic.comparable_size)
										'unterschiedliche Packungsgrösse'
									end
				[
					original.basename, original.dose, original.comparable_size,
					format_price(original.price_exfactory),
					format_price(original.price_public),
					generic.basename, generic.dose, generic.comparable_size,
					format_price(generic.price_exfactory),
					format_price(generic.price_public),
					generic.pharmacode, generic.company, 
					format_price(original.price_public - generic.price_public),
					sprintf("%1.1f%%", price_difference(original, generic)),
					remarks, (generic.sl_entry) ? 'Ja' : 'Nein',
				].collect { |item| item.to_s }
			end
			def price_difference(original, generic)
				oprice = original.price_public.to_f
				pprice = generic.price_public.to_f
				osize = original.comparable_size.qty.to_f 
				psize = generic.comparable_size.qty.to_f
				unless ( (oprice <= 0) || (pprice <= 0) || (osize <= 0) || (psize <= 0))
					(( (osize * pprice) / (psize * oprice) ) - 1.0).abs * 100.0
				end
			end
		end
	end
end
