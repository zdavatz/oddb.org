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

      def test_tool_tipp_javascript
        skip("Howto test emitting the script")
        # Also we did not check that the generated SPAN must have an id like <uniq_id>_dialog
      end
    end
  end
end # ODDB
