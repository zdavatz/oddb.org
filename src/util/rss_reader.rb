#!/usr/bin/env ruby

# ODDB::RssReader -- oddb.org -- 26.08.2026
#
# Liest die vorgefertigten Feeds unter data/rss/<sprache>/ zeilenweise und gibt
# die ersten n Eintraege zurueck.
#
# Zeilenweise, und nicht mit einem XML-Parser, aus einem einzigen Grund:
# fachinfo.rss ist 248 MB gross. Ein DOM davon im Speicher waere pro Aufruf ein
# Vielfaches davon, und gebraucht werden die ersten fuenfzig Eintraege. Die
# Feeds kommen aus RSS::Maker (plugin/rss.rb), sind also immer gleich
# eingerueckt und haben jedes Feld auf seiner eigenen Zeile - was das Lesen
# ohne Parser ueberhaupt erst vertretbar macht.

require "cgi"
require "time"

module ODDB
  class RssReader
    Item = Struct.new(:title, :link, :date, :description)

    DEFAULT_LIMIT = 50

    # Beschreibungen der Preis-Feeds sind ganze HTML-Seiten von rund 28 KB -
    # der Feed traegt dort die gerenderte Detailansicht mit sich. Auf einer
    # Uebersicht ist das nichts wert, also fliegt alles raus, was nach einem
    # Dokument aussieht oder zu lang ist. Bei recall.rss bleiben rund 120
    # Zeichen echter Text uebrig, und der ist die Zeile wert.
    MAX_DESCRIPTION = 600

    attr_reader :title, :description, :items, :path

    def initialize(path, limit = DEFAULT_LIMIT)
      @path = path
      @limit = limit
      @items = []
      @title = nil
      @description = nil
      read
    end

    def exist?
      File.exist?(@path)
    end

    private

    def read
      return unless exist?
      current = nil
      in_channel_header = true
      File.foreach(@path, encoding: "UTF-8") do |line|
        if line.include?("<item>")
          in_channel_header = false
          current = Item.new
          next
        end
        if line.include?("</item>")
          @items << current if current
          current = nil
          return if @items.size >= @limit
          next
        end
        if current
          collect(current, line)
        elsif in_channel_header
          @title ||= tag(line, "title")
          @description ||= tag(line, "description")
        end
      end
    rescue => error
      # Ein unlesbarer Feed darf die Seite nicht mitnehmen - dann eben leer.
      SBSM.error("RssReader #{@path}: #{error.class}: #{error.message}") if defined?(SBSM)
      @items = []
    end

    def collect(item, line)
      if (value = tag(line, "title"))
        item.title ||= value
      elsif (value = tag(line, "link"))
        item.link ||= value
      elsif (value = tag(line, "pubDate"))
        item.date ||= parse_date(value)
      elsif (value = tag(line, "description"))
        item.description ||= usable_description(value)
      end
    end

    def tag(line, name)
      md = /<#{name}>(.*)<\/#{name}>/m.match(line)
      return nil unless md
      CGI.unescapeHTML(md[1].to_s).strip
    end

    def usable_description(value)
      return nil if value.length > MAX_DESCRIPTION
      return nil if /<(!DOCTYPE|html|head|body)\b/i.match?(value)
      stripped = value.gsub(/<[^>]*>/, " ").gsub(/\s+/, " ").strip
      stripped.empty? ? nil : stripped
    end

    def parse_date(value)
      Time.rfc2822(value)
    rescue
      begin
        Time.parse(value)
      rescue
        nil
      end
    end
  end
end
