#!/usr/bin/env ruby
# Invoice -- oddb -- 08.10.2004 -- mwalder@ywesee.com, rwaltert@ywesee.com 
require 'util/persistence'

module ODDB
	class Invoice
		include Persistence
		attr_reader :items
		def initialize(invoice_name)
			@name = invoice_name
			@items = {}
		end
		def create_item
			item = InvoiceItem.new
			@items.store(item.oid, item)
		end
		def item(oid)
			@items[oid]
		end
	end
	class InvoiceItem 
		include Persistence
		attr_accessor :user_pointer, :time, :item_pointer
		def init(app)
			super(app)
			@pointer.append(@oid)
		end
	end
end
