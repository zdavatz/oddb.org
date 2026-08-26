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

        # Ohne Jahresangabe die neuesten Eintraege. Mit Jahresangabe das ganze
        # Jahr, wie bei /recent_registrations/.
        LIMIT = 50

        class Feed
          attr_reader :title, :description, :items, :channel, :year, :years
          def initialize(reader, channel, fallback_title, year, years)
            @channel = channel
            @title = reader.title || fallback_title
            @description = reader.description
            @items = reader.items
            @year = year
            @years = years
          end

          def complete?
            !@year.nil?
          end
        end

        def initialize(session, channel)
          super(session, nil)
          @channel = channel
        end

        def init
          wanted = @session.user_input(:year).to_i
          wanted = nil if wanted.zero?

          if yearly_files.empty?
            # Ein einziger, kleiner Kanal (recall.rss: 188 KB, 226 Eintraege).
            # Einmal ganz lesen, daraus sowohl die Jahresliste als auch die
            # Eintraege - zweimal lesen waere die Datei zweimal.
            all = ODDB::RssReader.new(File.join(rss_dir, @channel), :all)
            years = all.items.filter_map { |item| item.date&.year }.uniq.sort.reverse
            year = years.include?(wanted) ? wanted : nil
            items = if year
              all.items.select { |item| item.date&.year == year }
            else
              all.items.first(LIMIT)
            end
            all.items.replace(items)
            reader = all
          else
            # fachinfo: die Jahresdateien liegen daneben, die grosse Datei
            # (248 MB) wird fuer eine Jahresansicht nie angefasst.
            years = yearly_files.keys.sort.reverse
            year = years.include?(wanted) ? wanted : nil
            reader = ODDB::RssReader.new(path_for(year), year ? :all : LIMIT)
            if year
              reader.items.replace(reader.items.select { |item| item.date&.year == year })
            end
          end

          @model = Feed.new(reader, @channel, @channel.sub(/\.rss\z/, ""), year, years)
        end

        private

        def rss_dir
          File.join(RSS_PATH, @session.language)
        end

        def base_name
          @channel.sub(/\.rss\z/, "")
        end

        # Zwei Formen von Geschichte. fachinfo.rss hat Jahresdateien neben sich
        # liegen - fachinfo-2006.rss bis fachinfo-2026.rss - und die grosse
        # Datei selbst ist 248 MB, die wird fuer eine Jahresansicht nie
        # angefasst. Die uebrigen Kanaele sind eine einzige, kleine Datei
        # (recall.rss 188 KB mit 226 Eintraegen); dort kommen die Jahre aus den
        # Daten der Eintraege.
        def yearly_files
          @yearly_files ||= Dir.glob(File.join(rss_dir, "#{base_name}-[0-9][0-9][0-9][0-9].rss"))
            .each_with_object({}) { |path, memo|
              if (md = /-(\d{4})\.rss\z/.match(path))
                memo[md[1].to_i] = path
              end
            }
        end

        def path_for(year)
          return File.join(rss_dir, @channel) unless year
          yearly_files[year] || File.join(rss_dir, @channel)
        end
      end
    end
  end
end
