#!/usr/bin/env ruby
# State::PayPal::Checkout -- ODDB -- 28.04.2005 -- hwyss@ywesee.com

require 'state/paypal/redirect'
require 'model/invoice'

module ODDB
	module State
		module PayPal
module Checkout
	CURRENCY = 'EUR'
	def checkout
		input = user_input(checkout_keys(), checkout_mandatory)
		if(error?)
			self
		else
			ODBA.transaction { 
				user = create_user(input)
				invoice = create_invoice(input)
				user.add_invoice(invoice)
				State::PayPal::Redirect.new(@session, invoice)
			}
		end
	rescue SBSM::ProcessingError => err
		@errors.store(err.key, err)
		self
	end
	def checkout_mandatory
		[ :salutation, :name, :name_first, :email ]
	end
	def checkout_keys
		checkout_mandatory()
	end
	def create_invoice(input)
		pointer = Persistence::Pointer.new([:invoice])
		invoice = @session.app.update(pointer.creator, {:currency => currency})
		@model.items.each { |abstract|
			item_ptr = invoice.pointer + [:item]
			time = Time.now
			file = abstract.text
			duration = abstract.duration
			expiry = InvoiceItem.expiry_time(duration, time)
			data = {
				:duration			=> duration,
				:expiry_time	=> expiry,
				:price				=> abstract.price,
				:quantity			=> abstract.quantity,
				:text					=> file,
				:time					=> time,
				:type					=> abstract.type,
				:data					=> abstract.data,
				:vat_rate			=> VAT_RATE,
			}
			item = @session.app.update(item_ptr.creator, data)
		}
		invoice
	end
	def create_user(input)
		input.each { |key, val| @session.set_cookie_input(key, val) }
		pointer = Persistence::Pointer.new([:admin_subsystem], 
			[:download_user, input[:email]])
		@session.app.update(pointer.creator, input)
	end
	def currency
		self.class.const_get(:CURRENCY)
	end
	def user_input(keys, mandatory)
		input = super
		msg = 'e_need_all_input'
		@errors.each { |key, err|
			if(err.message.match(/^e_missing_/))
				@errors.store(key, create_error(msg, key, err.value))
			end
		}
		input
	end
end
		end
	end
end
