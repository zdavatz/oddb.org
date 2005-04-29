#!/usr/bin/env ruby
# State::Drugs::RegisterDownload -- ODDB -- 28.04.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/paypal/checkout'
require 'view/drugs/register_download'

module ODDB
	module State
		module Drugs
class RegisterDownload < Global
	include State::PayPal::Checkout
	VIEW = View::Drugs::RegisterDownload
	attr_reader :search_query, :search_type
	def init
		@search_query = @session.user_input(:search_query)
		@search_type = @session.user_input(:search_type)
		item = AbstractInvoiceItem.new
		stype = ['(', @session.lookandfeel.lookup(@search_type), ')'].join
		item.text = [@search_query, stype].join('_') << ".csv"
		item.data = {
			:search_query => @search_query,
			:search_type	=> @search_type,
		}
		item.vat_rate = VAT_RATE
		item.total_netto = 3.5
		pointer = Persistence::Pointer.new(:invoice)
		@model = Persistence::CreateItem.new(pointer)
		@model.carry(:items, [item])
	end
end
		end
	end
end
