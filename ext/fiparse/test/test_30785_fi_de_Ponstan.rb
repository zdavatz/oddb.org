#!/usr/bin/env ruby
$: << File.expand_path("../src", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))
require "minitest/autorun"
require "fiparse"
require "flexmock/minitest"
require "util/workdir"
require "model/fachinfo"
module ODDB
  class FachinfoDocument
    def odba_id
      1
    end
  end
  module FiParse
    class TestFachinfoPonstande < Minitest::Test
      def setup
        return if defined?(@@path) && defined?(@@fachinfo) && @@fachinfo
        @@path = File.join(File.dirname(__FILE__), "data", "html", "30785_fi_de_Ponstan.html")
        @@writer = FachinfoHpricot.new
        File.open(@@path) do |fh|
          @@fachinfo = @@writer.extract(Hpricot(fh), name: "Ponstan")
        end
      end
      def test_fachinfo
        assert_equal(ODDB::FachinfoDocument2001, @@fachinfo.class)
      end
      def test_name
        assert_equal("Ponstan", @@writer.name.heading)
      end
      def test_title
        assert_nil(@@writer.title)
      end
      def test_chapters
        ODDB::FachinfoDocument::CHAPTERS.each do |chapter|
          begin
            res = eval("@@writer.#{chapter}")
          rescue => error
            puts "For #{File.basename(@@path)} chapter #{chapter} is not defined"
          end
        end
      end
    end
  end
end
