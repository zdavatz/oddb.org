#!/usr/bin/env ruby
# encoding: utf-8
$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'model/evidentia_search_link'
require 'plugin/plugin'
require 'util/oddbconfig'
require 'util/persistence'
require 'util/latest'
require 'drb'

module ODDB
  class EvidentiaSearchLinksPlugin < Plugin
    CSV_ORIGIN_URL = 'http://www.evidentia.beatsteinegger.com/evidentia_fi_link.csv'
    @@report = []
    def initialize(app, options = nil)
      super
    end
    def report
      @@report.join("\n")
    end

    def update(agent = Mechanize.new)
      @@report = []
      csv_file = File.expand_path('../../data/csv/evidentia_fi_link.csv', File.dirname(__FILE__))
      latest = csv_file.sub(/\.csv$/, '-latest.csv')
      result = Latest.get_latest_file(latest, ODDB::EvidentiaSearchLinksPlugin::CSV_ORIGIN_URL, agent)
      if result.is_a?(String)
        @@report << EvidentiaSearchLink.import_csv_file(latest)
        @app.evidentia_search_links_hash = EvidentiaSearchLink.get
        @app.odba_store
      end
      old_ones = Dir.glob(latest.sub( '-latest.csv', '-20*.csv'))
      FileUtils.rm(old_ones, verbose: true)
      true
    end
  end
end
