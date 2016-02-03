#!/usr/bin/ruby
# encoding: utf-8
# ODDB::Swissindex::Swissindex -- 02.10.2012 -- yasaka@ywesee.com
# ODDB::Swissindex::Swissindex -- 10.02.2012 -- mhatakeyama@ywesee.com

require 'rubygems'
require 'savon'
require 'mechanize'
require 'drb'
require 'config'
dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'plugin/refdata'

module ODDB
  module Swissindex
    DebugSwissindex = ENV['DEBUG_SWISSINDEX']
    def Swissindex.debug_msg(string)
      return unless DebugSwissindex
       $stdout.puts "#{Time.now}: #{string}"
       $stdout.flush
    end

    # This procedure is needed for the migel import!
    def Swissindex.session(type = SwissindexMigel)
      yield(type.new)
    end
  end

module Archiver
  def historicize(filename, archive_path, content, lang = 'DE')
    save_dir = File.join archive_path, 'xml'
    FileUtils.mkdir_p save_dir
    archive = File.join save_dir,
                        Date.today.strftime(filename.gsub(/\./,"-#{lang}-%Y.%m.%d."))
    latest  = File.join save_dir,
                        Date.today.strftime(filename.gsub(/\./,"-#{lang}-latest."))
    File.open(archive, 'w') do |f|
      f.puts content
    end
    FileUtils.cp(archive, latest)
  end
end
module Swissindex
class RequestHandler
  def initialize(wsdl_url = "https://index.ws.e-mediat.net/Swissindex/Pharma/ws_Pharma_V101.asmx?WSDL")
    Swissindex.debug_msg "RequestHandler wsdl_url #{wsdl_url}"
    @client = Savon.client(
      :wsdl => wsdl_url,
      :log => false,
      :log_level => :info,
      :open_timeout => 1,
      :read_timeout => 1,
      )
    @items = []
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
          out.print "The following packages (gtin or pharmacode) are not updated (probably because of no response from swissindex server).\n"
          out.print "The second possibility is that the pharmacode is not found in the swissindex server.\n\n"
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

class SwissindexMigel < RequestHandler
  URI = 'druby://localhost:50002'
  include DRb::DRbUndumped
  include Archiver
  attr_accessor :client, :base_url, :refdataServer
  REFDATA_SERVER = DRbObject.new(nil, ODDB::Refdata::RefdataArticle::URI)
  $stdout.sync = true
  def initialize
    REFDATA_SERVER.session(ODDB::Refdata::RefdataArticle) do |refdata|
      refdata.download_all('NonPharma')
    end
    super
    @base_url = ODDB.config.migel_base_url
  end

  def get_refdata_info(pharmacode, lang)
    res = nil
    REFDATA_SERVER.session(ODDB::Refdata::RefdataArticle) do |refdata|
      res = refdata.get_refdata_info(pharmacode, :phar, 'NonPharma')
    end
    $stdout.puts "SwissindexMigel.get_refdata_info returns #{res.inspect} for pharmacode #{pharmacode} #{lang}"
    res
  end

  def search_migel(pharmacode, lang = 'DE')
    Swissindex.debug_msg "SwissindexMigel search_migel pharmacode #{pharmacode}"
    agent = Mechanize.new
    try_time = 3
    begin
      agent.get(ODDB.config.migel_base_url.gsub(/DE/, lang) + 'Pharmacode=' + pharmacode)
    rescue StandardError, Timeout::Error => err
      Swissindex.debug_msg "search_migel pharmacode #{pharmacode} failed err #{err}"
      if try_time > 0
        sleep defined?(Minitest) ? 0.1 : 10
        agent = Mechanize.new
        try_time -= 1
        retry
      else
        return []
      end
    end
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
  end
  def merge_swissindex_migel(refdata_item, migel_line)
    # Swissindex data
    swissindex = refdata_item.collect do |key, value|
      case key
      when :gtin
        [:ean_code, value]
      when :dt
        [:datetime, value]
      when :lang
        [:language, value]
      when :dscr
        [:article_name, value]
      when :addscr
        [:size, value]
      when :comp
        [:companyname, value[:name], :companyean, value[:gln]]
      else
        [key, value]
      end
    end
    swissindex = Hash[*swissindex.flatten]

    # Migel data
    pharmacode, article_name, companyname, ppha, ppub, factor, pzr = *migel_line
    migel = {
      :pharmacode   => pharmacode,
      :article_name => article_name,
      :companyname  => companyname,
      :ppha         => ppha,
      :ppub         => ppub,
      :factor       => factor,
      :pzr          => pzr,
    }
    migel.update swissindex
  end
  # 'MiGelCode' is also available for query_key
  def search_migel_table(code, query_key = 'Pharmacode', lang = 'DE')
    # prod.ws.e-mediat.net use untrusted ssl cert
    Swissindex.debug_msg "SwissindexMigel.search_migel_table #{code} query_key  #{query_key} lang #{lang}"
    agent = Mechanize.new { |a|
      a.ssl_version, a.verify_mode = 'SSLv3',
      OpenSSL::SSL::VERIFY_NONE
    }
    try_time = 3
    pharmacode = nil
    begin
      agent.get(@base_url.gsub(/DE/,lang) + query_key + '=' + code)
      count = 100
      table = []
      line  = []
      migel = {}
      agent.page.search('td').each_with_index do |td, i|
        text = td.inner_text.chomp.strip
        if text.is_a?(String) && text.length == 7 && text.match(/\d{7}/)
          migel_item = if pharmacode = line[0] and pharmacode.match(/\d{7}/) and refdata_item = get_refdata_info(pharmacode, lang)
                         merge_swissindex_migel(refdata_item, line)
                       else
                         merge_swissindex_migel({}, line)
                       end
          table << migel_item
          line = []
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
      migel_item = if pharmacode = line[0] and pharmacode.match(/\d{7}/) and refdata_item = get_refdata_info(pharmacode, lang)
                     merge_swissindex_migel(refdata_item, line)
                   else
                     merge_swissindex_migel({}, line)
                   end
      table << migel_item
      table.shift
      table
    rescue StandardError, Timeout::Error => err
      $stdout.puts "search_migel_table #{code} for pharmacode #{pharmacode.inspect} failed err #{err}"
      if try_time > 0
        sleep defined?(Minitest) ? 0.1 : 10
        agent = Mechanize.new
        try_time -= 1
        retry
      else
        return []
      end
    end
  end
  def search_item(pharmacode, lang = 'DE')
    Swissindex.debug_msg  "SwissindexMigel search_item pharmacode #{pharmacode}"
    lang.upcase!
    try_time = 3
    begin
      soap = '<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
            <pharmacode xmlns="http://swissindex.e-mediat.net/SwissindexNonPharma_out_V101">' + pharmacode + '</pharmacode>
            <lang xmlns="http://swissindex.e-mediat.net/SwissindexNonPharma_out_V101">' + lang + '</lang>
        </soap:Body>
      </soap:Envelope>'
      response = @client.call(:get_by_pharmacode, :xml => soap)
      if nonpharma = response.to_hash[:nonpharma]
        nonpharma_item = if nonpharma[:item].is_a?(Array)
                          nonpharma[:item].sort_by{|item| item[:gtin].to_i}.reverse.first
                        elsif nonpharma[:item].is_a?(Hash)
                          nonpharma[:item]
                        end

        return nonpharma_item
      else
        return nil
      end

    rescue StandardError, Timeout::Error => err
      Swissindex.debug_msg  "search_item #{pharmacode} failed err #{err}" unless err.is_a?(Timeout::Error)
      if try_time > 0
        sleep defined?(Minitest) ? 0.1 : 10
        try_time -= 1
        retry
      else
        return nil
      end
    end
  end
  def search_item_with_swissindex_migel(pharmacode, lang = 'DE')
   Swissindex.debug_msg "SwissindexMigel search_item_with_swissindex_migel pharmacode #{pharmacode}"
    migel_line = search_migel(pharmacode, lang)
    if refdata_item = search_item(pharmacode, lang)
      merge_swissindex_migel(refdata_item, migel_line)
    else
      merge_swissindex_migel({}, migel_line)
    end
  end
  def search_migel_position_number(pharmacode, lang = 'DE')
    Swissindex.debug_msg "SwissindexMigel search_migel_position_number pharmacode #{pharmacode}"
    agent = Mechanize.new
    try_time = 3
    begin
      agent.get(@base_url.gsub(/DE/, lang) + 'Pharmacode=' + pharmacode)
      pos_num = nil
      agent.page.search('td').each_with_index do |td, i|
        if i == 6
          pos_num = td.inner_text.chomp.strip
          break
        end
      end
      return pos_num
    rescue StandardError, Timeout::Error => err
      Swissindex.debug_msg "search_migel_position_number #{pharmacode} failed err #{err}"
      if try_time > 0
        sleep defined?(Minitest) ? 0.1 : 10
        agent = Mechanize.new
        try_time -= 1
        retry
      else
        return nil
      end
    end
  end
end
end
end # ODDB
