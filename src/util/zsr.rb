#!/usr/bin/env ruby
# encoding: utf-8

require 'savon'

module ODDB
  module ZSR
    ZSRService = 'https://www.pharmedsolutions.ch/ZSRService/wsdl'
    def ZSR.info(zsr_id)
      return {} unless zsr_id and zsr_id.length > 6
      client = Savon.client(wsdl: ZSRService)
      # using zsr__id as zsr_id gets camel-cased -> zsrId in the sent request
      response = client.call(:get_information, message: {zsr__id: zsr_id} )
      response.body[:information]
    rescue => e
      return {}
    end
  end
end
