#!/usr/bin/ruby
# encoding: utf-8
# ODDB::Swissindex::SwissindexPharma -- 15.08.2011 -- mhatakeyama@ywesee.com

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
    @base_url   = 'https://prod.ws.e-mediat.net/wv_getMigel/wv_getMigel.aspx?Lang=DE&Query='
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

    rescue StandardError, Timeout::Error => err
      if try_time > 0
        puts err
        puts err.backtrace
        puts
        puts "retry"
        sleep 10
        try_time -= 1
        retry
      else
        puts " - probably server is not responding"
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
      agent.get(@base_url + 'Pharma=' + pharmacode)
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
    rescue StandardError, Timeout::Error => err
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
  def search_migel_table(code, query_key = 'Pharmacode')
    # 'MiGelCode' is also available for query_key
    agent = Mechanize.new
    try_time = 3
    begin
      agent.get(@base_url + query_key + '=' + code)
      count = 100
      table = []
      line  = []
      migel = {}
      agent.page.search('td').each_with_index do |td, i|
        text = td.inner_text.chomp.strip
        if text.is_a?(String) && text.length == 7 && text.match(/\d{7}/) 
          swissindex = {}
          if pharmacode = line[0] and pharmacode.match(/\d{7}/) and item = search_item(pharmacode)
            swissindex[:ean_code] = item[:gtin]
            swissindex[:article_name] = item[:dscr]
            swissindex[:size] = item[:addscr]
            swissindex[:status] = item[:status]
            if company = item[:comp]
              swissindex[:companyname] = company[:name]
            end
          end

          pharmacode, article_name, companyname, ppha, ppub, factor = *line
          migel = {
            :pharmacode   => pharmacode,
            :article_name => article_name,
            :companyname  => companyname,
            :ppha         => ppha,
            :ppub         => ppub,
            :factor       => factor,
          }
          migel.update swissindex
#          line.unshift ean_code
#          table << line
          table << migel
          line = []
          swisindex = {}
          count = 0
        end
        if count < 7 
          text = text.split(/\n/)[1] || text.split(/\n/)[0]
          text = text.gsub(/\302\240/, '').strip if text
          line << text
          count += 1
        end
      end
      # for the last line
      swissindex = {}
      if pharmacode = line[0] and pharmacode.match(/\d{7}/) and item = search_item(pharmacode)
        swissindex[:ean_code] = item[:gtin]
        swissindex[:article_name] = item[:dscr]
        swissindex[:size] = item[:addscr]
        swissindex[:status] = item[:status]
        if company = item[:comp]
          swissindex[:companyname] = company[:name]
        end
      end
      pharmacode, article_name, companyname, ppha, ppub, factor = *line
      migel = {
        :pharmacode   => pharmacode,
        :article_name => article_name,
        :companyname  => companyname,
        :ppha         => ppha,
        :ppub         => ppub,
        :factor       => factor,
      }
      migel.update swissindex

      table << migel
=begin
      ean_code = nil
      if pharmacode = line[0] and pharmacode.match(/\d{7}/) 
        ean_code = search_item(pharmacode)[:gtin]
      end
      line.unshift ean_code
      table << line
=end

      table.shift
      table
    rescue StandardError, Timeout::Error => err
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
      agent.get(@base_url + 'Pharmacode=' + pharmacode)
      pos_num = nil
      agent.page.search('td').each_with_index do |td, i|
        if i == 6
          pos_num = td.inner_text.chomp.strip
          break
        end
      end
      return pos_num
    rescue StandardError, Timeout::Error => err
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
  def search_item(code, search_type = :get_by_gtin, lang = 'DE')
    client = Savon::Client.new do | wsdl, http |
      wsdl.document = "https://index.ws.e-mediat.net/Swissindex/Pharma/ws_Pharma_V101.asmx?WSDL"
    end
    try_time = 3
    begin
      response = client.request search_type do
      soap.xml = if search_type == :get_by_gtin
      '<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <GTIN xmlns="http://swissindex.e-mediat.net/SwissindexPharma_out_V101">' + code + '</GTIN>
          <lang xmlns="http://swissindex.e-mediat.net/SwissindexPharma_out_V101">' + lang    + '</lang>
        </soap:Body>
      </soap:Envelope>'
                 elsif search_type == :get_by_pharmacode
      '<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <pharmacode xmlns="http://swissindex.e-mediat.net/SwissindexPharma_out_V101">' + code + '</pharmacode>
          <lang xmlns="http://swissindex.e-mediat.net/SwissindexPharma_out_V101">' + lang    + '</lang>
        </soap:Body>
      </soap:Envelope>'
                 end
      end
      if pharma = response.to_hash[:pharma] 
        return pharma[:item]
      else
        return nil
      end

    rescue StandardError, Timeout::Error => err
      if try_time > 0
        puts err
        puts err.backtrace
        puts
        puts "retry"
        sleep 10
        try_time -= 1
        retry
      else
        puts " - probably server is not responding"
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
