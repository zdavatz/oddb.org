#!/usr/bin/env ruby
# State::PayPal::Return -- ODDB -- 21.04.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/paypal/return'
require 'delegate'

module ODDB
	module State
		module PayPal
class Return < State::Global
	class InvoiceWrapper < SimpleDelegator
		attr_accessor :items
	end
	class ItemWrapper < SimpleDelegator
		attr_accessor :email, :oid
	end
	VIEW = View::PayPal::Return
	def init
		if((id = @session.user_input(:invoice)) \
			&& (invoice = @session.invoice(id)))
			@model = InvoiceWrapper.new(invoice)
			user = @session.resolve(invoice.user_pointer)
			@model.items = invoice.items.values.collect { |item|
				wrap = ItemWrapper.new(item)
				wrap.email = user.email
				wrap.oid = invoice.oid
				wrap
			}
		else
			@model = nil
		end
		super
	end
	def back
		@previous.previous if(@previous.respond_to?(:previous))
	end
end
		end
	end
end
