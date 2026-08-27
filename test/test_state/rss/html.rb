#!/usr/bin/env ruby

# ODDB::State::Rss::TestHtml -- oddb.org -- 27.08.2026

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "fileutils"
require "tmpdir"
require "util/oddbconfig"
require "state/rss/html"

module ODDB
  module State
    module Rss
      class TestHtml < Minitest::Test
        @@saved = ODDB::RSS_PATH

        def setup
          eval("ODDB::RSS_PATH = Dir.mktmpdir")
          @dir = File.join(RSS_PATH, "de")
          FileUtils.makedirs(@dir)
          super
        end

        def teardown
          FileUtils.rm_rf(RSS_PATH)
          eval("ODDB::RSS_PATH = '#{@@saved}'")
          super
        end

        def write_feed(name, dates)
          items = dates.collect { |date|
            "    <item>\n" \
            "      <title>Eintrag #{date}</title>\n" \
            "      <link>http://example.com/#{date}</link>\n" \
            "      <description>Beschreibung</description>\n" \
            "      <pubDate>#{Time.parse(date).rfc822}</pubDate>\n" \
            "    </item>\n"
          }.join
          File.write(File.join(@dir, name),
            "<?xml version=\"1.0\"?>\n<rss version=\"2.0\">\n  <channel>\n" \
            "    <title>Testkanal</title>\n    <description>Test</description>\n" \
            "#{items}  </channel>\n</rss>\n")
        end

        def state(year = nil)
          session = flexmock("session", language: "de")
          session.should_receive(:user_input).with(:year).and_return(year)
          state = ODDB::State::Rss::Html.new(session, "price_cut.rss")
          state.init
          state.model
        end

        # Der Fehler, um den es geht: update_price_feeds ueberschreibt
        # price_cut.rss bei jedem Lauf mit einem Fenster von einem Monat. Wer
        # die Einstiegsseite aus dieser Datei speiste, sah Juli und hielt
        # Januar bis Juni fuer verloren, obwohl die Monatsarchive danebenlagen.
        def test_default_shows_the_whole_newest_year
          write_feed("price_cut.rss", ["2026-07-01"])
          write_feed("price_cut-2026-01.rss", ["2026-01-01"])
          write_feed("price_cut-2026-06.rss", ["2026-06-01"])
          write_feed("price_cut-2026-07.rss", ["2026-07-01"])
          write_feed("price_cut-2025-12.rss", ["2025-12-01"])
          model = state
          assert_equal(2026, model.year)
          assert_equal([1, 6, 7], model.items.collect { |i| i.date.month }.sort)
          assert_equal([2026, 2025], model.years)
        end

        def test_requested_year_wins
          write_feed("price_cut.rss", ["2026-07-01"])
          write_feed("price_cut-2026-01.rss", ["2026-01-01"])
          write_feed("price_cut-2025-12.rss", ["2025-12-01"])
          model = state("2025")
          assert_equal(2025, model.year)
          assert_equal([2025], model.items.collect { |i| i.date.year }.uniq)
        end

        # Ein Jahr, das es nicht gibt, faellt auf das neueste zurueck und nicht
        # auf eine leere Seite.
        def test_unknown_year_falls_back_to_newest
          write_feed("price_cut.rss", ["2026-07-01"])
          write_feed("price_cut-2026-01.rss", ["2026-01-01"])
          assert_equal(2026, state("1999").year)
        end

        # fachinfo hat Jahresdateien statt Monatsarchiven, und die grosse
        # Datei (248 MB) wird nie angefasst. Auch dort ist die Einstiegsseite
        # das neueste Jahr und nicht der neueste Monat.
        def test_yearly_files_default_to_the_newest_year
          write_feed("fachinfo.rss", ["2026-08-01"])
          write_feed("fachinfo-2025.rss", ["2025-05-01"])
          write_feed("fachinfo-2026.rss", ["2026-01-01", "2026-04-01", "2026-08-01"])
          session = flexmock("session", language: "de")
          session.should_receive(:user_input).with(:year).and_return(nil)
          state = ODDB::State::Rss::Html.new(session, "fachinfo.rss")
          state.init
          assert_equal(2026, state.model.year)
          assert_equal([1, 4, 8], state.model.items.collect { |i| i.date.month }.sort)
          assert_equal([2026, 2025], state.model.years)
        end

        # Ein Kanal ganz ohne Archive: die Jahre kommen aus den Eintraegen,
        # und ohne Angabe steht auch hier das neueste Jahr.
        def test_single_file_defaults_to_newest_year
          write_feed("price_cut.rss", ["2026-07-01", "2025-03-01"])
          model = state
          assert_equal(2026, model.year)
          assert_equal([2026], model.items.collect { |i| i.date.year }.uniq)
        end
      end
    end
  end
end
