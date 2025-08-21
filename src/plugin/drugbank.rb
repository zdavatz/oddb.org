#!/usr/bin/env ruby

# ODDB::DrugbankPlugin -- oddb.org -- 25.06.2012 -- yasaka@ywesee.com

require "mechanize"
require "plugin/plugin"

module ODDB
  ###
  # = ODDB::DrugbankPlugin is ID updater plugin for link to drugbank.ca
  #
  # Note:: Atcclass#db_id is ID from DB of drugbank.ca
  # See::  http://www.drugbank.ca/documentation
  class DrugbankPlugin < Plugin
    PAGE_DOES_NOT_EXIST = "How did you get here? That page doesn't exist. Oh well, it happens."
    def initialize(app = nil, agent: Mechanize.new)
      super(app)
      # https://www.drugbank.ca/unearth/q?utf8=%E2%9C%93&query=Tamoxifen&searcher=drugs&approved=1&vet_approved=1&nutraceutical=1&illicit=1&withdrawn=1&investigational=1&button=
      @links = []
      # report
      @checked = 0
      @nonlinked = 0
      @activated = 0
      @changed = 0
      @agent = agent
    end

    ##
    # Update id of drugbank.ca for direct link url
    def update_db_id
      start_time = Time.now
      @app.atc_classes.values.each do |atc|
        next if atc.description.empty? # skip parent atc_class
        next unless atc.code.length > 6 # short codes are not in drugbank.ca
        @checked += 1
        db_id = _search_with(atc, @agent)
        if $VERBOSE
          puts "Changing #{atc.db_id} => #{db_id}" unless db_id.eql?(atc.db_id)
        end
        @changed += 1 unless db_id.eql?(atc.db_id)
        @app.update atc.pointer, {db_id: db_id}
        db_id.nil? ? @nonlinked += 1 : @activated += 1
      end
      @duration_in_secs = (Time.now.to_i - start_time.to_i)
    end

    def report
      [
        "Checked ATC classes   : #{@checked}",
        "Actived Drugbank Link : #{@activated}",
        "Non-link ATC classes  : #{@nonlinked}",
        "Updated ATC classes   : #{@changed}",
        "Update job took       : #{@duration_in_secs.to_i} seconds"
      ].join("\n")
    end

    private

    def _search_with(atc, agent)
      @links = []
      agent.keep_alive = false
      agent.user_agent_alias = "Linux Firefox"
      page = nil
      limit = 3
      tried = 0
      url = "https://www.drugbank.ca/unearth/q?utf8=%E2%9C%93&query=" + atc.name +
        "&searcher=drugs&approved=1&vet_approved=1&nutraceutical=1&illicit=1&withdrawn=1&investigational=1&button="
      begin
        tried += 1
        page = agent.get(url)
      rescue Mechanize::ResponseCodeError => e
        return nil
      rescue Net::HTTP::Persistent::Error => e
        if /timeout/iu =~ e.message and tried <= limit
          sleep 10
          retry
        end
      end
      begin
        if page && page.links && (reference = page.links.find { |x| /^D\w{3}\d{3}/.match(x.to_s) })
          puts "Found #{reference} for #{atc.code} #{atc.name} with #{atc.active_packages.size} active_packages" if $VERBOSE
          # first one is A01AB03 with 22 active_packages
          return reference.to_s
        end
      rescue
        puts "Error search for #{atc.code} #{atc.name}" if $VERBOSE
      end
      puts "Nothing found #{reference} for #{atc.code} #{atc.name}" if $VERBOSE
      nil
    end
  end
end
