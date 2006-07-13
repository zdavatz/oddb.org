#!/usr/bin/env ruby
# ODDB::Invoicer -- ydpm -- 12.12.2005 -- hwyss@ywesee.com

require 'date'
require 'plugin/plugin'
require 'plugin/ydim'
require 'util/oddbconfig'

module ODDB
	class Invoicer < Plugin
		RECIPIENTS = [ 
			'hwyss@ywesee.com', 
			'zdavatz@ywesee.com' 
		]
		def create_invoice(email, items, ydim_id)
			pointer = Persistence::Pointer.new(:invoice)
			values = {
				:yus_name		    =>	email,
				:keep_if_unpaid =>	true,
				:ydim_id				=>	ydim_id,
			}
			ODBA.transaction { 
				invoice = @app.update(pointer.creator, values)
				pointer = invoice.pointer + [:item]
				items.each { |item|
					@app.update(pointer.dup.creator, item.values)
				}
			}
		end
    def ensure_yus_user(comp_or_hosp)
      mail = comp_or_hosp.invoice_email
      @app.yus_create_user(mail)
      @app.yus_grant(mail, 'edit', comp_or_hosp.pointer.to_yus_privilege)
      @app.yus_set_preference(mail, 'association', comp_or_hosp.odba_id)
      mail
    rescue Yus::YusError
      ## assume user exists
      mail
    end
		def resend_invoice(invoice, day = @@today)
			YdimPlugin.new(@app).send_invoice(invoice.ydim_id)
		end
		def rp2fr(price)
			price.to_f / 100.0
		end
		def send_invoice(date, mail, items)
			plugin = YdimPlugin.new(@app)
			ydim_inv = plugin.inject_from_items(date, mail, items)
			ydim_id = ydim_inv.unique_id
			plugin.send_invoice(ydim_id)
			ydim_id
		end
	end
	class CompanyIndexInvoicer < Invoicer
		def run(date = @@today)
			@app.companies.each_value { |comp| 
				invoice_company_index(comp, date)
			}
		end
		def invoice_company_index(comp, date = @@today)
			idate = comp.index_invoice_date
			price = rp2fr(comp.index_price)
			## package_price is stored in Rappen
			package_price = rp2fr(comp.index_package_price)
			package_count = comp.active_package_count
			package_sum = package_price * package_count
			if(date == idate && price > 0)
				time = Time.now
				expiry_time = Time.local(date.year, date.month, date.day)
				base_item = AbstractInvoiceItem.new
				year = date.year
				base_item.text = sprintf('Eintrag Firmenverzeichnis %i/%i', 
																 year, year.next)
				base_item.type = :index
				base_item.unit = 'Jahr'
				base_item.price = price.to_f
				base_item.vat_rate = VAT_RATE
				base_item.time = time
				base_item.expiry_time = expiry_time
				items = [base_item]
				if(package_sum > 0)
					package_item = AbstractInvoiceItem.new
					package_item.type = :index_per_package
					package_item.text = sprintf('Anzahl Produktelinks (%i)', package_count)
					package_item.unit = 'Produkt'
					package_item.quantity = package_count
					package_item.price = package_price
					package_item.vat_rate = VAT_RATE
					package_item.time = time
					package_item.expiry_time = expiry_time
					items.push(package_item)
				end
        mail = ensure_yus_user(comp)
				## first send the invoice 
				ydim_id = send_invoice(date, mail, items) 
				## then store it in the database
				create_invoice(mail, items, ydim_id)
				@app.update(comp.pointer, {:index_invoice_date => (date >> 12)})
			end
		end
	end
	class LookandfeelInvoicer < Invoicer
		def run(date = @@today)
			@app.companies.each_value { |comp| 
				invoice_lookandfeel(comp, date)
			}
		end
		def invoice_lookandfeel(comp, date = @@today)
			idate = comp.lookandfeel_invoice_date
			price = rp2fr(comp.lookandfeel_price)
			## lookandfeel_member_price is stored in Rappen
			member_price = rp2fr(comp.lookandfeel_member_price)
			member_count = comp.lookandfeel_member_count.to_i
			member_sum = member_price * member_count
			if(date == idate && price > 0)
				time = Time.now
				expiry_time = Time.local(date.year, date.month, date.day)
				base_item = AbstractInvoiceItem.new
				base_item.text = case comp.business_area
				when 'ba_info'
					'Grundgebühr Look & Feel Medi-Information'
				when 'ba_insurance'
					'Grundgebühr Krankenkasse'
				else
					'Grundgebühr'
				end
				base_item.type = :lookandfeel
				base_item.unit = 'Jahr'
				base_item.price = price.to_f
				base_item.vat_rate = VAT_RATE
				base_item.time = time
				base_item.expiry_time = expiry_time
				items = [base_item]
				if(member_sum > 0)
					member_item = AbstractInvoiceItem.new
					member_item.type = :lookandfeel_per_member
					member_item.text = 'Anzahl Versicherte'
					member_item.unit = 'Person'
					member_item.quantity = member_count
					member_item.price = member_price
					member_item.vat_rate = VAT_RATE
					member_item.time = time
					member_item.expiry_time = expiry_time
					items.push(member_item)
				end
        mail = ensure_yus_user(comp)
				## first send the invoice 
				ydim_id = send_invoice(date, mail, items) 
				## then store it in the database
				create_invoice(mail, items, ydim_id)
				@app.update(comp.pointer, {:lookandfeel_invoice_date => (date >> 12)})
			end
		end
	end
end
