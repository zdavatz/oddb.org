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
    class TestPatinfoPonstanDe < Minitest::Test
      def setup
        return if defined?(@@path) && defined?(@@patinfo) && @@patinfo
        @@path = File.join(File.dirname(__FILE__), "data", "html", "30785_pi_de_Ponstan.html")
        @@writer = PatinfoHpricot.new
        File.open(@@path) do |fh|
          @@patinfo = @@writer.extract(Hpricot(fh), type: :pi)
        end
      end
      def test_patinfo
        assert_equal(ODDB::PatinfoDocument, @@patinfo.class)
      end
      def test_title
        assert_equal("Ponstan", @@writer.title)
      end
      def test_name
        assert_equal("Ponstan", @@writer.name.heading)
      end
      def test_chapters
        ODDB::PatinfoDocument2001::CHAPTERS.each do |chapter|
          begin
            res = eval("@@writer.#{chapter}")
          rescue => error
            puts "For 30785_pi_de_Ponstan.html chapter #{chapter} is not defined"
          end
        end
      end
    end
  end
end
