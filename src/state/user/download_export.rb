#!/usr/bin/env ruby
# encoding: utf-8
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
	## Number of Days during which a paid file may be downloaded
	def DownloadExport.duration(file)
		DOWNLOAD_EXPORT_DURATIONS[fuzzy_key(file)].to_i
	end
	def DownloadExport.fuzzy_key(file)
		DOWNLOAD_EXPORT_PRICES.each_key { |key|
			if(file.index(key))
				return key
			end
		}
		nil
	end
	def DownloadExport.price(file)
		DOWNLOAD_EXPORT_PRICES[fuzzy_key(file)].to_f
	end
	def DownloadExport.subscription_duration(file)
		DOWNLOAD_EXPORT_SUBSCRIPTION_DURATIONS[fuzzy_key(file)].to_i
	end
	def DownloadExport.subscription_price(file)
		DOWNLOAD_EXPORT_SUBSCRIPTION_PRICES[fuzzy_key(file)].to_f
	end
end
		end
	end
end
