#!/usr/bin/env ruby
# OddbConfig -- oddb -- 09.04.2003 -- hwyss@ywesee.com 

# Do not require any Application-Internals in this file

# Rockit redefines some StringScanner stuff, unless this is set
$USING_STRSCAN = true

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
	READONLY_URI = "druby://localhost:10013"
	CURRENCY_URI = "druby://localhost:10999"
  YUS_URI = "drbssl://localhost:9997"
  YUS_DOMAIN = 'oddb.org'
	PROJECT_ROOT = File.expand_path('../..', File.dirname(__FILE__))
  IMAGE_DIR = File.join(PROJECT_ROOT, 'doc', 'resources', 'images')
	PAYPAL_SERVER = 'www.paypal.com'
	PAYPAL_RECEIVER = 'zdavatz@ywesee.com'
	ENCODING = 'UTF-8'
	## Prices and Durations
  DOWNLOAD_EXPORT_PRICES = {
    'analysis.csv'				=> 300,
    'chde.xls'	          => 600,
    'de.oddb.yaml'				=> 600,
    'doctors.csv'					=> 1900,
    'doctors.yaml'				=> 2100,
    'fachinfos_de.pdf' 		=> 1000,
    'fachinfos_fr.pdf' 		=> 1000,
    'fachinfo.yaml'				=> 800,
    'compendium_ch.oddb.org.firefox.epub' => 17,
    'compendium_ch.oddb.org.htc.prc'      => 17,
    'compendium_ch.oddb.org.kindle.mobi'  => 17,
    'compendium_ch.oddb.org.stanza.epub'  => 17,
    'generics.xls'				=> 150,
    'index_therapeuticus' => 500,
    'interactions.yaml'   => 300,
    'migel.csv'						=> 100,
    'narcotics.csv'				=> 100,
    'narcotics.yaml'			=> 100,
    'oddb.csv'						=> 500,
    'oddb2.csv'						=> 600,
    'oddbdat'							=> 700,
    'oddb.yaml'						=> 600,
    'patents.xls'         => 500,
    'patinfo.yaml'				=> 500,
    'price_history.yaml'  => 1000,
    'price_history.csv'   => 1000,
    's31x'								=> 900,
    'swissdrug-update.xls'=> 150,
  }
  DOWNLOAD_EXPORT_SUBSCRIPTION_PRICES = {
    'chde.xls'	          => 2000,
    'de.oddb.yaml'				=> 2500,
    'fachinfos_de.pdf' 		=> 3000,
    'fachinfos_fr.pdf' 		=> 3000,
    'fachinfo.yaml'				=> 1400,
    'generics.xls'				=> 1700,
    'index_therapeuticus' => 1900,
    'interactions.yaml'   => 1200,
    'narcotics.csv'				=> 1000,
    'narcotics.yaml'			=> 1000,
    'oddb.csv'						=> 2000,
    'oddb2.csv'						=> 2100,
    'oddbdat'							=> 2500,
    'oddb.yaml'						=> 2500,
    'price_history.yaml'  => 2000,
    'price_history.csv'   => 2000,
    's31x'								=> 1400,
    'swissdrug-update.xls'=> 1700,
  }
  DOWNLOAD_EXPORT_DURATIONS = { 
    'analysis.csv'				=> 30,
    'chde.xls'	          => 30,
    'de.oddb.yaml'				=> 30,
    'doctors.csv'					=> 30,
    'doctors.yaml'				=> 30,
    'fachinfo.yaml'				=> 30,
    'fachinfos_de.pdf'		=> 30,
    'fachinfos_fr.pdf'		=> 30,
    'compendium_ch.oddb.org.firefox.epub' => 30,
    'compendium_ch.oddb.org.htc.prc'      => 30,
    'compendium_ch.oddb.org.kindle.mobi'  => 30,
    'compendium_ch.oddb.org.stanza.epub'  => 30,
    'generics.xls'				=> 30,
    'index_therapeuticus' => 30,
    'interactions.yaml'   => 30,
    'migel.csv'						=> 30,
    'narcotics.csv'				=> 30,
    'narcotics.yaml'			=> 30,
    'oddb.csv'						=> 30,
    'oddb2.csv'						=> 30,
    'oddbdat'							=> 30,
    'oddb.yaml'						=> 30,
    'patents.xls'	  			=> 30,
    'patinfo.yaml'				=> 30,
    'price_history.yaml'  => 30,
    'price_history.csv'   => 30,
    's31x'								=> 30,
    'swissdrug-update.xls'=> 30,
  }
  DOWNLOAD_EXPORT_SUBSCRIPTION_DURATIONS = { 
    'chde.xls'	          => 365,
    'de.oddb.yaml'				=> 365,
    'fachinfo.yaml'				=> 365,
    'fachinfos_de.pdf'		=> 365,
    'fachinfos_fr.pdf'		=> 365,
    'generics.xls'				=> 365,
    'index_therapeuticus' => 365,
    'interactions.yaml'		=> 365,
    'narcotics.csv'				=> 365,
    'narcotics.yaml'			=> 365,
    'oddb.csv'						=> 365,
    'oddb2.csv'						=> 365,
    'oddbdat'							=> 365,
    'oddb.yaml'						=> 365,
    'price_history.yaml'  => 365,
    'price_history.csv'   => 365,
    's31x'								=> 365,
    'swissdrug-update.xls'=> 365,
  }
  DOWNLOAD_PROTOCOLS = [ 'stanza' ]
  DOWNLOAD_UNCOMPRESSED = [
    'compendium_ch.oddb.org.firefox.epub',
    'compendium_ch.oddb.org.htc.prc',
    'compendium_ch.oddb.org.kindle.mobi',
    'compendium_ch.oddb.org.stanza.epub',
  ]
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
	end
end
