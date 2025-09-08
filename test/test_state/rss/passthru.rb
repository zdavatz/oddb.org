#!/usr/bin/env ruby

# ODDB::State::Rss::TestPassThru -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "util/oddbconfig"
require "state/rss/passthru"

module ODDB
  module State
    module Rss
      class TestPassThru < Minitest::Test
        @@saved = ODDB::RSS_PATH
        def setup
          eval("ODDB::RSS_PATH = Dir.mktmpdir")
          @lnf = flexmock("lookandfeel", lookup: "lookup")
          @session = flexmock("session",
            lookandfeel: @lnf,
            language: "language",
            passthru: "passthru")
          super
        end

        def teardown
          eval("ODDB::RSS_PATH = '#{@@saved}'")
          super
        end

        def test_init_no_file
          assert_raises(Errno::ENOENT) do
            @state = ODDB::State::Rss::PassThru.new(@session, "model")
          end
        end

        def test_init_with_rss_file
          path = File.join(RSS_PATH, "language", "model")
          FileUtils.makedirs(File.dirname(path))
          File.write(path, "dummy")
          @state = ODDB::State::Rss::PassThru.new(@session, "model")
          assert_equal("passthru", @state.init)
        end
      end
    end # Rss
  end # State
end # ODDB
