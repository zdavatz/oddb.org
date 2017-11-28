#!/usr/bin/env ruby
# encoding: utf-8
$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'plugin/plugin'
require 'util/oddbconfig'
require 'util/persistence'
require 'util/latest'
require 'drb'
require 'model/epha_interaction'

module ODDB
  class EphaInteractionPlugin < Plugin
    @@report = []

    def debug_msg(msg)
      if defined?(MiniTest) then $stdout.puts Time.now.to_s + ': ' + msg; $stdout.flush; return end
      if not defined?(@checkLog) or not @checkLog
        name = LogFile.filename('oddb/debug/', Time.now)
        FileUtils.makedirs(File.dirname(name))
        @checkLog = File.open(name, 'a+')
        $stdout.puts "Opened #{name}"
      end
      @checkLog.puts("#{Time.now}: #{msg}")
      @checkLog.flush
    end

    def initialize(app, options = nil)
      super
    end
    def report
      @@report.join("\n")
    end
        
    def update(csv_file_path = ODDB::EphaInteractions::CSV_FILE)
      @@report = []
      latest = csv_file_path.sub(/\.csv$/, '-latest.csv')
      FileUtils.makedirs(File.dirname(ODDB::EphaInteractions::CSV_FILE))
      if Latest.get_latest_file(latest, ODDB::EphaInteractions::CSV_ORIGIN_URL)
        msg = "EphaInteractionPlugin.update latest #{latest} #{File.exists?(latest)} via #{File.expand_path(csv_file_path)} from #{ODDB::EphaInteractions::CSV_ORIGIN_URL}"
        @@report << msg
        debug_msg(msg)
        @lineno = 0
        first_line = nil
        debug_msg(msg)
        ODDB::EphaInteractions.read_from_csv(latest)
        @app.odba_store
        msg = "Added #{EphaInteractions.get.size} interactions from #{latest}";
        @@report << msg
        debug_msg(msg)
      else
        FileUtils.cp(latest, ODDB::EphaInteractions::CSV_FILE, preserve: true, verbose: true) unless File.exist?(ODDB::EphaInteractions::CSV_FILE)
      end
      true
    end
  end
end
