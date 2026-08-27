#!/usr/bin/env ruby

# ODDB::TestLinkedInApi -- oddb.org -- 27.08.2026

$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))

require "minitest/autorun"
require "util/linkedin_api"

module ODDB
  class TestLinkedInApiEscape < Minitest::Test
    def escape(text)
      LinkedInApi.escape(text)
    end

    # Der Fehler, um den es geht: LinkedIn liest commentary als Auszeichnung
    # und wirft unmaskierte Sonderzeichen weg. Ein Unterstrich steckt in fast
    # jeder unserer Adressen, und der Beitrag sieht danach richtig aus - nur
    # der Link zeigt ins Leere.
    def test_underscores_in_a_url_survive
      assert_equal("https://ch.oddb.org/de/gcc/rss\\_html/channel/price\\_cut.rss",
        escape("https://ch.oddb.org/de/gcc/rss_html/channel/price_cut.rss"))
    end

    def test_every_reserved_character
      "|{}@[]()<>*_~".each_char { |char|
        assert_equal("\\#{char}", escape(char), char)
      }
    end

    # Der Backslash zuerst, sonst maskiert er die eigenen Maskierungen.
    def test_backslash_is_escaped_first
      assert_equal("\\\\\\_", escape("\\_"))
    end

    # Schlagworte bleiben Schlagworte: maskiert waere '#' ein gewoehnliches
    # Doppelkreuz und '#Generika' nur noch Text.
    def test_hash_is_left_alone
      assert_equal("#Generika #OpenData", escape("#Generika #OpenData"))
    end

    def test_ordinary_text_is_untouched
      ["Preissenkungen SL/LPPV", "−23.3 %", "OFEV 150 mg", "Zeno Davatz",
        "https://ch.oddb.org/de/gcc/home/"].each { |text|
        assert_equal(text, escape(text))
      }
    end

    def test_nil_becomes_empty
      assert_equal("", escape(nil))
    end
  end
end
