#!/usr/bin/env ruby

# ODDB::View::TestLookandfeelComponents -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/lookandfeel_components"

module ODDB
  module View
    class StubLookandfeelComponents
      CSS_KEYMAP = {"value" => "klass"}
      CSS_HEAD_KEYMAP = {"value" => "map"}
      include LookandfeelComponents
      def initialize(model, session)
        @model = model
        @session = session
        @lookandfeel = session.lookandfeel
      end
    end

    class TestLookandfeelComponents < Minitest::Test
      def setup
        @lnf = flexmock("lookandfeel",
          lookup: "lookup",
          lookandfeel_key: {"key" => "value"})
        @session = flexmock("session", lookandfeel: @lnf)
        @model = flexmock("model")
        @view = ODDB::View::StubLookandfeelComponents.new(@model, @session)
      end

      def test_reorganize_components
        expected = {"key" => "value"}
        assert_equal(expected, @view.reorganize_components("lookandfeel_key"))
      end

      # Ein String-Schluessel bekommt keine Spaltenklasse - "nbsp" und
      # "result_item_start" sind keine Spalten.
      def test_a_string_key_keeps_its_class
        @view.reorganize_components("lookandfeel_key")
        assert_equal("klass", @view.instance_variable_get(:@css_map)["key"])
        assert_equal("map", @view.instance_variable_get(:@css_head_map)["key"])
      end
    end

    # Die Spaltenklasse col-<schluessel> ist die Voraussetzung dafuer, dass
    # responsive.css die Trefferliste auf dem Telefon zu Karten umbauen kann:
    # result_list_components wird in lookandfeelwrapper.rb mehrfach
    # ueberschrieben, die Spalte hat also nirgends dieselbe Nummer, aber
    # ueberall denselben Namen.
    class StubColumnComponents
      CSS_KEYMAP = {
        name_base: "list big",
        price_public: "list pubprice",
        "nbsp" => "list"
      }
      CSS_HEAD_KEYMAP = {
        name_base: "th",
        price_public: "th right"
      }
      include LookandfeelComponents
      attr_reader :css_map, :css_head_map
      def initialize(lookandfeel)
        @lookandfeel = lookandfeel
      end
    end

    class TestColumnCssClasses < Minitest::Test
      def build(components)
        lnf = flexmock("lookandfeel", result_list_components: components)
        view = StubColumnComponents.new(lnf)
        view.reorganize_components(:result_list_components)
        view
      end

      def test_appends_the_column_key_as_a_class
        view = build({[5, 0] => :name_base, [8, 0] => :price_public})
        assert_equal("list big col-name_base", view.css_map[[5, 0]])
        assert_equal("list pubprice col-price_public", view.css_map[[8, 0]])
      end

      def test_the_head_gets_it_too
        view = build({[5, 0] => :name_base, [8, 0] => :price_public})
        assert_equal("th col-name_base", view.css_head_map[[5, 0]])
        assert_equal("th right col-price_public", view.css_head_map[[8, 0]])
      end

      # Der Name haengt am Schluessel, nicht an der Position - das ist der
      # ganze Punkt.
      def test_the_class_does_not_depend_on_the_position
        a = build({[5, 0] => :price_public})
        b = build({[8, 0] => :price_public})
        assert_equal(a.css_map[[5, 0]], b.css_map[[8, 0]])
      end

      def test_string_keys_get_no_column_class
        view = build({[0, 0] => "nbsp"})
        assert_equal("list", view.css_map[[0, 0]])
        assert_equal("th", view.css_head_map[[0, 0]])
      end
    end
  end # View
end # ODDB
