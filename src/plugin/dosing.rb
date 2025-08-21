#!/usr/bin/env ruby

# ODDB::DosingPlugin -- oddb.org -- 26.06.2012 -- yasaka@ywesee.com

require "mechanize"
require "plugin/plugin"

module ODDB
  ###
  # = ODDB::DosingPlugin is ID updater plugin for link to dosing.de
  #
  # Note:: Atcclass#ni_id is ID(Niere ID) from DB of dosing.de
  # See::  http://dosing.de/Niere/nierelst.htm
  class DosingPlugin < Plugin
    def initialize(app = nil)
      super
      @index_url = "http://www.dosing.de/nierelst.php"
      @links = []
      # report
      @checked = 0
      @activated = 0
    end

    def update_ni_id
      start_time = Time.now
      _index
      # We should iterate over the links (around 800) instead of the atc_classe (around 8000)
      # eg. x = @app.atc_classes.values.find_all{ |x| /^Natriumfluorid/i.match(x.to_s) }
      non_empty_atc_classes = [] # Array of odba_id
      @app.atc_classes.values.compact.each do |atc|
        next if atc.description.empty? or !atc.respond_to?(:ni_id)
        non_empty_atc_classes << atc unless atc.ni_id && atc.ni_id.empty?
      end
      puts "Before loop we have #{non_empty_atc_classes.size} non_empty_atc_classes #{non_empty_atc_classes[0..5].join(".")}" if $VERBOSE
      @links.each do |link|
        next unless /\?monoid=(\d+)$/iu =~ link.uri.to_s
        ni_id = $1
        pattern = /^#{link.text}/i
        all_matching = @app.atc_classes.values.find_all { |x| pattern.match(x.to_s) }
        args = {ni_id: ni_id}
        all_matching.each do |atc|
          @checked += 1
          @activated += 1 unless atc.respond_to?(:ni_id) && atc.ni_id
          @app.update atc.pointer, args
          non_empty_atc_classes.delete_if { |elem| elem.odba_id == atc.odba_id }
        end
      end
      puts "After loop we have #{non_empty_atc_classes.size} non_empty_atc_classes #{non_empty_atc_classes[0..5].join(".")}" if $VERBOSE
      @removed_links = non_empty_atc_classes.size
      non_empty_atc_classes.each do |atc|
        args = {ni_id: nil}
        @app.update atc.pointer, args
      end
      @duration_in_secs = (Time.now.to_i - start_time.to_i)
    end

    ##
    # Update id of dosing.de for direct link url
    def report
      [
        "Checked ATC classes    : #{@checked}",
        "Activated Niere Link   : #{@activated}",
        "Non-linked ATC classes : #{@app.atc_classes.values.find_all { |atc| !atc.description.empty? && atc.respond_to?(:ni_id) && (!atc.ni_id || atc.ni_id.empty?) }.size}",
        "Update job took        : #{@duration_in_secs} seconds"
      ].join("\n")
    end

    private

    def _index
      agent = Mechanize.new
      agent.user_agent_alias = "Linux Firefox"
      page = agent.get @index_url
      @links = page.links.select do |link|
        link unless link.text.length < 5 # except "" and "#ABC"
      end
    end
  end
end
