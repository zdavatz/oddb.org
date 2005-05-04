#!/usr/bin/env ruby
# Invoice -- oddb -- 08.10.2004 -- mwalder@ywesee.com, rwaltert@ywesee.com 
require 'util/persistence'

module ODDB
	class Invoice
		include Persistence
		attr_reader :items
		attr_accessor :user_pointer
		def initialize
			super
			@items = {}
			@payment_received = false
		end
		def init(app)
			@pointer.append(@oid)
		end
		def item_by_text(text)
			@items.values.each { |item|
				return item if(item.text == text)
			}
			nil
		end
		def create_item
			item = InvoiceItem.new
			@items.store(item.oid, item)
		end
		def expired?
			@items.values.all? { |item| item.expired? }
		end
		def item(oid)
			@items[oid]
		end
		def total_brutto
			@items.values.inject(0) { |inj, item| inj + item.total_brutto }
		end
		def total_netto
			@items.values.inject(0) { |inj, item| inj + item.total_netto }
		end
		def payment_received!
			@payment_received = true
		end
		def payment_received?
			@payment_received
		end
		def vat
			@items.values.inject(0) { |inj, item| inj + item.vat }
		end
	end
	class AbstractInvoiceItem
		attr_accessor :user_pointer, :time, :item_pointer, #:name
			:text, :quantity, :price, :expiry_time, :vat_rate, :duration
		attr_accessor :data
		def initialize
			@quantity = 1.0
			@duration = 1
			@data = {}
		end
		def total_brutto
			total_netto * (1.0 + (@vat_rate.to_f / 100.0))
		end
		def total_brutto=(total)
			self.total_netto = (total / (1.0 + (@vat_rate.to_f / 100.0)))
		end
		def total_netto
			@quantity.to_f * @price.to_f
		end
		def total_netto=(total)
			@price = total.to_f / @quantity.to_f
		end
		def to_s
			@text.to_s
		end
		def vat
			total_netto * @vat_rate.to_f / 100.0
		end
	end
	class InvoiceItem < AbstractInvoiceItem
		include Persistence
		ODBA_SERIALIZABLE = ['@data']
		def InvoiceItem.expiry_time(duration, time)
			time + (duration * 24 * 60 * 60)
		end
		def initialize
			super
			@quantity = 1
		end
		def expired?
			@time.nil? || @expiry_time.nil? || Time.now > @expiry_time
		end
		def init(app)
			@pointer.append(@oid)
		end
	end
end
