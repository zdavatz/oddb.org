#!/usr/bin/env ruby

# State::Rss::Html -- oddb.org -- 26.08.2026

require "state/drugs/global"
require "util/rss_reader"
require "view/rss/html"

module ODDB
  module State
    module Rss
      class Html < State::Drugs::Global
        VIEW = View::Rss::HtmlFeed
        DIRECT_EVENT = :rss_html
        VOLATILE = true

        # Was der Leser sieht. Der Feed selbst hat je nach Kanal einige tausend
        # Eintraege; fuer eine Uebersichtsseite sind das die letzten fuenfzig.
        LIMIT = 50

        class Feed
          attr_reader :title, :description, :items, :channel
          def initialize(reader, channel, fallback_title)
            @channel = channel
            @title = reader.title || fallback_title
            @description = reader.description
            @items = reader.items
          end
        end

        def initialize(session, channel)
          super(session, nil)
          @channel = channel
        end

        def init
          path = File.join(RSS_PATH, @session.language, @channel)
          reader = ODDB::RssReader.new(path, LIMIT)
          @model = Feed.new(reader, @channel, @channel.sub(/\.rss\z/, ""))
        end
      end
    end
  end
end
