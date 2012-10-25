#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestRssPlugin -- oddb.org -- 25.10.2012 -- yasaka@ywesee.com

require 'pathname'
require 'test-unit'
require 'flexmock'

root = Pathname.new(__FILE__).realpath.parent.parent.parent
$: << root.join('test').join('test_plugin')
$: << root.join('src')

require 'plugin/rss'

module ODDB
  class TestRssPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @app = FlexMock.new 'app'
      @plugin = RssPlugin.new @app
    end
    def teardown
      # pass
    end
    def test_update_recall_feeds
      # pending
    end
  end
end


