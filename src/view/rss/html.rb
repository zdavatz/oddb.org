#!/usr/bin/env ruby

# View::Rss::Html -- oddb.org -- 26.08.2026
#
# Die HTML-Ansicht der Feeds. Ein Feed ist fuer einen Leser gemacht, nicht fuer
# einen Menschen: wer auf der Startseite auf "37 SL Neuaufnahmen" klickt,
# bekommt XML zu sehen, das der Browser roh oder mit seiner eigenen
# Notdarstellung anzeigt. Diese Ansicht liest denselben Feed und stellt ihn im
# Aussehen der Seite dar.
#
# Sie erfindet nichts nach: die Quelle bleibt die Datei unter data/rss/, die
# plugin/rss.rb schreibt. Was hier steht, steht auch im Feed.

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
          [0, 2] => :feed_items
        }
        CSS_CLASS = "composite"
        CSS_MAP = {
          [0, 1] => "th"
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
          here.value = CGI.escapeHTML(model.title.to_s)
          [span, sep, here]
        end

        def feed_title(model)
          title = model.title.to_s
          parts = [CGI.escapeHTML(title)]
          # Bei recall.rss und hpc.rss sind Titel und Beschreibung dasselbe Wort.
          descr = model.description.to_s
          if !descr.empty? && descr != title
            parts << CGI.escapeHTML(descr)
          end
          parts.join(" &ndash; ")
        end

        # Eine Tabelle, weil die Seite aus Tabellen gebaut ist und responsive.css
        # td.list und td.subheading auf schmalen Bildschirmen schon behandelt.
        def feed_items(model)
          rows = model.items.collect { |item| item_row(item) }
          if rows.empty?
            rows = ["<TR><TD class=\"list\">#{CGI.escapeHTML(@lookandfeel.lookup(:rss_html_empty).to_s)}</TD></TR>"]
          end
          ["<TABLE cellspacing=\"0\" class=\"composite\">",
            "<TR><TD class=\"subheading\">#{CGI.escapeHTML(@lookandfeel.lookup(:rss_html_entries).to_s)}",
            " (#{model.items.size})</TD></TR>",
            rows,
            "</TABLE>",
            source_note(model)].flatten.join
        end

        def item_row(item)
          title = CGI.escapeHTML(item.title.to_s)
          cell = if item.link && !item.link.empty?
            "<A class=\"list bold\" href=\"#{CGI.escapeHTML(item.link)}\">#{title}</A>"
          else
            "<SPAN class=\"bold\">#{title}</SPAN>"
          end
          date = item.date ? "<SPAN class=\"breadcrumb\">#{item.date.strftime("%d.%m.%Y")}</SPAN>" : ""
          descr = if item.description && !item.description.empty?
            "<BR><SPAN class=\"italic\">#{CGI.escapeHTML(item.description)}</SPAN>"
          else
            ""
          end
          "<TR><TD class=\"list\">#{date} #{cell}#{descr}</TD></TR>"
        end

        # Der Weg zurueck zum XML bleibt sichtbar - wer den Feed abonnieren will,
        # soll ihn hier finden und nicht auf der Startseite suchen muessen.
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
