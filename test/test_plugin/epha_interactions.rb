#!/usr/bin/env ruby
$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "stub/odba"
require "fileutils"
require "flexmock/minitest"
require "plugin/epha_interactions"

module ODDB
  class StubApp
    def odba_store
    end
  end

  class TestEphaInteractionPlugin < Minitest::Test
    def setup
      @app = StubApp.new
      @plugin = ODDB::EphaInteractionPlugin.new(@app, {})
    end

    def teardown
      ODBA.storage = nil
      super
    end

    def test_update_with_existing_db
      db_path = File.expand_path("../../data/sqlite/interactions.db", File.dirname(__FILE__))
      skip("interactions.db not found at #{db_path}") unless File.exist?(db_path)
      assert(@plugin.update(db_path))
      report = @plugin.report
      assert(report.match(/Reloaded interactions from SQLite DB/))
    end

    def test_update_with_missing_db
      assert(@plugin.update("/nonexistent/path/interactions.db"))
      report = @plugin.report
      assert(report.match(/SQLite DB not found/))
    end
  end
end
