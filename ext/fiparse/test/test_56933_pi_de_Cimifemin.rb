#!/usr/bin/env ruby
$: << File.expand_path("../src", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))
require "minitest/autorun"
require "fiparse"
require "flexmock/minitest"
require "util/workdir"

module ODDB
  class PatinfoDocument
    def odba_id
      1
    end
  end
  module FiParse
    class TestPatinfoCimifeminDe < Minitest::Test
      def setup
        return if defined?(@@path) && defined?(@@patinfo) && @@patinfo
        @@path = File.join(File.dirname(__FILE__), "data", "html", "56933_pi_de_Cimifemin.html")
        @@writer = PatinfoHpricot.new
        File.open(@@path) do |fh|
          @@patinfo = @@writer.extract(Hpricot(fh), name: "Cimifemin® forte Tabletten")
        end
      end
      def test_patinfo
        assert_equal(ODDB::PatinfoDocument, @@patinfo.class)
      end
      def test_title
        assert_nil(@@writer.title)
      end
      def test_name
        assert_match(/Cimifemin/, @@writer.name.heading)
      end
      def test_chapters
        ODDB::PatinfoDocument2001::CHAPTERS.each do |chapter|
          begin
            res = eval("@@writer.#{chapter}")
          rescue => error
            puts "For 56933_pi_de_Cimifemin.html chapter #{chapter} is not defined"
          end
        end
      end
    end
  end
end
