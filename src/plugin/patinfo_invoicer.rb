#!/usr/bin/env ruby
# PatinfoInvoicer -- oddb -- 16.08.2005 -- jlang@ywesee.com

require 'plugin/invoicer'

module ODDB
	class PatinfoInvoicer < Invoicer
		SECONDS_IN_DAY = 60*60*24
		attr_accessor :invoice_number
		def run(day = Date.today)
			send_daily_invoices(day - 1)
			send_annual_invoices(day)
		end
		def send_annual_invoices(day = Date.today)
			items = all_items.select { |item| item.type == :annual_fee }
			groups = group_by_company(items)
			groups.each { |company, items|
				## if autoinvoice is disabled, but a preferred invoice_date is set, 
				## invoice-start and -end-dates should be adjusted to that date.
				if(company.disable_autoinvoice)
					if(date = company.pref_invoice_date)
						if(date == day)
							date = company.pref_invoice_date = date + 1
							company.odba_store
						end
						time = Time.local(date.year, date.month, date.day)
						items.each { |item|
							if(item.respond_to?(:odba_store))
								item.expiry_time = time
								item.odba_store
							end
						}
					end
				elsif(user = company.user)
					if(company.pref_invoice_date.nil?)
						time = items.collect { |item| item.time }.min
						date = Date.new(time.year, time.month, time.day)
						company.pref_invoice_date = date
						company.odba_store
					end
					if(day == company.pref_invoice_date)
						## work with duplicates
						items = items.collect { |item| item.dup }
						## adjust the annual fee according to company settings
						adjust_company_fee(company, items)
						## adjust the fee according to date
						adjust_overlap_fee(day, items)
						## first send the invoice 
						ydim_id = send_invoice(day, company, items) 
						## then store it in the database
						create_invoice(user, items, ydim_id)
					elsif((day >> 12) == company.pref_invoice_date)
						## if the date has been set to one year from now,
						## this invoice has already been sent manually.
						## store the items anyway to prevent sending a 2-year
						## invoice on the following day..
						create_invoice(user, items, nil)
					end
				end
			}
		end
		def send_daily_invoices(day)
			items = recent_items(day)
			payable_items = filter_paid(items)
			groups = group_by_company(payable_items)
			groups.each { |company, items|
				if(!company.disable_autoinvoice && (user = company.user))
					## work with duplicates
					items = items.collect { |item| item.dup }
					## adjust the annual fee according to company settings
					adjust_company_fee(company, items)
					## adjust the annual fee according to date
					adjust_annual_fee(company, items)
					## first send the invoice 
					ydim_id = send_invoice(day, company, items) 
					## then store it in the database
					create_invoice(user, items, ydim_id)
				end
			}
			nil
		end
		def adjust_annual_fee(company, items)
			if(date = company.pref_invoice_date)
				diy = (date - (date << 12)).to_f
				items.each { |item|
					if(item.type == :annual_fee)
						tim = item.time
						days = (date - Date.new(tim.year, tim.month, tim.day)).to_f
						factor = days/diy
						item.data ||= {}
						item.data.update({:last_valid_date => date, :days => days})
						item.quantity = factor
					end
				}
			end
		end
		def adjust_company_fee(company, items)
			price = company.patinfo_price.to_i
			if(price > 0)
				items.each { |item|
					if(item.type == :annual_fee)
						item.price = price
					end
				}
			end
		end
		def adjust_overlap_fee(date, items)
			date_end = (date >> 12)
			diy = (date_end - date).to_f
			items.each { |item|
				days = diy
				date_start = date
				if(tim = item.expiry_time)
					valid = Date.new(tim.year, tim.month, tim.day)
					if(valid > date_start)
						date_start = valid
						days = (date_end - valid).to_f
						factor = days/diy
						item.quantity = factor
					end
				end
				item.data ||= {}
				item.data.update({
					:days => days,
					:first_valid_date => date_start, 
					:last_valid_date => date_end,
				})
			}
		end
		def all_items
			active = @app.active_pdf_patinfos.keys.inject({}) { |inj, key|
				inj.store(key[0,8], 1)
				inj
			}
			## all items for which the product still exists 
			@app.slate(:patinfo).items.values.sort_by { |item|
				item.time
			}.reverse.select { |item| 
				# but only once per sequence.
				(item.type == :processing) || active.delete(pdf_name(item))
			}
		end
		def filter_paid(items)
			## Prinzipielles Vorgehen
			# Für jedes item in items:
			# Gibt es ein Invoice, welches nicht expired? ist 
			# und welches ein Item beinhaltet, das den typ 
			# :annual_fee hat und den selben pdf_name wie item

			items = items.sort_by { |item| item.time }

			## Vorgeschlagener Algorithmus
			# 1. alle invoices von app
			# 2. davon alle items, die nicht expired? und den 
			#    typ :annual_fee haben
			# 3. davon den pdf_name
			# 4. -> neue Collection pointers
			fee_names = []
			prc_names = []
			@app.invoices.each_value { |invoice|
				invoice.items.each_value { |item|
					if(name = pdf_name(item))
						if(item.type == :annual_fee && !item.expired?)
							fee_names.push(name)
						elsif(item.type == :processing && !item.expired?)
							prc_names.push(name)
						end
					end
				}
			}
			fee_names.uniq!
			prc_names.uniq!
			
			# 5. Duplikate löschen
			result = []
			items.each { |item| 
				if(name = pdf_name(item))
					if(item.type == :annual_fee && !fee_names.include?(name))
						fee_names.push(name)
						result.push(item)
					elsif(item.type == :processing && !prc_names.include?(name))
						prc_names.push(name)
						result.push(item)
					end
				end
			}
			result
		end
		def group_by_company(items)
			active_companies = []
			@app.invoices.each_value { |inv|
				inv.items.each_value { |item|
					if(item.type == :annual_fee && (ptr = item.item_pointer) \
						&& (seq = sequence_resolved(ptr)) && (company = seq.company))
						active_companies.push(company.odba_instance)
					end
				}
			}
			active_companies.uniq!
			companies = {}
			items.each { |item| 
				ptr = item.item_pointer
				if(seq = sequence_resolved(ptr))
					(companies[seq.company.odba_instance] ||= []).push(item)
				end
			}
			price = PI_UPLOAD_PRICES[:activation]
			companies.each { |company, items|
				time = items.collect { |item| item.time }.min
				unless(active_companies.include?(company))
					item = AbstractInvoiceItem.new
					item.price = price
					item.text = 'Aufschaltgebühr'
					item.time = time
					item.type = :activation
					item.unit = 'Einmalig'
					item.vat_rate = VAT_RATE
					items.unshift(item)
				end
			}
			companies
		end
		def recent_items(day) # also takes a range of Dates
			fd = nil
			ld = nil
			if(day.is_a?(Range))
				fd = day.first
				ld = day.last.next
			else
				fd = day
				ld = day.next
			end
			ft = Time.local(fd.year, fd.month, fd.mday)
			lt = Time.local(ld.year, ld.month, ld.mday)
			range = ft...lt
			all_items.select { |item|
				range.include?(item.time)
			}
		end
=begin
		def sort_items(items)
			items.sort_by { |item| 
				[item.time.to_i / SECONDS_IN_DAY, item.text.to_s, item.type.to_s]
			}
		end
=end
	end
end
