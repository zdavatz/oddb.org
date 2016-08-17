#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'minitest/mock'
require 'flexmock'
require 'stub/odba'
require 'fileutils'
require 'plugin/evidentia_search_links'

module ODDB
  class StubLog
    include ODDB::Persistence
    attr_accessor :report, :pointers, :recipients, :hash
    def notify(arg=nil)
    end
  end
  class StubApp
    attr_writer :log_group
    attr_reader :pointer, :values, :model
    attr_accessor :last_date, :evidentia_search_links_hash, :registrations
    def initialize
      @model = StubLog.new
      @evidentia_search_links_hash = {}
    end
  end
  class TestEvidentiaSearchLinksPlugin < Minitest::Test
    include FlexMock::TestCase
  def setup
      @app = flexmock('stub_app', StubApp.new)
      @@datadir = File.expand_path '../data/csv/', File.dirname(__FILE__)
      @@destination = File.expand_path '../../data/csv/', File.dirname(__FILE__)
      FileUtils.rm_rf(@@destination, :verbose => $VERBOSE)
      FileUtils.mkdir_p @@destination
      ODDB.config.data_dir = @@destination
      ODDB.config.log_dir = @@destination
      @fileName = File.join(@@datadir, 'evidentia_fi_link.csv')
      FileUtils.rm_f(@@destination, :verbose => $VERBOSE)
      @mechanize = flexmock('Mechanize')
      @mechanize.should_receive(:get).with(ODDB::EvidentiaSearchLinksPlugin::CSV_ORIGIN_URL).and_return(IO.read(@fileName))
      @latest = File.join(@@destination, 'evidentia_fi_link-latest.csv')
    end

    def teardown
      FileUtils.rm_rf(@@destination, :verbose => $VERBOSE)
      ODBA.storage = nil
      super # to clean up FlexMock
    end

    def test_update_evidentia_search_links_update
      @app.should_receive(:odba_store).once
      assert(File.exists?(@fileName), "File #{@fileName} must exist")
      @plugin = ODDB::EvidentiaSearchLinksPlugin.new(@app, {})
      assert_equal(true, @plugin.update(@mechanize), 'Plugin must be able to update')
      report = @plugin.report
      assert(report.match(/Added 19 search_links/), 'report must match links')
      assert_equal('7680657820010 http://evidentia.ch/pneumologie/medical-fact-sheets/Esbriet Esbriet®',
                   EvidentiaSearchLink.get_info('7680657820010').to_s)
      assert_equal(19, EvidentiaSearchLink.get.size)
      assert_equal(19, @app.evidentia_search_links_hash.size)
      assert_equal(true, File.exist?(@latest), "#{@latest} must exist")
    end

    def test_skip_update_if_csv_okay
      @app.should_receive(:odba_store).never
      FileUtils.cp(@fileName, @latest, :verbose => $VERBOSE)
      @plugin = ODDB::EvidentiaSearchLinksPlugin.new(@app, {})
      assert_equal(true, @plugin.update(@mechanize), 'Plugin must be able to update')
      report = @plugin.report
      assert(report.empty?, 'Must skip importing CSV file and return an empty report')
      assert_equal(true, File.exist?(@latest), "#{@latest} must exist")
    end
    def test_skip_update_twice_in_one_day_must_skip
      @app.should_receive(:odba_store).once
      @plugin = ODDB::EvidentiaSearchLinksPlugin.new(@app, {})
      assert_equal(true, @plugin.update(@mechanize), 'Plugin must be able to update')
      report1 = @plugin.report
      assert(report1.match(/Added 19 search_links/), 'report must match links')
      assert_equal(true, @plugin.update(@mechanize), 'Plugin must be able to update')
      report2 = @plugin.report
      assert(report2.empty?, 'Must skip importing CSV file and return an empty report')
      assert_equal(true, File.exist?(@latest), "#{@latest} must exist")
    end
  end
end 
