#!/usr/bin/env ruby

# ODDB::App#rss_updates re-reads the hash from the stored root in a server
# process. Until 02.10.2026 a running server showed what it had loaded at
# start, and the home page said September with October in the database.

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "stub/odba"
require "stub/config"
require "minitest/autorun"
require "flexmock/minitest"
require "util/oddbapp"

class TestRssUpdatesRefresh < Minitest::Test
  STALE = {"price_cut.rss" => [Date.new(2026, 9, 1), 22]}
  FRESH = {"price_cut.rss" => [Date.new(2026, 10, 1), 284]}

  def app(auxiliary: nil)
    system = flexmock("system")
    system.should_receive(:rss_updates).and_return { system.instance_variable_get(:@rss_updates) }
    system.instance_variable_set(:@rss_updates, STALE)
    app = ODDB::App.allocate
    app.instance_variable_set(:@cache_mutex, Mutex.new)
    app.instance_variable_set(:@system, system)
    app.instance_variable_set(:@auxiliary, auxiliary)
    app
  end

  def stored(hash, times: 1)
    root = Object.new
    root.instance_variable_set(:@rss_updates, hash)
    storage = flexmock("storage")
    storage.should_receive(:restore_named).with("oddbapp").times(times).and_return("dump")
    flexmock(ODBA).should_receive(:storage).and_return(storage)
    flexmock(ODBA).should_receive(:marshaller).and_return(flexmock(load: root))
  end

  def test_a_server_reads_what_the_jobs_stored
    stored(FRESH)
    assert_equal(FRESH, app.rss_updates)
  end

  def test_it_asks_the_database_once_per_ttl
    stored(FRESH, times: 1)
    a = app
    3.times { assert_equal(FRESH, a.rss_updates) }
  end

  def test_it_asks_again_after_the_ttl
    stored(FRESH, times: 2)
    a = app
    a.rss_updates
    a.instance_variable_set(:@rss_updates_read, Time.now - ODDB::App::RSS_UPDATES_TTL - 1)
    a.rss_updates
  end

  def test_no_stored_root_keeps_what_we_have
    flexmock(ODBA).should_receive(:storage).and_return(flexmock(restore_named: nil))
    assert_equal(STALE, app.rss_updates)
  end

  def test_a_job_keeps_its_own_copy
    flexmock(ODBA).should_receive(:storage).never
    assert_equal(STALE, app(auxiliary: true).rss_updates)
  end

  def test_garbage_in_the_database_is_not_taken
    stored("not a hash")
    assert_equal(STALE, app.rss_updates)
  end
end
