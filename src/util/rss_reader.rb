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

    # nil heisst: alles lesen. Fuer die Jahresansicht noetig, und vertretbar,
    # weil dort nie fachinfo.rss selbst gelesen wird, sondern die
    # Jahresdateien fachinfo-<jahr>.rss daneben.
    DEFAULT_LIMIT = 50

    # Beschreibungen der Preis-Feeds sind ganze HTML-Seiten von rund 28 KB -
    # der Feed traegt dort die gerenderte Detailansicht mit sich. Auf einer
    # Uebersicht ist das nichts wert, also fliegt alles raus, was nach einem
    # Dokument aussieht oder zu lang ist. Bei recall.rss bleiben rund 120
    # Zeichen echter Text uebrig, und der ist die Zeile wert.
    MAX_DESCRIPTION = 600

    # Eine Zeile, die laenger ist als das, kann kein Titel, kein Link und kein
    # Datum mehr sein - und als Beschreibung waere sie ohnehin verworfen.
    # fachinfo.rss traegt ganze Fachinformationen als je eine Zeile von
    # mehreren Megabyte, und vier Regex-Laeufe ueber so eine Zeile sind der
    # Unterschied zwischen 52 Sekunden und einer halben fuer ein Jahr.
    MAX_LINE = 8192

    # Ein einziger, am Zeilenanfang verankerter Ausdruck statt vier Suchen pro
    # Zeile. fachinfo-2026.rss hat 3.7 Millionen Zeilen, davon tragen ein paar
    # tausend ein Feld; alles andere ist der HTML-Text der Fachinformationen.
    # Verankert scheitert der Ausdruck nach wenigen Bytes, und das Lesen des
    # ganzen Jahres faellt von 52 auf gut eine Sekunde.
    FIELD = /\A\s*<(title|link|pubDate|description)>(.*)<\/\1>/m

    # Vorkompiliert, statt den Namen in jedes Muster zu interpolieren: ein
    # interpolierter Ausdruck wird bei jedem Aufruf neu uebersetzt.
    PATTERNS = {
      "title" => /<title>(.*)<\/title>/m,
      "description" => /<description>(.*)<\/description>/m
    }.freeze

    attr_reader :title, :description, :items, :path

    def initialize(path, limit = DEFAULT_LIMIT)
      @path = path
      @limit = limit
      @limit = nil if limit == :all
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
          # Die Einrueckung der Felder aus der Datei selbst nehmen, statt sie
          # anzunehmen: ein Feld steht zwei Stellen tiefer als sein <item>.
          # Damit wird aus dem Test pro Zeile ein Praefixvergleich, und der
          # Regex laeuft nur noch auf den paar tausend Zeilen, die ihn
          # brauchen - bei fachinfo-2026.rss sind es 20100 von 3.7 Millionen.
          @field_prefix ||= "#{line[/\A[ \t]*/]}  <"
          current = Item.new
          next
        end
        if line.include?("</item>")
          @items << current if current
          current = nil
          return if @limit && @items.size >= @limit
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
      return if line.bytesize > MAX_LINE
      return if @field_prefix && !line.start_with?(@field_prefix)
      md = FIELD.match(line)
      return unless md
      value = CGI.unescapeHTML(md[2].to_s).strip
      case md[1]
      when "title" then item.title ||= value
      when "link" then item.link ||= value
      when "pubDate" then item.date ||= parse_date(value)
      when "description" then item.description ||= usable_description(value)
      end
    end

    # Erst suchen, dann das Muster: include? ist ein Substring-Vergleich und
    # spart den Regex-Lauf auf allen Zeilen, die das Feld gar nicht tragen -
    # und das sind fast alle.
    def tag(line, name)
      return nil unless line.include?("<#{name}>")
      md = PATTERNS[name].match(line)
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
