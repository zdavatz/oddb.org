#!/usr/bin/ruby
# encoding: utf-8
# ODDB::Swissindex::SwissindexPharma -- 06.05.2011 -- mhatakeyama@ywesee.com

require 'rubygems'
require 'savon'
require 'mechanize'
require 'drb'


module ODDB
  module Swissindex
    def Swissindex.session(type = SwissindexPharma)
      yield(type.new)
    end

class SwissindexNonpharma
  URI = 'druby://localhost:50002'
  include DRb::DRbUndumped
  def initialize
    Savon.configure do |config|
        config.log = false            # disable logging
        config.log_level = :info      # changing the log level
    end
    @base_url   = 'https://prod.ws.e-mediat.net/wv_getMigel/wv_getMigel.aspx?Lang=DE&Query=Pharmacode='
  end
  def search_item(pharmacode, lang = 'DE')
    client = Savon::Client.new do | wsdl, http |
      wsdl.document = "https://index.ws.e-mediat.net/Swissindex/NonPharma/ws_NonPharma_V101.asmx?WSDL"
    end
    try_time = 3
    begin
      response = client.request :get_by_pharmacode do
        soap.xml = '<?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
              <pharmacode xmlns="http://swissindex.e-mediat.net/SwissindexNonPharma_out_V101">' + pharmacode + '</pharmacode>
              <lang xmlns="http://swissindex.e-mediat.net/SwissindexNonPharma_out_V101">' + lang + '</lang>
          </soap:Body>
        </soap:Envelope>'
      end
      if nonpharma = response.to_hash[:nonpharma]
        return nonpharma[:item]
      else
        return nil
      end

    rescue StandardError => err
      if try_time > 0
        puts err
        puts err.backtrace
        puts
        puts "retry"
        sleep 10
        try_time -= 1
        retry
      else
        puts " - #{server} is not responding"
        puts err
        puts err.backtrace
        puts
        return nil
      end
    end
  end
  def search_migel(pharmacode)
    agent = Mechanize.new
    try_time = 3
    begin
      agent.get(@base_url + pharmacode)
      count = 100
      line = []
      agent.page.search('td').each_with_index do |td, i|
        text = td.inner_text.chomp.strip
        if text.is_a?(String) && text.length == 7 && text == pharmacode
          count = 0
        end
        if count < 7
          text = text.split(/\n/)[1] || text.split(/\n/)[0]
          text = text.gsub(/\302\240/, '').strip if text
          line << text
          count += 1
        end
      end
      line
    rescue => err
      if try_time > 0
        puts err
        puts err.backtrace
        puts
        puts "retry"
        sleep 10
        agent = Mechanize.new
        try_time -= 1
        retry
      else
        return []
      end
    end
  end
  def search_migel_position_number(pharmacode)
    agent = Mechanize.new
    try_time = 3
    begin
      agent.get(@base_url + pharmacode)
      pos_num = nil
      agent.page.search('td').each_with_index do |td, i|
        if i == 6
          pos_num = td.inner_text.chomp.strip
          break
        end
      end
      return pos_num
    rescue => err
      if try_time > 3
        puts err
        puts err.backtrace
        puts
        puts "retry"
        sleep 10
        agent = Mechanize.new
        try_time -= 1
        retry
      else
        return nil
      end
    end
  end
end


class SwissindexPharma
  URI = 'druby://localhost:50001'
  include DRb::DRbUndumped
  def initialize
    Savon.configure do |config|
        config.log = false            # disable logging
        config.log_level = :info      # changing the log level
    end
  end
  def search_item(eancode, lang = 'DE')
    client = Savon::Client.new do | wsdl, http |
      wsdl.document = "https://index.ws.e-mediat.net/Swissindex/Pharma/ws_Pharma_V101.asmx?WSDL"
    end
    try_time = 3
    begin
      response = client.request :get_by_gtin do
      soap.xml = '<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <GTIN xmlns="http://swissindex.e-mediat.net/SwissindexPharma_out_V101">' + eancode + '</GTIN>
          <lang xmlns="http://swissindex.e-mediat.net/SwissindexPharma_out_V101">' + lang    + '</lang>
        </soap:Body>
      </soap:Envelope>'
      end
      if pharma = response.to_hash[:pharma] 
        return pharma[:item]
      else
        return nil
      end

    rescue StandardError => err
      if try_time > 0
        puts err
        puts err.backtrace
        puts
        puts "retry"
        sleep 10
        try_time -= 1
        retry
      else
        puts " - #{server} is not responding"
        puts err
        puts err.backtrace
        puts
        return nil
      end
    end
  end
end

  end # Swissindex
end # ODDB
