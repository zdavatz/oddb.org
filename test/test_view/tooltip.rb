#!/usr/bin/env ruby

# ODDB::View::TestLogoHead -- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/tooltip"
require "htmlgrid/span"
require "stub/cgi"
module ODDB
  module View
    class StubContainer
      attr_accessor :additional_javascripts
    end

    class TestTooltip < Minitest::Test
      def setup
        @lnf = flexmock("lookandfeel",
          lookup: "lookup",
          attributes: {},
          enabled?: false,
          _event_url: "_event_url")
        @session = flexmock("session",
          flavor: "gcc",
          lookandfeel: @lnf,
          persistent_user_input: "persistent_user_input")
        @model = flexmock("model")
        @container = flexmock("container", CGI.new)
        @element = flexmock("span", HtmlGrid::Span.new(@model, @session, @container))
        @element.should_receive(:additional_javascripts).and_return([])
      end

      def test_tooltip_selbstbehalt
        ODDB::View::TooltipHelper.set_tooltip(@element, "http://some.url/url")
        assert_match("<SPAN>", @element.to_html(@container))
      end

      def test_tooltip_with_href
        ODDB::View::TooltipHelper.set_tooltip(@element, nil, "dummy content")
        result = @element.to_html(CGI.new)
        assert_match(/<SPAN>/, result)
        # assert_match('dialog', result)
      end

      # Die drei Gestalten, in denen der Text ankommt. ASCII-8BIT ist der Fall,
      # der die Packungsseiten umgeworfen hat: encode("UTF-8") kann aus einem
      # binaeren String kein Byte ueber 0x7F konvertieren.
      def test_to_utf8_reads_binary_as_utf8
        binary = "Préparations".dup.force_encoding("ASCII-8BIT")
        got = ODDB::View::TooltipHelper.to_utf8(binary)
        assert_equal(Encoding::UTF_8, got.encoding)
        assert_equal("Préparations", got)
      end

      def test_to_utf8_falls_back_to_latin1
        latin1 = "Mittel f\xFCr Haut".dup.force_encoding("ASCII-8BIT")
        got = ODDB::View::TooltipHelper.to_utf8(latin1)
        assert_equal(Encoding::UTF_8, got.encoding)
        assert_equal("Mittel für Haut", got)
      end

      def test_to_utf8_leaves_clean_text_alone
        assert_equal("Mittel für Haut", ODDB::View::TooltipHelper.to_utf8("Mittel für Haut"))
        assert_equal("", ODDB::View::TooltipHelper.to_utf8(nil))
      end

      # Und der Weg, auf dem es in der Anwendung wirklich passiert ist.
      def test_set_tooltip_survives_binary_content
        ODDB::View::TooltipHelper.set_tooltip(@element, nil, "Préparations".dup.force_encoding("ASCII-8BIT"))
        assert_match(/<SPAN>/, @element.to_html(CGI.new))
      end

      def test_tool_tipp_javascript
        skip("Howto test emitting the script")
        # Also we did not check that the generated SPAN must have an id like <uniq_id>_dialog
      end
    end
  end
end # ODDB
