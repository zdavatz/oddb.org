#!/usr/bin/env ruby

# ODDB::YearFeeds -- oddb.org -- 30.08.2026
#
# Der gemeinsame Unterbau der Jahresfeeds. FachinfoYearFeeds gab es seit dem
# 27.08.2026; als dasselbe fuer die Patienteninformationen dazukam, waren es
# zwei Klassen mit demselben Rumpf und drei Unterschieden: woher die Dokumente
# kommen, wie ein Eintrag verlinkt wird und wie die Datei heisst.
#
# Was hier steht, ist der Rumpf. Eine Unterklasse liefert BASE_NAME, CHANNELS,
# #collect und #link_for.
#
# Warum ueberhaupt Jahresdateien aus dem change_log und nicht aus dem Bestand:
# ein Dokument traegt genau ein revision-Datum, also landete es in genau einem
# Jahr - eine Aufteilung des Bestands, keine Geschichte. Die Geschichte liegt
# im change_log, dort, wo auch die /diff/-Seiten herkommen.

require "cgi"
require "fileutils"
require "time"

module ODDB
  class YearFeeds
    # Ein Eintrag ist eine Aenderung an einem Tag. seqnr und ikscd bleiben bei
    # den Fachinformationen leer - dort adressiert die Registrierungsnummer
    # allein den Diff, bei den Patienteninformationen braucht es Sequenz und
    # Packung dazu.
    Entry = Struct.new(:date, :iksnr, :name, :seqnr, :ikscd)

    # Feedverzeichnis => Sprache des Dokuments. data/rss kennt de, fr und en;
    # eine englische Fach- oder Patienteninformation gibt es nicht, der
    # englische Feed trug immer schon den deutschen Bestand. Italienische
    # Dokumente gibt es, ein data/rss/it nicht.
    LANGUAGES = {
      "de" => "de",
      "fr" => "fr",
      "en" => "de"
    }.freeze

    ROOT_URL = "https://ch.oddb.org"

    attr_reader :counts

    def initialize(app, root:, logger: nil)
      @app = app
      @root = root
      @logger = logger
      @counts = Hash.new(0)
    end

    def base_name
      self.class::BASE_NAME
    end

    def channels
      self.class::CHANNELS
    end

    # => { "de" => { 2015 => [Entry, ...] } }
    def collect(limit: nil)
      raise NotImplementedError
    end

    def link_for(dir, entry)
      raise NotImplementedError
    end

    def write(buckets, apply: false)
      written = 0
      LANGUAGES.each { |dir, lang|
        years = buckets[lang]
        next unless years
        years.each { |year, entries|
          path = File.join(@root, dir, "#{base_name}-#{year}.rss")
          write_feed(path, dir, entries) if apply
          written += 1
        }
      }
      written
    end

    # Die kleine Datei neben den Jahresdateien: <base>.rss mit den neuesten
    # Eintraegen. Die HTML-Ansicht liest sie nie - die steigt beim neuesten
    # Jahr ein -, aber /rss/channel/<base>.rss zeigt darauf, und ohne die
    # Datei antwortet der Abonnent-Link mit 404.
    def write_latest(buckets, apply: false, limit: 50)
      written = 0
      LANGUAGES.each { |dir, lang|
        years = buckets[lang]
        next unless years
        entries = years.values.flatten
          .sort_by { |entry| [entry.date, entry.name.to_s] }.reverse.first(limit)
        next if entries.empty?
        path = File.join(@root, dir, "#{base_name}.rss")
        write_feed(path, dir, entries) if apply
        written += 1
      }
      written
    end

    # Fuer app.rss_updates, das die Startseite ausliest: der neueste Tag und
    # wie viele Aenderungen in dessen Monat fallen.
    def latest(buckets, lang: "de")
      years = buckets[lang]
      return nil if years.nil? || years.empty?
      entries = years.values.flatten
      newest = entries.collect(&:date).max
      return nil unless newest
      [newest, entries.count { |entry|
        entry.date.year == newest.year && entry.date.month == newest.month
      }]
    end

    private

    def progress(done, unit)
      return unless @logger && (done % 250).zero?
      @logger.call("  #{done} #{unit}, #{@counts[:entries]} Einträge")
    end

    def value(object, method)
      object.send(method)
    rescue
      nil
    end

    # Ein Dokument traegt den ganzen Text, ein ChangeLogItem den alten und den
    # neuen. Wer sie nur liest, muss sie wieder loslassen - ohne das stand der
    # Fachinfo-Lauf nach 1500 Dokumenten bei 2.7 GB und waere bei allen 6287
    # ueber zehn Gigabyte gelandet. odba_retire ersetzt das Objekt bei allen,
    # die es halten, durch seinen Stub; das ist, was ODBA selbst tut, wenn der
    # Speicher knapp wird, und schreibt nichts.
    def retire(object)
      id = value(object, :odba_id)
      return unless id
      ODBA.cache.fetch_cache_entry(id)&.odba_retire(force: true)
    rescue
      nil
    end

    # Nicht holder.send(lang): SimpleLanguage#description faellt auf die erste
    # vorhandene Sprache zurueck, wenn die gewuenschte fehlt (language.rb:33).
    # Ein Dokument ohne franzoesischen Text lieferte damit seine deutsche
    # Geschichte in den franzoesischen Feed.
    def document_for(holder, lang)
      descriptions = value(holder, :descriptions)
      return value(holder, lang.to_sym) unless descriptions.respond_to?(:[])
      descriptions[lang]
    end

    def each_change_date(holder, lang)
      document = document_for(holder, lang)
      return unless document.respond_to?(:change_log)
      log = begin
        Array(document.change_log)
      rescue
        []
      end
      log.each { |item|
        time = value(item, :time)
        yield(time.to_date) if time.respond_to?(:year)
        retire(item)
      }
      retire(log)
      retire(document)
    end

    def write_feed(path, dir, entries)
      title, description = channels[dir]
      FileUtils.mkdir_p(File.dirname(path))
      tmp = File.join(File.dirname(path), "." + File.basename(path))
      File.open(tmp, "w:utf-8") { |fh|
        fh.puts %(<?xml version="1.0" encoding="UTF-8"?>)
        fh.puts %(<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">)
        fh.puts "  <channel>"
        fh.puts "    <title>#{CGI.escapeHTML(title)}</title>"
        fh.puts "    <link>#{ROOT_URL}/#{dir}/gcc/home/</link>"
        fh.puts "    <description>#{CGI.escapeHTML(description)}</description>"
        entries.sort_by { |entry| [entry.date, entry.name.to_s] }.reverse_each { |entry|
          fh.puts "    <item>"
          fh.puts "      <title>#{CGI.escapeHTML(entry.name.to_s)}</title>"
          fh.puts "      <link>#{CGI.escapeHTML(link_for(dir, entry))}</link>"
          # Genau die Form, die View::Rss::HtmlFeedComposite erkennt: dann
          # steht die Nummer in einer eigenen Spalte statt in jeder Zeile.
          fh.puts "      <description>Swissmedic-Registration #{entry.iksnr}</description>"
          fh.puts "      <author>ODDB.org</author>"
          fh.puts "      <pubDate>#{entry.date.to_time.rfc2822}</pubDate>"
          fh.puts "      <dc:date>#{entry.date.to_time.utc.iso8601}</dc:date>"
          fh.puts "    </item>"
        }
        fh.puts "  </channel>"
        fh.puts "</rss>"
      }
      FileUtils.mv(tmp, path)
    end
  end
end
