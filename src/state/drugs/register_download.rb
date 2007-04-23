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
	CURRENCY = 'EUR'
	attr_reader :search_query, :search_type
	def RegisterDownload.price(package_count)
		count = package_count.to_i
		if(count <= 0)
			0
		else
			3.5 + [(count / 100.0).ceil - 1 , 0].max
		end
	end
	def init
		@search_query = @session.user_input(:search_query)
		@search_type = @session.user_input(:search_type) || 'st_oddb'
		package_count = @model.atc_classes.inject(0) { |inj, atc|
			inj + atc.package_count
		}
		item = AbstractInvoiceItem.new
		stype = @session.lookandfeel.lookup(@search_type)
		item.text = [@search_query, stype, 'csv'].join('.')
		item.type = :csv_export
		item.data = {
			:search_query => @search_query,
			:search_type	=> @search_type,
		}
		item.unit = 'Download'
		item.vat_rate = VAT_RATE
		item.total_netto = self.class.price(package_count)
		pointer = Persistence::Pointer.new(:invoice)
		@model = Persistence::CreateItem.new(pointer)
		@model.carry(:items, [item])
		@model.carry(:currency, currency)
    user = @session.user
		if(user.creditable?('org.oddb.download'))
			@model.carry(:yus_name, user.name)
			@model.carry(:email, user.name)
		end
	end
end
class RegisterInvoicedDownload < RegisterDownload
	VIEW = View::Drugs::RegisterInvoicedDownload
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
				app = @session.app
				item = @model.items.first
				slate_ptr = Persistence::Pointer.new([:slate, :download])
				slate = app.create(slate_ptr)
				item_ptr = slate_ptr + [:item]
				values = item.values
				values.store(:yus_name, @session.user.name)
				values.store(:time, Time.now)
				@paid = app.update(item_ptr.creator, values, unique_email)
			end
			State::User::Download.new(@session, @paid)
		end
	end
end
		end
	end
end
