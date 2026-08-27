#!/usr/bin/env ruby

# View::Rss::Html -- oddb.org -- 26.08.2026
#
# Die HTML-Ansicht der Feeds. Ein Feed ist fuer einen Leser gemacht, nicht fuer
# einen Menschen: wer auf der Startseite auf "37 SL Neuaufnahmen" klickt, bekam
# XML zu sehen. Diese Ansicht liest denselben Feed und stellt ihn im Aussehen
# der Seite dar.
#
# Sie erfindet nichts nach: die Quelle bleibt die Datei unter data/rss/, die
# plugin/rss.rb schreibt.

require "cgi"
require "view/privatetemplate"
require "view/searchbar"

module ODDB
  module View
    module Rss
      class HtmlFeedComposite < HtmlGrid::Composite
        COMPONENTS = {
          [0, 0] => :breadcrumbs,
          [0, 1] => :feed_title,
          [0, 2] => :year_chooser,
          [0, 3] => :feed_items
        }
        CSS_CLASS = "composite"
        CSS_MAP = {
          [0, 1] => "th",
          [0, 2] => "atc list date-chooser"
        }
        LEGACY_INTERFACE = false

        def breadcrumbs(model, session = @session)
          home = HtmlGrid::Link.new(:back_to_home, model, @session, self)
          home.href = @lookandfeel._event_url(:home)
          home.css_class = "list"
          span = HtmlGrid::Span.new(model, @session, self)
          span.css_class = "breadcrumb bold"
          span.value = home
          sep = HtmlGrid::Span.new(model, @session, self)
          sep.css_class = "breadcrumb"
          sep.value = "&lt;"
          here = HtmlGrid::Span.new(model, @session, self)
          here.css_class = "breadcrumb"
          here.value = CGI.escapeHTML([model.title.to_s, period(model)].compact.join(" – "))
          [span, sep, here]
        end

        # Im Titel steht, welcher Zeitraum zu sehen ist - sonst weiss niemand,
        # ob die Liste den laufenden Monat oder zwei Jahre zeigt.
        def feed_title(model)
          parts = [CGI.escapeHTML(model.title.to_s)]
          if (span = period(model))
            parts << CGI.escapeHTML(span)
          end
          descr = model.description.to_s
          # Bei recall.rss und hpc.rss sind Titel und Beschreibung dasselbe Wort.
          parts << CGI.escapeHTML(descr) if !descr.empty? && descr != model.title.to_s
          parts.join(" &ndash; ")
        end

        # "August 2026", wenn alles aus einem Monat kommt; "2026" innerhalb
        # eines Jahres; sonst von wann bis wann.
        def period(model)
          dates = model.items.filter_map(&:date)
          return nil if dates.empty?
          first, last = dates.min, dates.max
          if first.year == last.year && first.month == last.month
            "#{month_name(first.month)} #{first.year}"
          elsif first.year == last.year
            "#{month_name(first.month)} – #{month_name(last.month)} #{first.year}"
          else
            "#{month_name(first.month)} #{first.year} – #{month_name(last.month)} #{last.year}"
          end
        end

        def month_name(number)
          @lookandfeel.lookup("month_#{number}").to_s
        end

        # Wie bei /recent_registrations/: eine Zeile mit den Jahren, das
        # laufende ohne Verweis.
        def year_chooser(model)
          years = model.years.to_a
          return "" if years.empty?
          # Nicht escapen: dash_separator ist "&nbsp;-&nbsp;", also schon
          # Markup. CGI.escapeHTML machte daraus sichtbares "&amp;nbsp;".
          separator = @lookandfeel.lookup(:dash_separator).to_s
          separator = "&nbsp;&ndash;&nbsp;" if separator.empty?
          links = years.collect { |year|
            if year == model.year
              "<SPAN class=\"bold\">#{year}</SPAN>"
            else
              url = @lookandfeel._event_url(:rss_html, channel: model.channel, year: year)
              "<A class=\"list\" href=\"#{CGI.escapeHTML(url)}\">#{year}</A>"
            end
          }
          # "Neueste" nur, wo es die Ansicht wirklich gibt. Wo die
          # Einstiegsseite das neueste Jahr ist, zeigte der Eintrag auf
          # dieselbe Seite, die daneben schon als Jahr dasteht.
          if model.newest_view?
            if model.year.nil?
              links.unshift("<SPAN class=\"bold\">" \
                "#{CGI.escapeHTML(@lookandfeel.lookup(:rss_html_newest).to_s)}</SPAN>")
            else
              url = @lookandfeel._event_url(:rss_html, channel: model.channel)
              links.unshift("<A class=\"list\" href=\"#{CGI.escapeHTML(url)}\">" \
                "#{CGI.escapeHTML(@lookandfeel.lookup(:rss_html_newest).to_s)}</A>")
            end
          end
          links.join(separator)
        end

        # Eine richtige Tabelle mit Kopfzeile. Die Beschreibung der Rueckruf-
        # und HPC-Eintraege ist immer "Swissmedic-Registration <nummer>" - das
        # Wort auf jeder Zeile zu wiederholen ist Papierverschwendung, die
        # Nummer gehoert in eine eigene Spalte mit Titel darueber.
        IKSNR_PATTERN = /Swissmedic-Registration\s+(\d+)/i

        def feed_items(model)
          numbered = model.items.any? { |item| iksnr(item) }
          rows = model.items.collect { |item| item_row(item, numbered) }
          if rows.empty?
            rows = ["<TR><TD class=\"list\">" \
              "#{CGI.escapeHTML(@lookandfeel.lookup(:rss_html_empty).to_s)}</TD></TR>"]
          end
          ["<TABLE cellspacing=\"0\" class=\"composite\">",
            "<TR><TD class=\"subheading\" colspan=\"#{numbered ? 3 : 2}\">",
            CGI.escapeHTML(@lookandfeel.lookup(:rss_html_entries).to_s),
            " (#{model.items.size})</TD></TR>",
            header_row(numbered),
            rows,
            "</TABLE>",
            source_note(model)].flatten.join
        end

        def header_row(numbered)
          cells = ["<TH class=\"th col-rss_date\">" \
            "#{CGI.escapeHTML(@lookandfeel.lookup(:rss_html_date).to_s)}</TH>",
            "<TH class=\"th col-rss_title\">" \
              "#{CGI.escapeHTML(@lookandfeel.lookup(:rss_html_title).to_s)}</TH>"]
          if numbered
            cells << "<TH class=\"th col-rss_iksnr\">" \
              "#{CGI.escapeHTML(@lookandfeel.lookup(:rss_html_iksnr).to_s)}</TH>"
          end
          "<TR>#{cells.join}</TR>"
        end

        def iksnr(item)
          md = IKSNR_PATTERN.match(item.description.to_s)
          md && md[1]
        end

        def item_row(item, numbered)
          title = CGI.escapeHTML(item.title.to_s)
          cell = if item.link && !item.link.empty?
            "<A class=\"list bold\" href=\"#{CGI.escapeHTML(item.link)}\">#{title}</A>"
          else
            "<SPAN class=\"bold\">#{title}</SPAN>"
          end
          # Was nicht dem Muster entspricht, bleibt als Zeile unter dem Titel
          # stehen, damit nichts verloren geht.
          number = iksnr(item)
          rest = item.description.to_s
          rest = "" if number || rest.empty?
          cell += "<DIV class=\"italic\">#{CGI.escapeHTML(rest)}</DIV>" unless rest.empty?
          cells = ["<TD class=\"list col-rss_date\">" \
            "#{item.date ? item.date.strftime("%d.%m.%Y") : "&nbsp;"}</TD>",
            "<TD class=\"list col-rss_title\">#{cell}</TD>"]
          if numbered
            cells << "<TD class=\"list italic col-rss_iksnr\">#{number || "&nbsp;"}</TD>"
          end
          "<TR>#{cells.join}</TR>"
        end

        # Der Weg zurueck zum XML bleibt sichtbar - wer den Feed abonnieren
        # will, soll ihn hier finden und nicht auf der Startseite suchen muessen.
        def source_note(model)
          url = @lookandfeel._event_url(:rss, channel: model.channel)
          "<TABLE cellspacing=\"0\" class=\"composite\"><TR><TD class=\"list\">" \
            "<A class=\"list\" href=\"#{CGI.escapeHTML(url)}\">" \
            "#{CGI.escapeHTML(@lookandfeel.lookup(:rss_html_source).to_s)}</A>" \
            "</TD></TR></TABLE>"
        end
      end

      class HtmlFeed < View::PrivateTemplate
        SEARCH_HEAD = View::SearchForm
        CONTENT = View::Rss::HtmlFeedComposite

        def backtracking(model, session = @session)
          nil
        end
      end
    end
  end
end
