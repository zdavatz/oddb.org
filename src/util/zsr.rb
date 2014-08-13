#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Validator -- oddb.org -- 29.10.2012 -- yasaka@ywesee.com
# ODDB::Validator -- oddb.org -- 14.02.2012 -- mhatakeyama@ywesee.com
# ODDB::Validator -- oddb.org -- 18.11.2002 -- hwyss@ywesee.com

require 'savon'

module ODDB
	module ZSR
    ZSRService = 'https://www.pharmedsolutions.ch/ZSRService/wsdl'
		def ZSR.info(zsr_id)
      $stdout.puts "ZSR.info for #{zsr_id.inspect}"
      return {} unless zsr_id and zsr_id.length > 6
      Savon.configure do |config|
        config.log       = false # disable logging
        config.log_level = :error # changing the log level
      end
      client = Savon::Client.new do | wsdl, http |
        wsdl.document = ZSRService
      end
      response = client.request :getInformationParameters do
          soap.xml = %(<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
xmlns:tns="https://www.pharmedsolutions.ch/ZSRService"
xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"
xmlns:xsd="http://www.w3.org/2001/XMLSchema"
xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"
xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >
<SOAP-ENV:Body><mns1:getInformationParameters
xmlns:mns1="https://www.pharmedsolutions.ch/ZSRService">
<zsr_id>#{zsr_id}</zsr_id>
</mns1:getInformationParameters></SOAP-ENV:Body></SOAP-ENV:Envelope>
)
      end
      response.to_hash[:information]
		end
	end
end
