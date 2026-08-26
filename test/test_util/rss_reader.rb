#!/usr/bin/env ruby
# TestRssReader -- oddb.org -- 26.08.2026

$LOAD_PATH.unshift File.expand_path("../..", __dir__)
$LOAD_PATH.unshift File.expand_path("../../src", __dir__)

require "minitest/autorun"
require "tmpdir"
require "util/rss_reader"

module ODDB
  class TestRssReader < Minitest::Test
    FEED = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel>
          <title>Chargenrückrufe</title>
          <description>Rückrufe von Swissmedic</description>
          <item>
            <title>Chargenrückruf &amp;ndash; Movicol</title>
            <link>https://ch.oddb.org/de/gcc/show/reg/53869</link>
            <description>Swissmedic-Registration 53869</description>
            <pubDate>Wed, 13 Aug 2026 00:00:00 +0200</pubDate>
          </item>
          <item>
            <title>Zweiter Eintrag</title>
            <link>https://ch.oddb.org/de/gcc/show/reg/11111</link>
            <description>&lt;br&gt;</description>
            <pubDate>Mon, 04 Aug 2026 00:00:00 +0200</pubDate>
          </item>
          <item>
            <title>Dritter Eintrag</title>
            <link>https://ch.oddb.org/de/gcc/show/reg/22222</link>
            <pubDate>Fri, 01 Aug 2026 00:00:00 +0200</pubDate>
          </item>
        </channel>
      </rss>
    XML

    def with_feed(body = FEED)
      Dir.mktmpdir { |dir|
        path = File.join(dir, "recall.rss")
        File.write(path, body)
        yield path
      }
    end

    def test_reads_channel_and_items
      with_feed { |path|
        reader = RssReader.new(path)
        assert_equal("Chargenrückrufe", reader.title)
        assert_equal("Rückrufe von Swissmedic", reader.description)
        assert_equal(3, reader.items.size)
        assert_equal("https://ch.oddb.org/de/gcc/show/reg/53869", reader.items.first.link)
      }
    end

    def test_unescapes_entities_in_the_title
      with_feed { |path|
        assert_equal("Chargenrückruf &ndash; Movicol", RssReader.new(path).items.first.title)
      }
    end

    def test_parses_the_date
      with_feed { |path|
        assert_equal("13.08.2026", RssReader.new(path).items.first.date.strftime("%d.%m.%Y"))
      }
    end

    # Der ganze Zweck der Klasse: fachinfo.rss ist 248 MB gross. Wer nach
    # fuenfzig Eintraegen aufhoert, darf den Rest nicht gelesen haben.
    def test_stops_at_the_limit
      with_feed { |path|
        assert_equal(1, RssReader.new(path, 1).items.size)
      }
    end

    # Beschreibungen der Preis-Feeds sind ganze HTML-Seiten von rund 28 KB.
    def test_drops_a_whole_html_document_as_description
      body = FEED.sub("Swissmedic-Registration 53869",
        "&lt;!DOCTYPE HTML&gt;&lt;HTML&gt;&lt;BODY&gt;viel&lt;/BODY&gt;&lt;/HTML&gt;")
      with_feed(body) { |path|
        assert_nil(RssReader.new(path).items.first.description)
      }
    end

    def test_drops_an_overlong_description
      body = FEED.sub("Swissmedic-Registration 53869", "x" * (RssReader::MAX_DESCRIPTION + 1))
      with_feed(body) { |path|
        assert_nil(RssReader.new(path).items.first.description)
      }
    end

    # &lt;br&gt; ist der uebliche Inhalt bei hpc.rss und bleibt nach dem
    # Entfernen der Tags leer - dann lieber gar nichts anzeigen.
    def test_drops_a_description_that_is_only_markup
      with_feed { |path|
        assert_nil(RssReader.new(path).items[1].description)
      }
    end

    def test_survives_a_missing_field
      with_feed { |path|
        item = RssReader.new(path).items.last
        assert_equal("Dritter Eintrag", item.title)
        assert_nil(item.description)
      }
    end

    def test_a_missing_file_is_not_an_error
      reader = RssReader.new("/gibt/es/nicht.rss")
      refute(reader.exist?)
      assert_empty(reader.items)
    end
  end
end
