#!/usr/bin/env ruby
# State::User::RegisterDownload -- oddb -- 22.12.2004 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/paypal/checkout'
require 'state/paypal/return'
require 'view/user/register_download'

module ODDB
	module State
		module User
class RegisterDownload < Global
	include State::PayPal::Checkout
	VIEW = View::User::RegisterDownload
	def checkout_keys
		checkout_mandatory() + [:business_area, :company_name]
	end
	def checkout_mandatory
		super + [ :address, :plz, :city, :phone ]
	end
end
=begin # experimental Implementation of Invoiced Download. 
class RegisterInvoicedDownload < RegisterDownload
	VIEW = View::User::RegisterInvoicedDownload
	def RegisterInvoicedDownload.price(package_count)
		count = package_count.to_i
		if(count <= 0)
			0
		else
			5 + ([(count / 100.0).ceil - 1 , 0].max * 1.5)
		end
	end
	CURRENCY = 'CHF'
	def checkout
		if(creditable?('org.oddb.download'))
			if(@paid.nil?)
        @paid = {}
				app = @session.app
				slate_ptr = Persistence::Pointer.new([:slate, :download])
				slate = app.create(slate_ptr)
        @model.items.each_with_index { |item, idx|
          time = Time.now
          expiry = InvoiceItem.expiry_time(item.duration, time)
          item_ptr = slate_ptr + [:item]
          values = item.values
          values.store(:yus_name, @session.user.name)
          values.store(:time, time)
          values.store(:expiry_time, expiry)
          stored = app.update(item_ptr.creator, values, unique_email)
          puts stored.inspect
          @paid.store(idx, stored)
        }
			end
      inv = @model.dup
      inv.carry(:items, @paid)
      inv.carry(:types, [:download])
      inv.carry(:payment_received?, true) # satisfy check in PayPal::Return
			State::PayPal::Return.new(@session, inv)
		end
	end
end
=end
		end
	end
end
