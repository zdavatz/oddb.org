#!/usr/bin/env ruby

# View::LookandfeelComponents -- oddb.org -- 15.05.2007 -- hwyss@ywesee.com

module ODDB
  module View
    # Die Spaltenklasse col-<schluessel>, getrennt von LookandfeelComponents,
    # weil nicht jede Liste ueber dessen reorganize_components geht: die
    # Vergleichsansicht (View::Drugs::CompareList) bringt eine eigene mit,
    # braucht die Klassen aber genauso.
    module ColumnCssClass
      # Die Spaltenreihenfolge ist pro Flavor eine andere: result_list_components
      # steht in lookandfeelbase.rb und wird in lookandfeelwrapper.rb mehrfach
      # ueberschrieben, mit anderer Zahl und anderer Reihenfolge der Spalten.
      # Ueber :nth-child ist eine Spalte deshalb nicht ansprechbar - in gcc ist
      # der Publikumspreis die neunte, anderswo die achte oder die fuenfte.
      #
      # Der Schluessel als Klasse macht sie unabhaengig von der Position
      # adressierbar: "col-price_public" heisst ueberall dasselbe. Das ist die
      # Voraussetzung dafuer, dass responsive.css die Tabelle auf schmalen
      # Bildschirmen zu einer Karte pro Packung umbauen kann.
      def with_column_class(klass, val)
        return klass unless val.is_a?(Symbol)
        "#{klass} col-#{val}"
      end
    end

    module LookandfeelComponents
      include ColumnCssClass

      def reorganize_components(lookandfeel_key, default = "th")
        @components = @lookandfeel.send(lookandfeel_key)
        @css_map = {}
        @css_head_map = {}
        @components.each { |key, val|
          if (klass = self.class::CSS_KEYMAP[val])
            @css_map.store(key, with_column_class(klass, val))
            @css_head_map.store(key,
              with_column_class(self.class::CSS_HEAD_KEYMAP[val] || default, val))
          end
        }
      end
    end
  end
end
