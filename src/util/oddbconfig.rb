#!/usr/bin/env ruby
# OddbConfig -- oddb -- 09.04.2003 -- hwyss@ywesee.com 

# Do not require any Application-Internals in this file

module ODDB
	SERVER_NAME = 'ch.oddb.org'
	SMTP_SERVER = 'mail.ywesee.com'
	MAIL_FROM = '"Zeno R.R. Davatz" <zdavatz@ywesee.com>'
	MAIL_TO = ['hwyss@ywesee.com']
	SMTP_FROM = 'zdavatz@ywesee.com'
	SERVER_URI = "druby://localhost:10000"
	FIPARSE_URI = "druby://localhost:10002"
	FIPDF_URI = "druby://localhost:10003"
	DOCPARSE_URI = "druby://localhost:10004"
	EXPORT_URI = "druby://localhost:10005"
	MEDDATA_URI = "druby://localhost:10006"
	SWISSREG_URI = "druby://localhost:10007"
	COMARKETING_URI = "druby://localhost:10008"
	## holidaymanager: "druby://localhost:10009"
	## xmlconv2: "druby://localhost:10010"
	ANALYSISPARSE_URI = "druby://localhost:10011"
	## globopharm.xmlconv.bbmb.ch: "druby://localhost:10012"
	CURRENCY_URI = "druby://localhost:10999"
  YUS_URI = "drbssl://localhost:9997"
  YUS_DOMAIN = 'oddb.org'
	PROJECT_ROOT = File.expand_path('../..', File.dirname(__FILE__))
	PAYPAL_SERVER = 'www.paypal.com'
	PAYPAL_RECEIVER = 'zdavatz@ywesee.com'
	ENCODING = 'latin1'
	## Prices and Durations
	DOWNLOAD_EXPORT_PRICES = {
		'analysis.csv'				=> 300,
		'doctors.csv'					=> 1900,
		'doctors.yaml'				=> 2100,
		'fachinfo.yaml'				=> 800,
		'generics.xls'				=> 150,
		'swissdrug-update.xls'=> 150,
		'migel.csv'						=> 100,
		'narcotics.csv'				=> 100,
		'narcotics.yaml'			=> 100,
		'oddb.csv'						=> 500,
		'oddbdat'							=> 700,
		'oddb.yaml'						=> 600,
		'patinfo.yaml'				=> 500,
		's31x'								=> 900,
	}
	DOWNLOAD_EXPORT_SUBSCRIPTION_PRICES = {
		'fachinfo.yaml'				=> 1400,
		'generics.xls'				=> 1700,
		'swissdrug-update.xls'=> 1700,
		'narcotics.csv'				=> 1000,
		'narcotics.yaml'			=> 1000,
		'oddb.csv'						=> 2000,
		'oddbdat'							=> 2500,
		'oddb.yaml'						=> 2500,
		's31x'								=> 1400,
	}
	DOWNLOAD_EXPORT_DURATIONS = { 
		'analysis.csv'				=> 30,
		'doctors.csv'					=> 30,
		'doctors.yaml'				=> 30,
		'fachinfo.yaml'				=> 30,
		'generics.xls'				=> 30,
		'swissdrug-update.xls'=> 30,
		'migel.csv'						=> 30,
		'narcotics.csv'				=> 30,
		'narcotics.yaml'			=> 30,
		'oddb.csv'						=> 30,
		'oddbdat'							=> 30,
		'oddb.yaml'						=> 30,
		'patinfo.yaml'				=> 30,
		's31x'								=> 30,
	}
	DOWNLOAD_EXPORT_SUBSCRIPTION_DURATIONS = { 
		'fachinfo.yaml'				=> 365,
		'generics.xls'				=> 365,
		'swissdrug-update.xls'=> 365,
		'narcotics.csv'				=> 365,
		'narcotics.yaml'			=> 365,
		'oddb.csv'						=> 365,
		'oddbdat'							=> 365,
		'oddb.yaml'						=> 365,
		's31x'								=> 365,
	}
	FI_UPLOAD_PRICES = {
		:activation => 1500,
		:annual_fee => 350,
		:processing => 150,
	}
	FI_UPLOAD_DURATION = 365
	PI_UPLOAD_DURATION = 365
	PI_UPLOAD_PRICES = {
		:activation => 1000,
		:annual_fee => 120,
		:processing => 90,
	}
	QUERY_LIMIT_PRICES = {
		1		=>	5,
		30	=>	50,
		365	=>	400,
	}
	VAT_RATE = 7.6
  RSS_PATH = File.join(PROJECT_ROOT, 'data', 'rss')
end

module ODBA
	class Cache
		MAIL_FROM = 'odba@oddb.org'
		MAIL_RECIPIENTS = [
			"hwyss@ywesee.com",
		]
		SMTP_SERVER = ::ODDB::SMTP_SERVER
		CLEANING_INTERVAL = 120
		CLEANER_PRIORITY = -1
	end
end
