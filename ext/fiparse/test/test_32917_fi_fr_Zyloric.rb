#!/usr/bin/env ruby
$: << File.expand_path("../src", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))
require "minitest/autorun"
require "fiparse"
require "flexmock/minitest"
require "util/workdir"

module ODDB
  class FachinfoDocument
    def odba_id
      1
    end
  end
  module FiParse
    class TestFachinfoZyloricFr < Minitest::Test
      def setup
        return if defined?(@@path) && defined?(@@fachinfo) && @@fachinfo
        @@path = File.join(File.dirname(__FILE__), "data", "html", "32917_fi_fr_Zyloric.html")
        @parser = ODDB::FiParse
        @@fachinfo =  @parser.parse_fachinfo_html(File.read(@@path), lang: "fr")
      end
      def test_fachinfo
        assert_equal(ODDB::FachinfoDocument2001, @@fachinfo.class)
      end
      def test_name
        assert_equal("Zyloric®", @@fachinfo.name)
      end
      def test_chapters
        ODDB::FachinfoDocument2001::CHAPTERS.each do |chapter|
          begin
            res = eval("@@fachinfo.#{chapter}")
          rescue => error
            puts "For 32917_fi_fr_Zyloric.html chapter #{chapter} is not defined"
          end
        end
      end
    end
  end
end
