#!/usr/bin/env ruby

# ODDB::View::Rss::TestHtml -- oddb.org -- 27.08.2026

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "view/rss/html"

module ODDB
  module View
    module Rss
      class TestHtmlFeedComposite < Minitest::Test
        # Die Preis-Feeds schreiben das Datum in den Titel, weil ein Feedleser
        # keine Spalten hat. In der Tabelle steht es schon in der ersten
        # Spalte - zweimal dasselbe Datum auf einer Zeile ist Laerm.
        def strip(title)
          title.sub(HtmlFeedComposite::DATE_PREFIX, "")
        end

        def test_strips_the_date_the_price_feeds_prefix
          assert_equal("OFEV 150 mg, Weichkapseln, 60 Kapsel(n), 1577.15, -24.8%",
            strip("01.08.2026: OFEV 150 mg, Weichkapseln, 60 Kapsel(n), 1577.15, -24.8%"))
        end

        # recall.rss und hpc.rss schreiben kein Datum in den Titel, und ein
        # Datum mitten im Titel ist Teil des Titels.
        def test_leaves_other_titles_alone
          ["Chargenrückruf Dafalgan 500 mg",
            "Swissmedic-Registration 12345",
            "Rückruf vom 01.08.2026 betreffend Charge 4711"].each do |title|
            assert_equal(title, strip(title))
          end
        end

        # Ein Datum ohne Doppelpunkt bleibt stehen - nur die Form, die die
        # Feeds selbst schreiben, wird entfernt.
        def test_needs_the_colon
          assert_equal("01.08.2026 OFEV 150 mg", strip("01.08.2026 OFEV 150 mg"))
        end
      end
    end
  end
end
