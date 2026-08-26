#!/usr/bin/env ruby
# TestDarkMode -- oddb.org -- Der Dunkelmodus darf die helle Seite nicht anfassen

$LOAD_PATH.unshift File.expand_path("../..", __dir__)
$LOAD_PATH.unshift File.expand_path("../../src", __dir__)

require "minitest/autorun"

module ODDB
  module View
    # Die eine Eigenschaft, die zaehlt: ohne html[data-theme="dark"] ist
    # dark.css wirkungslos. Sonst wuerde eine Datei, die in jede Seite
    # eingebettet wird, das Aussehen aller Nutzer aendern - auch derer, die nie
    # umgeschaltet haben.
    #
    # Der Dunkelmodus haengt bewusst nicht an der bestehenden Farbwahl
    # (:styles, oddb-blue.css und Geschwister). Die ist wirkungslos, seit das
    # Stylesheet eingebettet statt verlinkt wird: publictemplate.rb sucht
    # "oddb.css" in einem <style>-Block, in dem der Dateiname gar nicht
    # vorkommt.
    class TestDarkMode < Minitest::Test
      CSS = File.expand_path("../../doc/resources/dark.css", __dir__)
      JS = File.expand_path("../../doc/resources/javascript/darkmode.js", __dir__)
      SOURCES = [
        File.expand_path("../../doc/resources/gcc/oddb.css", __dir__),
        File.expand_path("../../doc/resources/diff.css", __dir__)
      ]

      def setup
        @css = File.read(CSS)
      end

      def test_files_are_there
        assert File.exist?(CSS), "dark.css fehlt"
        assert File.exist?(JS), "darkmode.js fehlt"
      end

      # Jede Regel, die Farben setzt, muss auf den Dunkelmodus beschraenkt sein.
      # Ausgenommen sind nur die Variablendefinition unter :root und der
      # Umschalter selbst, der in beiden Modi sichtbar ist.
      def test_every_colour_rule_is_scoped_to_dark
        unscoped = selectors_setting_colour.reject { |selector|
          selector.include?('html[data-theme="dark"]') ||
            selector.start_with?(":root") ||
            selector.include?("#dark-mode-toggle")
        }
        assert_empty(unscoped,
          "diese Regeln wuerden auch im hellen Modus greifen: #{unscoped.inspect}")
      end

      def test_braces_balance
        assert_equal(@css.count("{"), @css.count("}"))
      end

      # Der Umschalter darf auf dem Ausdruck nicht erscheinen.
      def test_toggle_is_hidden_when_printing
        assert_match(/@media\s+print\s*\{[^}]*#dark-mode-toggle[^}]*display:\s*none/m, @css)
      end

      def test_script_sets_the_attribute_and_remembers_the_choice
        js = File.read(JS)
        assert_match(/setAttribute\("data-theme", "dark"\)/, js)
        assert_match(/removeAttribute\("data-theme"\)/, js)
        assert_match(/localStorage/, js)
        assert_match(/prefers-color-scheme/, js)
      end

      # localStorage wirft in privaten Fenstern und bei gesperrten Seitendaten.
      # Ein Umschalter, der daran scheitert, waere schlechter als keiner.
      def test_storage_access_is_guarded
        js = File.read(JS)
        stored = js[/function stored\(\).*?\n  \}/m]
        remember = js[/function remember\(theme\).*?\n  \}/m]
        refute_nil(stored)
        refute_nil(remember)
        assert_match(/catch/, stored, "stored() faengt keinen Fehler ab")
        assert_match(/catch/, remember, "remember() faengt keinen Fehler ab")
      end

      def test_the_template_wires_both_files_in
        template = File.read(File.expand_path("../../src/view/publictemplate.rb", __dir__))
        assert_match(/DARK_MODE_CSS\s*=\s*"\/resources\/dark\.css"/, template)
        assert_match(/DARK_MODE_JS\s*=\s*"darkmode\.js"/, template)
        # An css_links, nicht an javascripts: centeredsearchform, patinfo,
        # fachinfo und interaction_chooser ueberschreiben javascripts ohne
        # super, ein Haken dort ginge auf diesen Seiten verloren.
        assert_match(/def css_links.*DARK_MODE_CSS.*DARK_MODE_JS/m, template)
      end

      # Der eigentliche Fehler beim ersten Anlauf: von Hand aufgezaehlt, 77
      # Regeln uebersehen. Und ein generisches html[data-theme="dark"] a
      # (Spezifitaet 0,1,2) verliert gegen a.subheading:link (0,2,1) aus
      # oddb.css - die Links blieben dunkelblau auf dunklem Grund, 2.1:1.
      #
      # Deshalb wird der Ueberlagerungsteil erzeugt und nicht gepflegt, und
      # deshalb prueft dieser Test, dass jede farbsetzende Regel der Quellen
      # eine Entsprechung hat.
      def test_every_source_rule_has_a_dark_counterpart
        covered = selectors_of(@css).collect { |selector|
          selector.sub('html[data-theme="dark"] ', "")
        }
        missing = SOURCES.flat_map { |source|
          next [] unless File.exist?(source)
          selectors_setting_colour_in(File.read(source))
        }.uniq.reject { |selector| covered.include?(selector) }
        assert_empty(missing,
          "diese Regeln der Quell-Stylesheets bleiben hell: #{missing.inspect}\n" \
          "python3 bin/generate_dark_css.py #{SOURCES.join(" ")} neu laufen lassen")
      end

      def test_the_generator_is_in_the_tree
        assert File.exist?(File.expand_path("../../bin/generate_dark_css.py", __dir__)),
          "bin/generate_dark_css.py fehlt - der Ueberlagerungsteil waere nicht reproduzierbar"
      end

      private


      def selectors_setting_colour
        selectors_setting_colour_in(@css, /(background|(^|[\s;])color|filter)\s*:/)
      end

      def selectors_setting_colour_in(css, pattern = /(background|(^|[\s;])color)\s*:/)
        strip_comments(css).scan(/([^{}]+)\{([^}]*)\}/).select { |_selector, body|
          body =~ pattern
        }.collect { |selector, _body|
          selector.split(",").collect { |one| one.split.join(" ") }
        }.flatten.reject { |one| one.empty? || one.start_with?("@") }
      end

      def selectors_of(css)
        strip_comments(css).scan(/([^{}]+)\{/).flatten.collect { |selector|
          selector.split(",").collect { |one| one.split.join(" ") }
        }.flatten
      end

      # Der Kopfkommentar enthaelt geschweifte Klammern; ohne ihn zu entfernen
      # zerfaellt die Zerlegung.
      def strip_comments(css)
        css.gsub(%r{/\*.*?\*/}m, "")
      end
    end
  end
end
