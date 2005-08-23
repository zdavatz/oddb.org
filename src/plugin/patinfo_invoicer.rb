#!/usr/bin/env ruby
# Plugin::PatinfoInvoicer -- oddb -- 16.08.2005 -- jlang@ywesee.com

require 'plugin/plugin'
require 'pdfinvoice/config'
require 'pdfinvoice/invoice'
require 'rmail'
require 'date'

module ODDB
	class PatinfoInvoicer < Plugin
		RECIPIENTS = [ 
			'hwyss@ywesee.com', 
			'zdavatz@ywesee.com' 
		]
		def run(day = Date.today - 1)
			items = recent_items(day)
			payable_items = filter_paid(items)
			groups = group_by_company(payable_items)
			groups.each { |company, items|
				if(user = company.user)
					## first send the invoice 
					send_invoice(day, company, items) 
					## then store it in the database
					create_invoice(user, items)
				end
			}
			nil
		end
		def assemble_pdf_invoice(pdfinvoice, day, company, items)
			pdfinvoice.invoice_number = day.strftime('Patinfo-Upload-%d.%m.%Y')
			lines = [ company.name, "z.H. #{company.contact}" ]
			lines += company.address(0).lines
			pdfinvoice.debitor_address = lines
			pdfinvoice.items = items.collect { |item|
				[ day, item.text, item.unit, 
					item.quantity.to_i, item.price.to_f ]
			}
			pdfinvoice
		end
		def create_pdf_invoice(day, company, items)
			pdfinvoice = PdfInvoice::Invoice.new(PdfInvoice.config)
			assemble_pdf_invoice(pdfinvoice, day, company, items)
		end
		def create_invoice(user, items)
			pointer = Persistence::Pointer.new(:invoice)
			values = {
				:user_pointer	=>	user.pointer,
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
			# :annual_fee hat und den selben model_pointer wie item

			items = items.sort_by { |item| item.time }

			## Vorgeschlagener Algorithmus
			# 1. alle invoices von app
			# 2. davon alle items, die nicht expired? und den 
			#    typ :annual_fee haben
			# 3. davon den item_pointer
			# 4. -> neue Collection pointers
			fee_pointers = []
			prc_pointers = []
			@app.invoices.each_value { |invoice|
				invoice.items.each_value { |item|
					if(item.type == :annual_fee && !item.expired?)
						fee_pointers.push(item.item_pointer)
					elsif(item.type == :processing && !item.expired?)
						prc_pointers.push(item.item_pointer)
					end
				}
			}
			fee_pointers.uniq!
			prc_pointers.uniq!
			
			# 5. Duplikate löschen
			result = []
			items.each { |item| 
				ptr = item.item_pointer
				if(item.type == :annual_fee && !fee_pointers.include?(ptr))
					fee_pointers.push(ptr)
					result.push(item)
				elsif(item.type == :processing && !prc_pointers.include?(ptr))
					prc_pointers.push(ptr)
					result.push(item)
				end
			}
			result
		end
		def group_by_company(items)
			companies = {}
			items.each { |item| 
				ptr = item.item_pointer
				seq = ptr.resolve(@app)
				(companies[seq.company] ||= []).push(item)
			}
			companies
		end
		def recent_items(day)
			slate = @app.slate(:patinfo)
			all_items = slate.items.values
			time_start = Time.local(day.year, day.month, day.day)
			time_end = time_start + (24 * 60 * 60)
			range = time_start...time_end
			all_items.select { |item|
				range.include?(item.time)
			}
		end
		def send_invoice(day, company, items)
			to = company.contact_email
			invoice = create_pdf_invoice(day, company, items)
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
			smtp = Net::SMTP.new('localhost')
			recipients = RECIPIENTS.dup.push(to).uniq
			smtp.start {
				recipients.each { |recipient|
					smtp.sendmail(fpart.to_s, SMTP_FROM, recipient)
				}
			}
		end
		def transmogrify_items
			root_ptr = Persistence::Pointer.new([:user, 0])
			slate = @app.slate(:patinfo)
			items = []
			slate.items.each_value { |item|
				if(item.type.nil?)
					item.unit = 'Jahresgebühr'
					item.type = :annual_fee
					item.price = 120
					item.duration = 365
					item.expiry_time = InvoiceItem.expiry_time(365, item.time)
					item.vat_rate = VAT_RATE
					item.odba_store
					items.push(item)
					if(item.user_pointer == root_ptr)
						fee = item.dup
						fee.unit = 'Bearbeitung'
						fee.type = :processing
						fee.price = 90
						items.push(fee)
					end
				end
			}
			payable_items = filter_paid(items)
			groups = group_by_company(payable_items)
			groups.each { |company, items|
				if(user = company.user)
					create_invoice(user, items)
				end
			}
			nil
		end
	end
end
