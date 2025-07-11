#!/usr/bin/ruby
# encoding: utf-8

# To test it place the following two lines at the end of this file
#   test1 = ODDB::Refdata::RefdataArticle.new
#   test1.get_refdata_info('7680657880014')
# and call sudo -u apache bundle-311 exec ruby-311  ext/refdata/bin/refdatad

require 'rubygems'
require 'drb'
require 'rubyntlm'
require 'net/ntlm'
require 'net/ntlm/version'
require 'savon'
require 'config'
require 'util/logfile'

module ODDB
  module Refdata
    DebugRefdata = ENV['DEBUG_REFDATA']
    # This procedure is needed for the migel import!
    def Refdata.debug_msg(string)
      return unless DebugRefdata
       ODDB::LogFile.debug  "#{string}"
    end

    def Refdata.session(type = RefdataArticle)
      yield(type.new)
    end

    def Refdata.check_net_ntlm_version
      begin
        require 'net/ntlm'
        require 'net/ntlm/version' unless Net::NTLM.const_defined?(:VERSION)
        unless Net::NTLM::VERSION::STRING >= '0.3.2'
          raise ArgumentError, 'Invalid version of rubyntlm. Please use v0.3.2+.'
        end
      rescue LoadError
      end
    end
  Refdata.check_net_ntlm_version

module Archiver
  REFDATA_BASE_URI = "http://refdatabase.refdata.ch"
  ODDB::LogFile.debug "Refdata: Starting debugging using REFDATA_BASE_URI http://refdatabase.refdata.ch"

  def historicize(filename, archive_path, content)
    save_dir = File.join archive_path, 'xml'
    FileUtils.mkdir_p save_dir
    archive = File.join save_dir,
                        Date.today.strftime(filename.gsub(/\./,"-%Y.%m.%d."))
    latest  = File.join save_dir,
                        Date.today.strftime(filename.gsub(/\./,"-latest."))
    File.open(archive, 'w') do |f|
      f.puts content
    end
    FileUtils.cp(archive, latest)
    ODDB::LogFile.debug "Archiver #{latest} #{File.size(latest)} bytes. archive #{archive}"
  end
end

class RequestHandler
  def initialize(wsdl_url = "https://refdatabase.refdata.ch/Service/Article.asmx?WSDL")
    @client = Savon.client(
      :wsdl => wsdl_url,
      :log => false,
      :log_level => :info,
      :open_timeout => 1,
      :read_timeout => 1,
      )
  end
  def logger(file, options={})
    project_root = File.expand_path('../../..', File.dirname(__FILE__))
    log_dir      = File.expand_path("doc/sl_errors/#{Time.now.year}/#{"%02d" % Time.now.month.to_i}", project_root)
    log_file     = File.join(log_dir, file)
    create_file = if File.exist?(log_file)
                    mtime = File.mtime(log_file)
                    last_update = [mtime.year, mtime.month, mtime.day].join.to_s
                    now = Time.new
                    today = [now.year, now.month, now.day].join.to_s
                    last_update != today
                  else
                    true
                  end
    FileUtils.mkdir_p log_dir
    wa = create_file ? 'w' : 'a'
    open(log_file, wa) do |out|
      if options.has_key?(:code)
        if create_file
          out.print "The following packages (gtin or pharmacode) are not updated (probably because of no response from refdata server).\n"
          out.print "The second possibility is that the pharmacode is not found in the refdata server.\n\n"
        end
        out.print "#{options[:type]}: #{options[:code]} (#{Time.new})\n"
      elsif options.has_key?(:error)
        out.print "#{options[:type]}: #{options[:error]} (#{Time.new})\n"
      else
        out.print "#{options[:type]}: (#{Time.new})\n"
      end
    end
    return nil
  end
end

class RefdataArticle < RequestHandler
  URI = 'druby://127.0.0.1:50001'
  include DRb::DRbUndumped
  include Archiver
  @@items ||= {}
  @@time_download ||= {}
  $stdout.sync = true
  def initialize
    super()
  end

  def download_all(type = 'Pharma')
    ODDB::LogFile.debug "RefdataArticle.download_all starting #{type} @@items #{@@items.size}"
    @type = type
    if @@items[type] && @@time_download[type] &&
        ((diff = Time.now- @@time_download[type]).to_i < 24*60*60) # less than 24 hours
      $stdout.puts "Skipping downloading #{type} #{diff} = #{Time.now} - #{@@time_download[type]}"
      return
    end
    @client.globals[:read_timeout] = 120

    try_time = 3
    begin
        soap = %(<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://refdatabase.refdata.ch/Article_in" xmlns:ns2="http://refdatabase.refdata.ch/">
  <SOAP-ENV:Body>
    <ns2:DownloadArticleInput>
      <ns1:ATYPE>#{@type.upcase}</ns1:ATYPE>
    </ns2:DownloadArticleInput>
  </SOAP-ENV:Body>
  </SOAP-ENV:Envelope>
</ns1:ATYPE></ns2:DownloadArticleInput></SOAP-ENV:Body>
)
      response = @client.call(:download, :xml => soap)
      if response.success?
        if xml = response.to_xml
          archive_path = File.expand_path('../../../data', File.dirname(__FILE__))
          historicize("XMLRefdata#{type}.xml",archive_path, xml)
          @@items[@type] = response.to_hash[:article][:item]
          @@time_download[type] = Time.now
          ODDB::LogFile.debug "RefdataArticle.download_all done #{type} time #{@@time_download[type]}"
          return true
        else
          # received broken data or unexpected error
          raise StandardError
        end
      else
        # timeout or unexpected error
        raise StandardError
      end
    rescue StandardError, Timeout::Error => err
      ODDB::LogFile.debug "Refdata Download failed: try_time #{try_time} #{err}. from #{caller[0..5].join("\n")}"
      if err.is_a?(ArgumentError)
        raise err
      end
      if try_time > 0
        sleep 10
        try_time -= 1
        retry
      else
        options = {
          :type  => :download_all.to_s,
          :error => err
        }
        return logger('bag_xml_refdata_pharmacode_download_all_error.log', options);
      end
    end
  end
  def get_refdata_info(code, key_type = :gtin, type = 'Pharma')
    download_all(type) unless @@items and @@items[type]
    Refdata.debug_msg "RefdataArticle.get_refdata_info1 code #{code} key_type #{key_type} type #{type}"
    item = {}
    item = @@items[type].find { |i| i.has_key?(key_type) and code == i[key_type] } if @@items and @@items[type]
    Refdata.debug_msg "RefdataArticle.get_refdata_info2 item #{item}"
    return  {} unless item
    case
    when item.empty?
      Refdata.debug_msg "RefdataArticle.get_refdata_info done #{code} key_type #{key_type} empty returns {}"
      return {}
    when item[:status] == "I"
      Refdata.debug_msg "RefdataArticle.get_refdata_info done #{code} key_type #{key_type} :status I returns {}"
      return {}
    else
      Refdata.debug_msg "RefdataArticle.get_refdata_info done #{code} key_type #{key_type} returns #{item.inspect}"
      return item
    end
  end
  def search_item(code, type = 'Pharma')
    ODDB::LogFile.debug "RefdataArticle.search_item code #{code} type #{type}"
    @type = type
    try_time = 3
    is_gtin = code.to_s.length == 13
    begin
      soap = %(<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://refdatabase.refdata.ch/Article_in" xmlns:ns2="http://refdatabase.refdata.ch/">
  <SOAP-ENV:Body>
    <ns2:DownloadArticleInput>
      <ns1:ATYPE>#{@type.upcase}</ns1:ATYPE>
      <ns1:TYPE>#{is_gtin ? 'GTIN' : 'PHAR'}</ns1:TYPE>
      <ns1:TERM>#{code}</ns1:TERM>
    </ns2:DownloadArticleInput>
  </SOAP-ENV:Body>
  </SOAP-ENV:Envelope>
</ns1:ATYPE></ns2:DownloadArticleInput></SOAP-ENV:Body>
)
      response = @client.call(:download, :xml => soap)
      if pharma = response.to_hash[:article]
        # If there are some products those phamarcode is same, then the return value become an Array
        # We take one of them which has a higher Ean-Code
        pharma_item = if pharma[:item].is_a?(Array)
                        pharma[:item].sort_by{|item| item[:gtin].to_i}.reverse.first
                      elsif pharma[:item].is_a?(Hash)
                        pharma[:item]
                      end
        ODDB::LogFile.debug "RefdataArticle.search_item code #{code} type #{type} returns #{pharma_item}"
        return pharma_item
      else
        # Pharmacode is not found in request result by ean(GTIN) code
        ODDB::LogFile.debug "RefdataArticle.search_item code #{code} type #{type} returns {}"
        return {}
      end
    rescue StandardError, Timeout::Error => err
      ODDB::LogFile.debug "RefdataArticle.search_item(#{code}) failed: #{err}"
      if err.is_a?(ArgumentError)
        raise err
      end
      if try_time > 0
        sleep 10
        try_time -= 1
        retry
      else
        options = {
          :type => @type.to_s.gsub('gen_by_', ''),
          :code => code
        }
        return logger('bag_xml_refdata_pharmacode_error.log', options)
      end
    end
  end
end

  end # Refdata

end # ODDB
