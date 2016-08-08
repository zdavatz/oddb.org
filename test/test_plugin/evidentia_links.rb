#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
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
      @app.should_receive(:odba_store).once
      @@datadir = File.expand_path '../data/csv/', File.dirname(__FILE__)
      @@destination = File.expand_path '../../data/csv/', File.dirname(__FILE__)
      assert(File.directory?(@@datadir), "Directory #{@@datadir} must exist")
      FileUtils.mkdir_p @@destination
      ODDB.config.data_dir = @@destination
      ODDB.config.log_dir = @@destination
      @fileName = File.join(@@datadir, 'evidentia_fi_link.csv')
      FileUtils.cp(@fileName, @@destination, :verbose => $VERBOSE)
    end

    def teardown
      FileUtils.rm_rf @@destination
      ODBA.storage = nil
      super # to clean up FlexMock
    end

    def test_update_evidentia_search_links_update
      assert(File.exists?(@fileName), "File #{@fileName} must exist")
      @plugin = ODDB::EvidentiaSearchLinksPlugin.new(@app, {})
      assert_equal(true, @plugin.update, 'Plugin must be able to update')
      report = @plugin.report
      assert(report.match(/Added 19 search_links/))
      assert_equal('7680657820010 http://evidentia.ch/pneumologie/medical-fact-sheets/Esbriet Esbriet®',
                   EvidentiaSearchLink.get_info('7680657820010').to_s)
      assert_equal(19, EvidentiaSearchLink.get.size)
      assert_equal(19, @app.evidentia_search_links_hash.size)
    end
  end
end 
