#!/usr/bin/env ruby

# TestUtf8Diff -- oddb.org -- 2026
# Regression coverage for View::Drugs.utf8_diff, which stops the
# Encoding::UndefinedConversionError that made every /diff/ page return 500.

$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "stub/odba"
require "view/drugs/change_logs"

module ODDB
  module View
    class TestUtf8Diff < Minitest::Test
      DIFF_OPTIONS = {
        diff: "-U 3",
        source: "strings",
        include_plus_and_minus_in_html: true,
        include_diff_info: false,
        context: 0,
        allow_empty_diff: false
      }
      OLD_TEXT = "Schwangerschaft: Vorsicht\nDosierung fuer Kinder\n"
      NEW_TEXT = "Schwangerschaft: Grösse und Übelkeit\nDosierung für Kinder\n"

      # config.ru sets Encoding.default_internal = UTF-8 for the running app.
      # Without it IO#write does not transcode and the bug does not reproduce,
      # so the test has to recreate that condition.
      def setup
        @internal = Encoding.default_internal
        Encoding.default_internal = Encoding::UTF_8
      end

      def teardown
        Encoding.default_internal = @internal
        ODBA.storage = nil
        super
      end

      def binary_diff(old_text = OLD_TEXT, new_text = NEW_TEXT)
        diffy = Diffy::Diff.new(old_text, new_text, DIFF_OPTIONS)
        # what ydiffy (diff.rb:60) does whenever the diff output is not valid
        # UTF-8, and what we then marshal into ODBA
        diffy.instance_variable_set(:@diff, diffy.diff.dup.force_encoding("ASCII-8BIT"))
        diffy
      end

      # Guards the premise: without the fix this really does blow up, so the
      # test below is not green for the wrong reason.
      def test_binary_diff_raises_without_the_fix
        assert_raises(Encoding::UndefinedConversionError) do
          binary_diff.to_s(:html)
        end
      end

      def test_renders_html_for_binary_tagged_diff
        html = Drugs.utf8_diff(binary_diff).to_s(:html)
        assert(html.valid_encoding?)
        assert_equal(Encoding::UTF_8, html.encoding)
        # umlauts must survive the fix - the char-level diff wraps the changed
        # ones in <strong>, so assert on the surrounding text too
        assert_match("Grösse und Übelkei", html)
        assert_match("f<strong>ü</strong>r Kinder", html)
      end

      def test_leaves_valid_utf8_diff_untouched
        diffy = Diffy::Diff.new(OLD_TEXT, NEW_TEXT, DIFF_OPTIONS)
        assert_same(diffy, Drugs.utf8_diff(diffy))
      end

      # The copy must not spawn a second `diff` subprocess, and must not mutate
      # the ODBA-cached original.
      def test_does_not_touch_the_original
        diffy = binary_diff
        before = diffy.diff
        copy = Drugs.utf8_diff(diffy)
        refute_same(diffy, copy)
        assert_equal(Encoding::ASCII_8BIT, before.encoding)
        assert_equal(Encoding::ASCII_8BIT, diffy.diff.encoding)
        assert_equal(Encoding::UTF_8, copy.diff.encoding)
      end

      def test_scrubs_genuinely_invalid_bytes
        diffy = Diffy::Diff.new(OLD_TEXT, NEW_TEXT, DIFF_OPTIONS)
        broken = (diffy.diff + "\xC3 orphan\n").force_encoding("ASCII-8BIT")
        diffy.instance_variable_set(:@diff, broken)
        copy = Drugs.utf8_diff(diffy)
        assert(copy.diff.valid_encoding?, "scrubbed text must be valid UTF-8")
        assert_match("?", copy.diff)
      end

      def test_returns_original_when_diff_is_not_a_string
        diffy = Diffy::Diff.new(OLD_TEXT, NEW_TEXT, DIFF_OPTIONS)
        diffy.instance_variable_set(:@diff, nil)
        assert_same(diffy, Drugs.utf8_diff(diffy))
      end
    end
  end
end
