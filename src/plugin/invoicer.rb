#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Invoicer -- ydpm -- 27.06.2011 -- mhatakeyama@ywesee.com
# ODDB::Invoicer -- ydpm -- 12.12.2005 -- hwyss@ywesee.com

require 'date'
require 'plugin/plugin'
require 'plugin/ydim'
require 'util/oddbconfig'

module ODDB
	class Invoicer < Plugin
		RECIPIENTS = [ 
			'mhatakeyama@ywesee.com', 
			'zdavatz@ywesee.com' 
		]
		def create_invoice(email, items, ydim_id)
			pointer = Persistence::Pointer.new(:invoice)
			values = {
				:yus_name		    =>	email,
				:keep_if_unpaid =>	true,
				:ydim_id				=>	ydim_id,
			}
      invoice = @app.update(pointer.creator, values)
      pointer = invoice.pointer + [:item]
      items.each { |item|
        @app.update(pointer.dup.creator, item.values)
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
		def send_invoice(date, mail, items, service_date=date)
			plugin = YdimPlugin.new(@app)
			ydim_inv = plugin.inject_from_items(date, mail, items, 'CHF', service_date)
			ydim_id = ydim_inv.unique_id
			plugin.send_invoice(ydim_id)
			ydim_id
    rescue StandardError => e
			log = Log.new(@@today)
			log.report = [
        "Invoicer#send_invoice(#{date}, #{mail}, #{items.join(',')}, #{service_date})",
				"Error: #{e.class}",
				"Message: #{e.message}",
				"Backtrace:",
				e.backtrace.join("\n"),
			].join("\n")
			#log.notify("Error Invoice: #{subject}")
			log.notify("Error Invoice: ")
      nil
		end
	end
end
