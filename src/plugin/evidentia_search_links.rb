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
    @@report = []
    def initialize(app, options = nil)
      super
    end
    def report
      @@report.join("\n")
    end

    def update
      @@report = []
      csv_file = File.expand_path('../../data/csv/evidentia_fi_link.csv', File.dirname(__FILE__))
      if File.exist?(csv_file)
        @@report << EvidentiaSearchLink.import_csv_file(csv_file)
      else
        @@report << "File #{csv_file} does not exist"
      end
      @app.evidentia_search_links_hash = EvidentiaSearchLink.get
      @app.odba_store
      true
    end
  end
end
