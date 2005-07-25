#!/usr/bin/env ruby
# State::User::DownloadExport -- oddb -- 20.09.2004 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'state/user/checkout'
require 'view/user/download_export'
require 'model/invoice'

module ODDB
	module State
		module User
class DownloadExport < State::User::Global
	VIEW = View::User::DownloadExport
	DIRECT_EVENT = :download_export
	PRICES = {
		'doctors.yaml'	=> 500,
		'oddb.yaml'			=> 600,
		'fachinfo.yaml'	=> 800,
		'patinfo.yaml'	=> 500,
		'oddbdat'				=> 700,
		's31x'					=> 900,
	}
	SUBSCRIPTION_PRICES = {
		'oddb.yaml'			=> 2500,
		'fachinfo.yaml'	=> 1400,
		'oddbdat'				=> 2500,
		's31x'					=> 1400,
	}
	## Number of Days during which a paid file may be downloaded
	DURATIONS = { 
		'doctors.yaml'	=> 30,
		'oddb.yaml'			=> 30,
		'fachinfo.yaml'	=> 30,
		'patinfo.yaml'	=> 30,
		'oddbdat'				=> 30,
		's31x'					=> 30,
	}
	SUBSCRIPTION_DURATIONS = { 
		'oddb.yaml'			=> 365,
		'fachinfo.yaml'	=> 365,
		'oddbdat'				=> 365,
		's31x'					=> 365,
	}
	def DownloadExport.duration(file)
		DURATIONS[fuzzy_key(file)].to_i
	end
	def DownloadExport.fuzzy_key(file)
		PRICES.keys.select { |key|
			file.index(key)
		}.first
	end
	def DownloadExport.price(file)
		PRICES[fuzzy_key(file)].to_f
	end
	def DownloadExport.subscription_duration(file)
		SUBSCRIPTION_DURATIONS[fuzzy_key(file)].to_i
	end
	def DownloadExport.subscription_price(file)
		SUBSCRIPTION_PRICES[fuzzy_key(file)].to_f
	end
	def proceed
		keys = [:download, :months]
		input = user_input(keys, keys) 
		items = []
		if(files = input[:download])
			files.each { |filename, val|
				if(val)
					item = AbstractInvoiceItem.new
					item.text = filename
					item.vat_rate = VAT_RATE
					months = input[:months][filename]
					item.quantity = months.to_f
					price_mth = 'price'
					duration_mth = 'duration'
					if(months == '12')
						price_mth = 'subscription_' << price_mth
						duration_mth = 'subscription_' << duration_mth
					end
					item.total_netto = DownloadExport.send(price_mth, filename)
					item.duration = DownloadExport.send(duration_mth, filename)
					items.push(item)
				end
			}
		end
		if(items.empty?)
			@errors.store(:download, create_error('e_no_download_selected', 
				:download, nil))
			return self
		end
		pointer = Persistence::Pointer.new(:invoice)
		invoice = Persistence::CreateItem.new(pointer)
		invoice.carry(:items, items)
		RegisterDownload.new(@session, invoice)
	end
end
		end
	end
end
