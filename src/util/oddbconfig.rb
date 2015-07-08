#!/usr/bin/env ruby
# encoding: utf-8
# OddbConfig -- oddb.org -- 17.08.2012 -- yasaka@ywesee.com
# OddbConfig -- oddb.org -- 11.01.2012 -- mhatakeyama@ywesee.com 
# OddbConfig -- oddb.org -- 09.04.2003 -- hwyss@ywesee.com 

# Do not require any Application-Internals in this file

# Rockit redefines some StringScanner stuff, unless this is set
$USING_STRSCAN = true
require 'config'

module ODDB
	SERVER_NAME = 'ch.oddb.org'
	SERVER_URI = "druby://localhost:10000"
	SERVER_URI_FOR_CRAWLER = "druby://localhost:10001"
	SERVER_URI_FOR_GOOGLE_CRAWLER = "druby://localhost:10008"
	FIPARSE_URI = "druby://localhost:10002"
	FIPDF_URI = "druby://localhost:10003"
	DOCPARSE_URI = "druby://localhost:10004"
	EXPORT_URI = "druby://localhost:10005"
	MEDDATA_URI = "druby://localhost:10006"
	SWISSREG_URI = "druby://localhost:10007"
	READONLY_URI = "druby://localhost:10013"
	CURRENCY_URI = "druby://localhost:10999"
  YUS_URI = "drbssl://localhost:9997"
  MIGEL_URI = 'druby://localhost:33000'
  YUS_DOMAIN = 'oddb.org'
	PROJECT_ROOT = File.expand_path('../..', File.dirname(__FILE__))
  IMAGE_DIR = File.join(PROJECT_ROOT, 'doc', 'resources', 'images')
	PAYPAL_SERVER   = ODDB.config.paypal_server
	PAYPAL_RECEIVER = ODDB.config.paypal_receiver
  
	ENCODING = 'UTF-8'
	## Prices and Durations
  DOWNLOAD_EXPORT_PRICES = {
    'analysis.csv'				=> 300,
    'chde.xls'	          => 600,
    'de.oddb.yaml'				=> 600,
    'doctors.csv'					=> 1900,
    'doctors.yaml'				=> 2100,
    'generics.xls'				=> 150,
    'index_therapeuticus' => 500,
    'migel.csv'						=> 100,
    'narcotics.csv'				=> 100,
    'narcotics.yaml'			=> 100,
    'oddb.csv'						=> 500,
    'oddb2.csv'						=> 600,
    'oddb.yaml'						=> 600,
    'oddb.dat'            => 50,
    'oddb_with_migel.dat' => 80,
    'patents.xls'         => 500,
    'price_history.yaml'  => 1000,
    'price_history.csv'   => 1000,
    'swissdrug-update.xls'=> 150,
  }
  DOWNLOAD_EXPORT_SUBSCRIPTION_PRICES = {
    'chde.xls'	          => 2000,
    'de.oddb.yaml'				=> 2500,
    'fachinfo.yaml'				=> 2400,
    'generics.xls'				=> 1700,
    'index_therapeuticus' => 1900,
    'narcotics.csv'				=> 1000,
    'narcotics.yaml'			=> 1000,
    'oddb.csv'						=> 2000,
    'oddb2.csv'						=> 2100,
    'oddb.yaml'						=> 2500,
    'price_history.yaml'  => 2000,
    'price_history.csv'   => 2000,
    'swissdrug-update.xls'=> 1700,
  }
  DOWNLOAD_EXPORT_DURATIONS = { 
    'analysis.csv'				=> 30,
    'chde.xls'	          => 30,
    'de.oddb.yaml'				=> 30,
    'doctors.csv'					=> 30,
    'doctors.yaml'				=> 30,
    'generics.xls'				=> 30,
    'index_therapeuticus' => 30,
    'migel.csv'						=> 30,
    'narcotics.csv'				=> 30,
    'narcotics.yaml'			=> 30,
    'oddb.csv'						=> 30,
    'oddb2.csv'						=> 30,
    'oddb.yaml'						=> 30,
    'patents.xls'	  			=> 30,
    'patinfo.yaml'				=> 30,
    'price_history.yaml'  => 30,
    'price_history.csv'   => 30,
    'swissdrug-update.xls'=> 30,
  }
  DOWNLOAD_EXPORT_SUBSCRIPTION_DURATIONS = { 
    'chde.xls'	          => 365,
    'de.oddb.yaml'				=> 365,
    'generics.xls'				=> 365,
    'index_therapeuticus' => 365,
    'narcotics.csv'				=> 365,
    'narcotics.yaml'			=> 365,
    'oddb.csv'						=> 365,
    'oddb2.csv'						=> 365,
    'oddb.yaml'						=> 365,
    'price_history.yaml'  => 365,
    'price_history.csv'   => 365,
    'swissdrug-update.xls'=> 365,
  }
  DOWNLOAD_PROTOCOLS = [ 'stanza' ]
  DOWNLOAD_UNCOMPRESSED = [
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
	VAT_RATE = 8.0
  RSS_PATH = File.join(PROJECT_ROOT, 'data', 'rss')
end
