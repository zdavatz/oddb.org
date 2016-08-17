#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Substance -- oddb.org -- 19.02.2012 -- mhatakeyama@ywesee.com 
# ODDB::Substance -- oddb.org -- 25.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'util/logfile'
require 'csv'

module ODDB
  class EvidentiaSearchLink
    @@evidentia_search_links_hash ||= {}
    attr_reader :gtin, :link, :trademark
    include Persistence
    def initialize(gtin, link, trademark)
      @gtin = gtin
      @link = link
      @trademark = trademark
      super()
      @@evidentia_search_links_hash[gtin] = self
    end
    alias :pointer_descr :gtin
    def to_i
      oid
    end
    def to_s
      "#{gtin} #{link} #{trademark}"
    end
    def update_values(values, origin=nil)
    end
    def <=>(other)
      to_s.downcase <=> other.to_s.downcase
    end

    def EvidentiaSearchLink.get
      return @@evidentia_search_links_hash
    end
    def EvidentiaSearchLink.set(interactions)
      @@evidentia_search_links_hash = interactions
    end
    def EvidentiaSearchLink.get_info(gtin)
      @@evidentia_search_links_hash[gtin]
    end
    def EvidentiaSearchLink.checkout
      @@evidentia_search_links_hash = {}
    end
    def EvidentiaSearchLink.import_csv_file(file_name)
      @lineno = 0
      first_line = nil
      counter = 0
      EvidentiaSearchLink.checkout
      return "File #{file_name} does not exist" unless File.exist?(file_name)
      File.readlines(file_name).each do |line|
        @lineno += 1
        line = line.force_encoding('utf-8')
        # GTIN/EAN;Link;Markenname
        next if /GTIN\/EAN;Link/i.match(line) # skip first line
        begin
          elements = CSV.parse_line(line.strip, :col_sep => ';')
        rescue CSV::MalformedCSVError
          msg << "CSV::MalformedCSVError in line #{@lineno}: #{line}"
          next
        end
        next if elements.size < 3 # Eg. empty line at the end
        search_link = ODDB::EvidentiaSearchLink.new(elements[0], elements[1], elements[2])
        counter += 1
      end
      msg = "#{Time.now} Added #{EvidentiaSearchLink.get.size} search_links from #{file_name}"
      EvidentiaSearchLink.debug_msg(msg)
      msg
    end
  private
     def EvidentiaSearchLink.debug_msg(msg)
      if not defined?(@checkLog) or not @checkLog
        name = LogFile.filename('oddb/debug/', Time.now)
        FileUtils.makedirs(File.dirname(name))
        @checkLog = File.open(name, 'a+')
      end
      @checkLog.puts("#{Time.now}: #{msg}")
      @checkLog.flush
    end
  end
end
