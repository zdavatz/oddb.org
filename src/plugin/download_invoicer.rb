#!/usr/bin/env ruby
# Plugin::DownloadInvoicer -- oddb -- 27.09.2005 -- hwyss@ywesee.com

require 'plugin/invoicer'

module ODDB
	class DownloadInvoicer < Invoicer
		def run(month = (@@today - 1))
			items = recent_items(month)
			unless(items.empty?)
				payable_items = filter_paid(items)
				groups = group_by_user(payable_items)
				groups.each { |email, items|
					## first send the invoice 
					ydim_id = send_invoice(month, email, items) 
					## then store it in the database
					create_invoice(email, items, ydim_id)
				}
			end
			nil
		end
		def filter_paid(items)
			items = items.sort_by { |item| item.time }

			range = items.first.time..items.last.time

			## Vorgeschlagener Algorithmus
			# 1. alle invoices von app
			# 2. davon alle items die den typ :csv_export haben und im
			#    Zeitraum range liegen
			# 3. Annahme: item.time ist Eineindeutig
			times = []
			@app.invoices.each_value { |invoice|
				invoice.items.each_value { |item|
					if(item.type == :csv_export && range.include?(item.time))
						times.push(item.time)
					end
				}
			}
			
			# 5. Duplikate löschen
			result = []
			items.delete_if { |item| 
				times.include?(item.time)
			}
			items
		end
		def group_by_user(items)
			items.inject({}) { |groups, item|
				(groups[item.yus_name] ||= []).push(item)
				groups
			}
		end
		def recent_items(date)
			slate = @app.slate(:download)
			all_items = slate.items.values
			time_start = Time.local(date.year, date.month)
			date_end = date >> 1
			time_end = Time.local(date_end.year, date_end.month)
			range = time_start...time_end
			all_items.select { |item|
				range.include?(item.time)
			}
		end
	end
end
