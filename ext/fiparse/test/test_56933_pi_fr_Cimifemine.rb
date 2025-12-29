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
    class TestPatinfoCimifemineFr < Minitest::Test
      def setup
        return if defined?(@@path) && defined?(@@patinfo) && @@patinfo
        @@path = File.join(File.dirname(__FILE__), "data", "html", "56933_pi_fr_Cimifemine.html")
        @parser = ODDB::FiParse
        @@patinfo =  @parser.parse_patinfo_html(File.read(@@path), lang: "fr")
      end
      def test_patinfo
        assert_equal(ODDB::PatinfoDocument, @@patinfo.class)
      end
      def test_name
        assert_equal('Cimifemine® forte comprimés', @@patinfo.name)
      end
      def test_chapters
        ODDB::PatinfoDocument2001::CHAPTERS.each do |chapter|
          begin
            res = eval("@@patinfo.#{chapter}")
          rescue => error
            puts "For 56933_pi_fr_Cimifemine.html chapter #{chapter} is not defined"
          end
        end
      end
    end
  end
end
