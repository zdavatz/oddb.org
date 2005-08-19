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
		'doctors.yaml'	=> 1100,
		'oddb.csv'			=> 500,
		'oddb.yaml'			=> 600,
		'fachinfo.yaml'	=> 800,
		'patinfo.yaml'	=> 500,
		'oddbdat'				=> 700,
		's31x'					=> 900,
	}
	SUBSCRIPTION_PRICES = {
		'oddb.csv'			=> 2000,
		'oddb.yaml'			=> 2500,
		'fachinfo.yaml'	=> 1400,
		'oddbdat'				=> 2500,
		's31x'					=> 1400,
	}
	## Number of Days during which a paid file may be downloaded
	DURATIONS = { 
		'oddb.csv'			=> 30,
		'doctors.yaml'	=> 30,
		'oddb.yaml'			=> 30,
		'fachinfo.yaml'	=> 30,
		'patinfo.yaml'	=> 30,
		'oddbdat'				=> 30,
		's31x'					=> 30,
	}
	SUBSCRIPTION_DURATIONS = { 
		'oddb.csv'			=> 365,
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
end
		end
	end
end
