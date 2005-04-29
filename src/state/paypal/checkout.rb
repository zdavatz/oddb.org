#!/usr/bin/env ruby
# State::PayPal::Checkout -- ODDB -- 28.04.2005 -- hwyss@ywesee.com

require 'state/paypal/redirect'
require 'model/invoice'

module ODDB
	module State
		module PayPal
module Checkout
	def checkout
		input = user_input(checkout_keys(), checkout_mandatory)
		if(error?)
			self
		else
			input.each { |key, val| @session.set_cookie_input(key, val) }
			email = input.delete(:email)
			#@session.set_cookie_input(:email, email)
			ODBA.transaction { 
				pointer = Persistence::Pointer.new([:admin_subsystem], 
					[:download_user, email])
				user = @session.app.update(pointer.creator, input)
				pointer = Persistence::Pointer.new([:invoice])
				invoice = @session.app.create(pointer)
				@model.items.each { |abstract|
					item_ptr = pointer + [:item]
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
						:data					=> abstract.data,
						:vat_rate			=> VAT_RATE,
					}
					item = @session.app.update(item_ptr.creator, data)
				}
				user.add_invoice(invoice)
				State::PayPal::Redirect.new(@session, invoice)
			}
		end
	end
	def checkout_mandatory
		[ :salutation, :name, :name_first, :email ]
	end
	def checkout_keys
		checkout_mandatory()
	end
end
		end
	end
end
