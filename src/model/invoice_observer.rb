#!/usr/bin/env ruby

# InvoiceObserver -- oddb -- 03.08.2005 -- hwyss@ywesee.com

module ODDB
  module InvoiceObserver
    attr_accessor :salutation, :name, :name_first, :fullname, :address,
      :location, :plz
    def add_invoice(invoice)
      invoices.push(invoice)
      @invoices.odba_isolated_store
      invoice.user_pointer = @pointer
      invoice.odba_isolated_store
      invoice
    end

    def contact
      [@name_first, @name].compact.join(" ")
    end

    def invoice(oid)
      oid = oid.to_i
      invoices.find { |invoice|
        invoice.oid == oid
      }
    end

    def invoice_email
      email
    end

    def remove_invoice(invoice)
      if invoices.delete(invoice)
        @invoices.odba_isolated_store
        invoice
      end
    end

    def invoices
      if @invoices.nil?
        @invoices = []
        odba_store
      end
      @invoices
    end
  end
end
