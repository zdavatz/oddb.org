#!/usr/bin/env ruby
# State::Drugs::PaymentMethod -- oddb -- 05.10.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/drugs/register_download'
require 'view/drugs/payment_method'

module ODDB
	module State
		module Drugs
class PaymentMethod < Global
	VIEW = View::Drugs::PaymentMethod
	attr_reader :search_query, :search_type
	def init
		super
		@search_query = @session.user_input(:search_query)
		@search_type = @session.user_input(:search_type)
		@result = @model
		@model = @session.user.model
	end
	def proceed_payment
		if(creditable? \
			&& @session.user_input(:payment_method) == 'pm_invoice')
			RegisterInvoicedDownload.new(@session, @result)
		else
			RegisterDownload.new(@session, @result)
		end
	end
end
		end
	end
end
