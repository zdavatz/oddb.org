#!/usr/bin/env ruby

# Monthly archives of sl_introduction, price_cut and price_rise, built from
# the packages' price history: <kind>-YYYY-MM.rss beside the live feed.
#
# Why not from the feeds: Plugin#update_price_feeds computes a one-month
# window and overwrites the three files on every run. The only source for
# anything older is the price history on the Package objects.
#
# Why not through View::Rss::Package: it works with price_public(0) and (1),
# today's pair. An archive built through it would show today's price under a
# date in 2019. The entries here come from the pair that was valid then.
#
# jobs/build_price_archives was the one-off of 26.08.2026 and held all of
# this itself. Nothing wrote an archive afterwards, and the /rss_html/ pages,
# which assemble the newest year from these files, still ended at August on
# 2 October. Updater#update_price_feeds now calls this for the month it has
# just written.

require "cgi"
require "fileutils"
require "time"

module ODDB
  class PriceArchives
    KINDS = {
      sl_introduction: ["SL Neuaufnahmen", "Neuaufnahme von Produkten in die Spezialitäten-Liste"],
      price_cut: ["Preissenkungen SL/LPPV", "Preissenkungen von Produkten in der Spezialitäten-Liste"],
      price_rise: ["Preiserhöhungen SL/LPPV", "Preiserhöhungen von Produkten in der Spezialitäten-Liste"]
    }
    MAX_HISTORY = 500 # guard against a broken chain

    attr_reader :packs, :changes

    def initialize(app, root:)
      @app = app
      @root = root
      @packs = 0
      @changes = 0
    end

    # kind => { "YYYY-MM" => [entry, ...] }. With +months+ (an array of
    # "YYYY-MM") only those are kept; one pass over all packages either way.
    def collect(months: nil)
      buckets = KINDS.keys.to_h { |kind| [kind, {}] }
      @app.each_package { |pack|
        @packs += 1
        history = []
        index = 0
        while (price = pack.price_public(index))
          history << price
          index += 1
          break if index > MAX_HISTORY
        end
        next if history.empty?
        # history[0] is the newest. Compare from old to new.
        history = history.reverse
        history.each_with_index { |price, i|
          valid = price.valid_from
          next unless valid
          previous = (i > 0) ? history[i - 1] : nil
          kind = if previous.nil?
            (price.authority == :sl) ? :sl_introduction : nil
          elsif previous > price
            :price_cut
          elsif price > previous
            :price_rise
          end
          next unless kind
          month = valid.strftime("%Y-%m")
          next if months && !months.include?(month)
          @changes += 1
          percent = if previous && previous.to_f > 1e-10
            (price - previous) / previous.to_f * 100.0
          end
          (buckets[kind][month] ||= []) << {
            date: valid,
            name: pack.name.to_s,
            size: pack.size.to_s,
            price: price,
            percent: percent,
            iksnr: pack.iksnr, seqnr: pack.seqnr, ikscd: pack.ikscd
          }
        }
      }
      buckets
    end

    # Writes one file per kind, month and language directory. Returns the
    # number of files written.
    def write(buckets)
      written = 0
      Dir.glob(File.join(@root, "*")).select { |d| File.directory?(d) }.each { |dir|
        buckets.each { |kind, months|
          title, description = KINDS.fetch(kind)
          months.each { |month, entries|
            write_feed(File.join(dir, "#{kind}-#{month}.rss"), title, description, entries)
            written += 1
          }
        }
      }
      written
    end

    private

    def write_feed(path, title, description, entries)
      FileUtils.mkdir_p(File.dirname(path))
      tmp = File.join(File.dirname(path), "." + File.basename(path))
      File.open(tmp, "w:utf-8") { |fh|
        fh.puts %(<?xml version="1.0" encoding="UTF-8"?>)
        fh.puts %(<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">)
        fh.puts "  <channel>"
        fh.puts "    <title>#{CGI.escapeHTML(title)}</title>"
        fh.puts "    <link>https://ch.oddb.org/de/gcc/home/</link>"
        fh.puts "    <description>#{CGI.escapeHTML(description)}</description>"
        entries.sort_by { |e| e[:date] }.reverse_each { |e|
          head = e[:date].strftime("%d.%m.%Y")
          parts = [e[:name], e[:size], e[:price].to_s]
          parts << format("%+.1f%%", e[:percent]) if e[:percent]
          title_line = "#{head}: #{parts.reject(&:empty?).join(", ")}"
          url = "https://ch.oddb.org/de/gcc/show/reg/#{e[:iksnr]}/seq/#{e[:seqnr]}/pack/#{e[:ikscd]}"
          fh.puts "    <item>"
          fh.puts "      <title>#{CGI.escapeHTML(title_line)}</title>"
          fh.puts "      <link>#{CGI.escapeHTML(url)}</link>"
          fh.puts "      <author>ODDB.org</author>"
          fh.puts "      <pubDate>#{e[:date].to_time.rfc2822}</pubDate>"
          # getutc, not utc: Time#utc converts the receiver in place, and the
          # same entry is written once per language. Until 02.10.2026 the
          # first directory got "01.08.2026 ... +0200" and every later one
          # "31.07.2026 ... -0000" - the previous month.
          fh.puts "      <dc:date>#{e[:date].to_time.getutc.iso8601}</dc:date>"
          fh.puts "    </item>"
        }
        fh.puts "  </channel>"
        fh.puts "</rss>"
      }
      FileUtils.mv(tmp, path)
    end
  end
end
