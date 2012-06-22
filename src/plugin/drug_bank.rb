#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::DrugBankPlugin -- oddb.org -- 21.06.2012 -- yasaka@ywesee.com

require 'mechanize'

module ODDB
  ###
  # = ODDB::DrugBankPlugin is ID updater plugin for link to drugbank.ca
  #
  # Note:: Atcclass#db_id is ID from DB of drugbank.ca
  # See::  http://www.drugbank.ca/documentation
  class DrugBankPlugin < Plugin
    def initialize(app=nil)
      super app
      @search_url = "http://www.drugbank.ca/search?utf8=✓&query=%s&commit=Search"
      @links = []
      # report
      @checked   = 0
      @nonlinked = 0
      @activated = 0
    end
    ##
    # Update id of drugbank.ca for direct link url
    def update_db_id
      @app.atc_classes.values.each do |atc|
        next if atc.description.empty? # skip parent atc_class
        next unless atc.code.length > 6 # short codes are not in drugbank.ca
        sleep 5
        _search_with atc
        db_id = _extract_db_id_of atc
        args = { :db_id => db_id }
        @app.update atc.pointer, args
        db_id.nil? ? @nonlinked += 1 : @activated += 1
        @checked += 1
      end
    end
    def report
      [
        "Checked ATC classes   : #{@checked}",
        "Actived Drugbank Link : #{@activated}",
        "Non-link ATC classes  : #{@nonlinked}",
      ].join("\n")
    end
    private
    def _search_with atc
      @links = []
      agent = Mechanize.new
      agent.user_agent_alias = "Linux Firefox"
      page = nil
      limit = 3
      tried = 0
      begin
        tried += 1
        page = agent.get(@search_url % atc.code)
      rescue Timeout::Error
        if tried <= limit
          sleep 10
          retry
        end
      end
      if page
        @links = page.links.select do |link|
          link if link.text.match /DB/
        end
      end
    end
    ##
    # Extract first ID from search result
    #
    # URL format is:
    #   http://www.drugbank.ca/drugs/DB00571
    def _extract_db_id_of(atc)
      db_id = nil
      catch :db_id do
        @links.each do |link|
          if link.uri.to_s =~ /drugs\/(DB\d{5})/iu
            db_id = $1
            throw :db_id
          end
        end
      end
      db_id
    end
  end
end
