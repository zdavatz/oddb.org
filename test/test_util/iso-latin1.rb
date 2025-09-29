#!/usr/bin/env ruby

# ODDB::Util::TestIsoLatin1 -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "util/iso-latin1"

module ODDB
  module Util
    class TestIsoLatin1 < Minitest::Test
      def setup
        @str =+ "TESTFÄLLE"
      end

      def test_downcase
        assert_equal("testfälle", @str.downcase)
      end

      def test_downcase!
        @str.downcase!
        assert_equal("testfälle", @str)
      end
    end
  end # Util
end # ODDB
