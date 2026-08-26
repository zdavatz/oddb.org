#!/usr/bin/env ruby
# TestResponsive -- oddb.org -- responsive.css darf den Desktop nicht anfassen

$LOAD_PATH.unshift File.expand_path("../..", __dir__)
$LOAD_PATH.unshift File.expand_path("../../src", __dir__)

require "minitest/autorun"

module ODDB
  module View
    # Die zwei Eigenschaften, die zaehlen:
    #
    #  1. Jede Regel steht in einer Media Query. Was ausserhalb stuende, wuerde
    #     jeden Besucher treffen, auch den am 27-Zoll-Schirm.
    #  2. Keine festen Farben. Die Datei wird in jede Seite eingebettet und muss
    #     auch im Dunkelmodus stimmen - eine Farbe hier waere im dunklen Modus
    #     falsch und wuerde von bin/generate_dark_css.py nie gesehen, weil der
    #     Erzeuger nur oddb.css und diff.css liest.
    class TestResponsive < Minitest::Test
      CSS = File.expand_path("../../doc/resources/responsive.css", __dir__)

      def setup
        @css = File.read(CSS)
      end

      def test_the_file_is_there
        assert File.exist?(CSS), "responsive.css fehlt"
      end

      def test_braces_balance
        assert_equal(@css.count("{"), @css.count("}"))
      end

      def test_every_rule_lives_in_a_media_query
        depth = 0
        outside = []
        @css.gsub(%r{/\*.*?\*/}m, "").each_line do |line|
          if /@media[^{]*\{/.match?(line)
            depth += 1
            next
          end
          outside << line.strip if depth.zero? && /[a-z-]+\s*:/.match?(line)
          depth += line.count("{")
          depth -= line.count("}")
          depth = 0 if depth < 0
        end
        assert_empty(outside,
          "diese Deklarationen stehen ausserhalb jeder Media Query: #{outside.inspect}")
      end

      def test_no_fixed_colours
        colours = @css.gsub(%r{/\*.*?\*/}m, "").scan(/#[0-9a-fA-F]{3,8}\b/)
        assert_empty(colours,
          "feste Farben gehoeren in dark.css, nicht hierher: #{colours.inspect}")
      end

      # Die Spaltenklassen kommen aus reorganize_components. Ohne sie greift auf
      # dem Telefon keine einzige Regel der Trefferliste, weil die
      # Spaltenreihenfolge pro Flavor eine andere ist.
      def test_addresses_the_columns_by_name
        %w[col-name_base col-price_public col-deductible col-compositions].each do |klass|
          assert_includes(@css, klass, "#{klass} wird nicht angesprochen")
        end
      end

      def test_the_three_breakpoints_are_there
        assert_match(/@media\s*\(min-width:\s*1025px\)/, @css)
        assert_match(/@media\s*\(max-width:\s*1024px\)/, @css)
        assert_match(/@media\s*\(max-width:\s*640px\)/, @css)
      end

      # Safari zoomt die Seite, sobald ein Feld mit weniger als 16px den Fokus
      # bekommt - und zoomt nicht wieder heraus.
      def test_inputs_are_16px_on_phones
        phone = @css[/@media\s*\(max-width:\s*640px\)\s*\{(.*)/m, 1].to_s
        assert_match(/input,.*?font-size:\s*16px/m, phone)
      end
    end
  end
end
