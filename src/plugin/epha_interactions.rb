#!/usr/bin/env ruby

$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "plugin/plugin"
require "util/oddbconfig"
require "util/persistence"
require "drb"
require "model/sdif_interaction"

module ODDB
  class EphaInteractionPlugin < Plugin
    @@report = []

    def debug_msg(msg)
      if defined?(Minitest) then $stdout.puts Time.now.to_s + ": " + msg
                                 $stdout.flush
                                 return end
      if !defined?(@checkLog) or !@checkLog
        name = LogFile.filename("oddb/debug/", Time.now)
        FileUtils.makedirs(File.dirname(name))
        @checkLog = File.open(name, "a+")
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

    def update(db_path = ODDB::EphaInteractions::DB_FILE)
      @@report = []
      if File.exist?(db_path)
        ODDB::EphaInteractions.reload_db
        msg = "EphaInteractionPlugin: Reloaded interactions from SQLite DB: #{db_path}"
        @@report << msg
        debug_msg(msg)
      else
        msg = "EphaInteractionPlugin: SQLite DB not found at #{db_path}"
        @@report << msg
        debug_msg(msg)
      end
      true
    end
  end
end
