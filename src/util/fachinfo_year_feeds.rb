#!/usr/bin/env ruby

# ODDB::FachinfoYearFeeds -- oddb.org -- 27.08.2026
#
# Die Jahresfeeds fachinfo-<jahr>.rss aus den Aenderungen selbst, nicht aus
# dem Bestand.
#
# Bis hierher baute Plugin#update_yearly_fachinfo_feeds sie aus
# app.sorted_fachinfos, also aus den heutigen Fachinformationen, sortiert nach
# dem Jahr ihrer letzten Revision. Jede Fachinfo hat genau ein revision-Datum,
# also landete jede in genau einem Jahr - eine Aufteilung des Bestands, keine
# Geschichte. Gemessen am 27.08.2026: ueber alle Jahresdateien zusammen 5053
# verschiedene Fachinfos, davon drei in mehr als einem Jahr. Und weil ein Jahr
# nur behaelt, was seither nicht wieder angefasst wurde, schrumpfen die alten:
# der Massenreparse vom Februar 2026 zog 2191 Dokumente aus ihren frueheren
# Jahren heraus, so dass 2025 auf 66 Eintraege fiel und 2026 auf 2871 stieg.
#
# Die Geschichte liegt im change_log der Dokumente - dieselbe Quelle, aus der
# die /diff/-Seiten kommen. Ein Eintrag ist hier eine Aenderung mit ihrem
# Datum und verweist auf den Diff, nicht auf die Fachinformation.
#
# Ein Eintrag je Fachinfo und Datum, nicht je Registrierung: eine Fachinfo
# gehoert im Schnitt zu 2.3 Registrierungen, und der Text hat sich einmal
# geaendert, nicht zweimal. Verlinkt wird ueber eine davon.

require "cgi"
require "fileutils"
require "time"

module ODDB
  class FachinfoYearFeeds
    Entry = Struct.new(:date, :iksnr, :name)

    # Feedverzeichnis => Sprache des Dokuments. data/rss kennt de, fr und en;
    # eine englische Fachinformation gibt es nicht, der englische Feed trug
    # immer schon den deutschen Bestand.
    LANGUAGES = {
      "de" => "de",
      "fr" => "fr",
      "en" => "de"
    }.freeze

    CHANNELS = {
      "de" => ["Fachinfo-Online von ODDB.org",
        "Neue und geänderte Fachinformtionen im Schweizer Gesundheitsmarkt"],
      "fr" => ["IPro-Online chez ODDB.org",
        "Informations professionnelles nouvelles et actualisées sur le marché de santé suisse."],
      "en" => ["DocInfo-Online on ODDB.org",
        "New and modified information for professionals in the Swiss Healthcare Market"]
    }.freeze

    ROOT_URL = "https://ch.oddb.org"

    attr_reader :counts

    def initialize(app, root:, logger: nil)
      @app = app
      @root = root
      @logger = logger
      @counts = Hash.new(0)
    end

    # => { "de" => { 2015 => [Entry, ...] } }
    def collect(limit: nil)
      buckets = {}
      seen = {}
      list = @app.sorted_fachinfos
      list = list.first(limit) if limit
      list.each_with_index { |fi, index|
        reg = registration_for(fi)
        next unless reg
        iksnr = value(reg, :iksnr)
        next unless iksnr
        name = value(reg, :name_base).to_s
        LANGUAGES.each_value.to_a.uniq.each { |lang|
          each_change_date(fi, lang) { |date|
            key = [lang, iksnr, date]
            next if seen[key]
            seen[key] = true
            @counts[:entries] += 1
            (buckets[lang] ||= {})[date.year] ||= []
            buckets[lang][date.year] << Entry.new(date, iksnr, name)
          }
        }
        @counts[:fachinfos] += 1
        # Ein FachinfoDocument traegt den ganzen Text, ein ChangeLogItem den
        # alten und den neuen. Wer sie nur liest, muss sie wieder loslassen -
        # ohne das stand der Prozess nach 1500 Fachinfos bei 2.7 GB und waere
        # bei allen 6287 ueber zehn gelandet. odba_retire ersetzt das Objekt
        # bei allen, die es halten, durch seinen Stub; das ist, was ODBA
        # selbst tut, wenn der Speicher knapp wird, und schreibt nichts.
        retire(fi)
        progress(index + 1) if @logger
      }
      buckets
    end

    def write(buckets, apply: false)
      written = 0
      LANGUAGES.each { |dir, lang|
        years = buckets[lang]
        next unless years
        years.each { |year, entries|
          path = File.join(@root, dir, "fachinfo-#{year}.rss")
          write_feed(path, dir, entries) if apply
          written += 1
        }
      }
      written
    end

    private

    def progress(done)
      return unless (done % 250).zero?
      @logger.call("  #{done} Fachinfos, #{@counts[:entries]} Einträge")
    end

    # Eine Fachinfo gehoert zu mehreren Registrierungen. Verlinkt wird ueber
    # die, die auch auf sie zurueckzeigt - eine Registrierung kann eine
    # fremde Fachinfo tragen, wenn eine Referenz verwaist ist.
    def registration_for(fachinfo)
      regs = begin
        Array(fachinfo.registrations)
      rescue
        []
      end
      regs.find { |reg|
        begin
          reg.respond_to?(:iksnr) && reg.fachinfo.equal?(fachinfo)
        rescue
          false
        end
      } || regs.find { |reg| reg.respond_to?(:iksnr) }
    end

    def value(object, method)
      object.send(method)
    rescue
      nil
    end

    def each_change_date(fachinfo, lang)
      document = value(fachinfo, lang.to_sym)
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

    def retire(object)
      id = value(object, :odba_id)
      return unless id
      ODBA.cache.fetch_cache_entry(id)&.odba_retire(force: true)
    rescue
      nil
    end

    def write_feed(path, dir, entries)
      title, description = CHANNELS[dir]
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
          fh.puts "      <link>#{CGI.escapeHTML(diff_url(dir, entry))}</link>"
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

    def diff_url(dir, entry)
      "#{ROOT_URL}/#{dir}/gcc/show/fachinfo/#{entry.iksnr}/diff/" +
        entry.date.strftime("%d.%m.%Y")
    end
  end
end
