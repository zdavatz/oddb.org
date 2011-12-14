#!/usr/bin/env ruby
# encoding: utf-8
# InvoiceObserver -- oddb -- 03.08.2005 -- hwyss@ywesee.com

module ODDB
	module InvoiceObserver
		attr_accessor :salutation, :name, :name_first, :fullname, :address, 
			:location, :plz, :ydim_id
		def add_invoice(invoice)
			self.invoices.push(invoice)
			@invoices.odba_isolated_store
			invoice.user_pointer = @pointer
			invoice.odba_isolated_store
			invoice
		end
		def contact
			[@name_first, @name].compact.join(' ')
		end
		def invoice(oid)
			oid = oid.to_i
			self.invoices.find { |invoice|
        invoice.oid == oid
			}
		end
		def invoice_email
			self.email
		end
		def remove_invoice(invoice)
			if(self.invoices.delete(invoice))
				@invoices.odba_isolated_store
				invoice
			end
		end
		def invoices
			if(@invoices.nil?)
				@invoices = []
				odba_store
			end
			@invoices
		end
		def ydim_address_lines
			[@address].compact
		end
		def ydim_location
			[@plz, @location].compact.join(' ')
		end
	end
end
