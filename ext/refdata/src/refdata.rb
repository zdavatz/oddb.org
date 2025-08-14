#!/usr/bin/ruby
# To test it place the following two lines at the end of this file
#   test1 = ODDB::Refdata::RefdataArticle.new
#   test1.get_refdata_info('7680657880014')
# and call sudo u apache bundle311 exec ruby311  ext/refdata/bin/refdatad

require 'rubygems'
require 'drb'
#require 'rubyntlm'
#require 'net/ntlm'
#require 'net/ntlm/version'
#require 'savon'
require 'config'
require 'util/logfile'
require 'open-uri'
require 'ox'
require 'util/workdir'

module ODDB
  module Refdata
    DebugRefdata = ENV['DEBUG_REFDATA']
    # This procedure is needed for the migel import!
    def Refdata.debug_msg(string)
      return unless DebugRefdata
       ODDB::LogFile.debug  "#{string}"
    end

module Archiver
  REFDATA_BASE_URI = "http://refdatabase.refdata.ch"
  ODDB::LogFile.debug "Refdata: Starting debugging using REFDATA_BASE_URI http://refdatabase.refdata.ch"

  def historicize(filename, archive_path, content)
    save_dir = File.join archive_path, 'xml'
    FileUtils.mkdir_p save_dir
    archive = File.join save_dir,
                        Date.today.strftime(filename.gsub(/\./,"%Y.%m.%d."))
    latest  = File.join save_dir,
                        Date.today.strftime(filename.gsub(/\./,"latest."))
    File.open(archive, 'w') do |f|
      f.puts content
    end
    FileUtils.cp(archive, latest)
    ODDB::LogFile.debug "Archiver #{latest} #{File.size(latest)} bytes. archive #{archive}"
    latest
  end
end

class RefdataArticle
  URI = (defined?(Minitest) ? 'druby://:58001' : 'druby://127.0.0.1:50001')
  include DRb::DRbUndumped
  include Archiver
  RefDataURL = "https://files.refdata.ch/simis-public-prod/Articles/1.0/Refdata.Articles.zip"
  @@items = {}
  @@time_download = (Date.today - 2).to_time # for a reload upon start
  $stdout.sync = true
  def initialize
    super()
  end

  def items
    @@items
  end if defined?(Minitest)

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

  def download_all
    ODDB::LogFile.debug "RefdataArticle.download_all starting @@items #{@@items.size}"
    @@refdata_xml = File.join(ODDB::WORK_DIR, 'xml', 'XMLRefdataPharma-latest.xml') # must be in sync with src/plugin/atc_less.rb
    if @@items && @@time_download &&
        ((diff = Time.now - @@time_download).to_i < 24*60*60) # less than 24 hours
      $stdout.puts "Skipping downloading #{diff} = #{Time.now}  #{@@time_download}"
      return
    end
    begin
      content = ::URI.open(RefDataURL, 'r').read
      latest = historicize("XMLRefdata-Articles-.zip", ODDB::WORK_DIR, content)
      File.open(latest, 'w+') {|f| f.write(content)}
      @@time_download = Time.now
      ODDB::LogFile.debug "RefdataArticle.download_all done time #{@@time_download}"
      xml = ''
      Zip::File.foreach(latest) do |entry|
        if entry.name =~ /Refdata.Articles.xml/iu
          puts entry.name
          entry.get_input_stream { |io| xml = io.read }
        end
      end
      File.open(@@refdata_xml, 'w') { |fh| fh.puts(xml) }

    rescue StandardError, Timeout::Error => err
      ODDB::LogFile.debug "Refdata Download failed: #{err}. from #{caller[0..5].join("\n")}"
      if err.is_a?(ArgumentError)
        raise err
      else
        options = {
          :type  => :download_all.to_s,
          :error => err
        }
        return logger('bag_xml_refdata_pharmacode_download_all_error.log', options);
      end
    end
    articles = Ox.load(xml, mode: :hash_no_attrs)[:Articles][:Article]
    articles.size
    @info_to_gln = {}
    articles.each_with_index do |article, index|
      Refdata.debug_msg "At article #{index} of #{articles.size}"  if (index % 20000) == 0
      gtin = article[:PackagedProduct][:DataCarrierIdentifier]
      details = {}
      article[:PackagedProduct][:Name].each do |lang_desc|
          details[ "name_#{lang_desc[:Language].downcase}".to_sym] = lang_desc[:FullName]
      end
      type = article[:MedicinalProduct][:ProductClassification][:ProductClass].capitalize
      type = 'NonPharma' if type.eql?('Nonpharma')
      details[:type] = type
      details[:gtin] = gtin
      details[:atc] = article[:MedicinalProduct][:ProductClassification][:Atc]
      details[:auth_holder_gln] = article[:PackagedProduct][:Holder][:Identifier]
      details[:auth_holder_name] = article[:PackagedProduct][:Holder][:Name]
      details[:swmc_authnr] = article[:PackagedProduct][:RegulatedAuthorisationIdentifier]
      @@items[type] ||= []
      @@items[type] << details
    end
  end
  def get_refdata_info(code, key_type = :gtin, type = 'Pharma')
    download_all unless @@items and @@items[type]
    Refdata.debug_msg "RefdataArticle.get_refdata_info1 code #{code} key_type #{key_type} type #{type}"
    item = {}
    item = @@items[type].find { |i| i.has_key?(key_type) and code.to_i == i[key_type].to_i } if @@items and @@items[type]
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
    download_all unless @@items and @@items[type]
    res = get_refdata_info(code, :gtin)
    return res.size == 0 ? nil : res
  end
end

  end # Refdata

end # ODDB
