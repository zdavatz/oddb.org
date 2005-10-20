#!/usr/bin/env ruby
# Plugin::DownloadInvoicer -- oddb -- 27.09.2005 -- hwyss@ywesee.com

require 'plugin/patinfo_invoicer'

module ODDB
	class DownloadInvoicer < Plugin
		RECIPIENTS = [ 
			'hwyss@ywesee.com', 
			'zdavatz@ywesee.com' 
		]
		def run(month = (Date.today - 1))
			items = recent_items(month)
			payable_items = filter_paid(items)
			groups = group_by_user(payable_items)
			groups.each { |pointer, items|
				if((user = pointer.resolve(@app)) && (hospital = user.model))
					## first send the invoice 
					send_invoice(month, hospital, items) 
					## then store it in the database
					create_invoice(user, items)
				end
			}
			nil
		end
		def assemble_pdf_invoice(pdfinvoice, day, hospital, items, email)
			pdfinvoice.invoice_number = day.strftime('Downloads-%m.%Y')
			addr = hospital.address(0)
			lines = [ hospital.name, "z.H. #{addr.name}", email ]
			lines += addr.lines_without_title
			pdfinvoice.debitor_address = lines
			pdfinvoice.items = items.collect { |item|
				[ item.time, item.text, 'Download', 
					item.quantity.to_i, item.price.to_f ]
			}
			pdfinvoice
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
		def create_pdf_invoice(day, hospital, items, email)
			config = PdfInvoice.config
			config.texts['thanks'] = <<-EOS
Ohne Ihre Gegenmeldung erfolgt der Rechnungsversand nur per Email.
Thank you for your patronage
			EOS
			pdfinvoice = PdfInvoice::Invoice.new(config)
			assemble_pdf_invoice(pdfinvoice, day, hospital, items, email)
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
				(groups[item.user_pointer] ||= []).push(item)
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
		def send_invoice(date, hospital, items)
			to = hospital.user.unique_email
			invoice = create_pdf_invoice(date, hospital, items, to)
			invoice_name = sprintf('CSV-Downloads-%s-%s.pdf', 
				hospital.name.tr(' ', '_'),
				date.strftime('%m.%Y'))
			invoice_name = "#{invoice.invoice_number}.pdf"
			fpart = RMail::Message.new
			header = fpart.header
			header.to = to
			header.from = MAIL_FROM
			header.subject = sprintf("Rechnung %i * CSV-Download %s", 
				items.size, date.strftime("%m/%Y"))
			header.add('Content-Type', 'application/pdf')
			header.add('Content-Disposition', 'attachment', nil,
				{'filename' => invoice_name })
			header.add('Content-Transfer-Encoding', 'base64')
			fpart.body = [invoice.to_pdf].pack('m')
			smtp = Net::SMTP.new(SMTP_SERVER)
			recipients = RECIPIENTS.dup.push(to).uniq
			smtp.start {
				recipients.each { |recipient|
					smtp.sendmail(fpart.to_s, SMTP_FROM, recipient)
				}
			}
		end
	end
end
