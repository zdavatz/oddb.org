#!/usr/bin/env ruby
# InvoiceObserver -- oddb -- 03.08.2005 -- hwyss@ywesee.com

module ODDB
	module InvoiceObserver
		attr_accessor :salutation, :name, :name_first, :address, 
			:location, :plz
		def add_invoice(invoice)
			self.invoices.push(invoice)
			@invoices.odba_isolated_store
			invoice.user_pointer = @pointer
			invoice.odba_isolated_store
			invoice
		end
		def invoice(oid)
			oid = oid.to_i
			self.invoices.each { |invoice|
				return invoice if(invoice.oid == oid)
			}
			nil
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
	end
end
