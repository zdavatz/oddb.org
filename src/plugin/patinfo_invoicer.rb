#!/usr/bin/env ruby
# PatinfoInvoicer -- oddb -- 16.08.2005 -- jlang@ywesee.com

require 'plugin/plugin'
require 'pdfinvoice/config'
require 'pdfinvoice/invoice'
require 'util/oddbconfig'
require 'rmail'
require 'date'

module ODDB
	class PatinfoInvoicer < Plugin
		RECIPIENTS = [ 
			'hwyss@ywesee.com', 
			#'zdavatz@ywesee.com',
		]
		def run(day = Date.today)
			send_daily_invoices(day - 1)
			send_annual_invoices(day)
		end
		def send_annual_invoices(day = Date.today)
			items = all_items.select { |item| item.type == :annual_fee }
			groups = group_by_company(items)
			groups.each { |company, items|
				if(!company.disable_autoinvoice && (user = company.user))
					if(company.pref_invoice_date.nil?)
						time = items.collect { |item| item.time }.min
						date = Date.new(time.year, time.month, time.day)
						company.pref_invoice_date = date
						company.odba_store
					end
					if(day == company.pref_invoice_date)
						## adjust the annual fee according to company settings
						adjust_company_fee(company, items)
						## adjust the fee according to date
						adjust_overlap_fee(day, items)
						## first send the invoice 
						send_invoice(day, company, items) 
						## then store it in the database
						create_invoice(user, items)
					elsif((day >> 12) == company.pref_invoice_date)
						## if the date has been sent to one year from now,
						## this invoice has already been sent manually.
						## store the items anyway to prevent sending a 2-year
						## invoice on the following day..
						create_invoice(user, items)
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
					send_invoice(day, company, items) 
					## then store it in the database
					create_invoice(user, items)
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
				active.delete(pdf_name(item))
			}
		end
		def assemble_pdf_invoice(pdfinvoice, day, company, items, email)
			pdfinvoice.invoice_number = day.strftime('Patinfo-Upload-%d.%m.%Y')
			lines = [ company.name, "z.H. #{company.contact}", email ]
			lines += company.address(0).lines
			pdfinvoice.debitor_address = lines
			pdfinvoice.items = items.sort_by { |item| 
				item.text.to_s
			}.collect { |item|
				lines = [item.text, item_name(item)]
				if(data = item.data) 
					first_date = data[:first_valid_date] || item.time
					last_date = data[:last_valid_date]
					days = data[:days]
					if(last_date && days)
						lines.push(sprintf("%s - %s", 
							first_date.strftime("%d.%m.%Y"), last_date.strftime("%d.%m.%Y")))
						lines.push(sprintf("%i Tage", days))
					end
				end
				[ item.time, lines.compact.join("\n"), item.unit, 
					item.quantity.to_f, item.price.to_f ]
			}
			pdfinvoice
		end
		def create_pdf_invoice(day, company, items, email)
			config = PdfInvoice.config
			config.texts['thanks'] = <<-EOS
Ohne Ihre Gegenmeldung erfolgt der Rechnungsversand nur per Email.
Thank you for your patronage
			EOS
			pdfinvoice = PdfInvoice::Invoice.new(config)
			assemble_pdf_invoice(pdfinvoice, day, company, items, email)
		end
		def create_invoice(user, items)
			pointer = Persistence::Pointer.new(:invoice)
			values = {
				:user_pointer		=>	user.pointer,
				:keep_if_unpaid =>	true,
			}
			ODBA.transaction { 
				invoice = @app.update(pointer.creator, values)
				pointer = invoice.pointer + [:item]
				items.each { |item|
					@app.update(pointer.dup.creator, item.values)
				}
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
		def item_name(item)
			name = ''
			if(data = item.data)
				name = data[:name].to_s.strip
			end
			if(name.empty? && (ptr = item.item_pointer))
				name = sequence_name(ptr).to_s.strip
			end
			name unless(name.empty?)
		end
		def pdf_name(item)
			name = item.text
			if(/^[0-9]{5} [0-9]{2}$/.match(name))
				name.tr(' ', '_')
			elsif((ptr = item.item_pointer) && (seq = sequence_resolved(ptr)))
				[seq.iksnr, seq.seqnr].join('_')
			end
		rescue Persistence::UninitializedPathError
		end
		def recent_items(day)
			mday = day.day
			month = day.month
			year = day.year
			all_items.select { |item|
				tim = item.time
				tim.day == mday && tim.month == month && tim.year == year
			}
		end
		def resend_invoice(invoice, day = Date.today)
			if((user = invoice.user_pointer.resolve(@app)) \
				&& (company = user.model))
				items = invoice.items.values
				send_invoice(day, company, items)
			end
		end
		def send_invoice(day, company, items)
			to = company.invoice_email || company.user.unique_email
			invoice = create_pdf_invoice(day, company, items, to)
			invoice_name = sprintf('Patinfo-Upload-%s-%s.pdf', 
				company.name.tr(' ', '_'),
				day.strftime('%d.%m.%Y'))
			invoice_name = "#{invoice.invoice_number}.pdf"
			fpart = RMail::Message.new
			header = fpart.header
			header.to = to
			header.from = MAIL_FROM
			fee_items = items.select { |item| item.type == :annual_fee }
			header.subject = sprintf("Rechnung %i * PI-Upload %s", 
				fee_items.size, day.strftime("%d.%m.%Y"))
			header.add('Content-Type', 'application/pdf')
			header.add('Content-Disposition', 'attachment', nil,
				{'filename' => invoice_name })
			header.add('Content-Transfer-Encoding', 'base64')
			fpart.body = [invoice.to_pdf].pack('m')
			smtp = Net::SMTP.new(SMTP_SERVER)
			recipients = RECIPIENTS.dup#.push(to).uniq
			smtp.start {
				recipients.each { |recipient|
					smtp.sendmail(fpart.to_s, SMTP_FROM, recipient)
				}
			}
		end
		def sequence_name(pointer)
			if(seq = sequence_resolved(pointer))
				seq.name
			end
		end
		def sequence_resolved(pointer)
			pointer.resolve(@app)
		rescue StandardError
		end
	end
end
