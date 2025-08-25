#!/usr/bin/env ruby

# ODDB::View::TestExternalLinks -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/navigationlink"
require "view/external_links"
require "htmlgrid/popuplink"

module ODDB
  module View
    class StubExternalLinks
      include ODDB::View::ExternalLinks
      def initialize(model, session)
        @model = model
        @session = session
        @lookandfeel = session.lookandfeel
      end
    end

    class TestStubExternalLinks < Minitest::Test
      def setup
        @lnf = flexmock("lookandfeel",
          lookup: "lookup",
          attributes: {},
          _event_url: "_event_url",
          enabled?: nil,
          direct_event: "direct_event")
        @session = flexmock("session", lookandfeel: @lnf)
        @model = flexmock("model")
        @links = ODDB::View::StubExternalLinks.new(@model, @session)
        @oddb_legal = /https:\/\/ywesee.com\/ODDB\/Legal/
      end

      def test_contact_link
        assert_kind_of(ODDB::View::NavigationLink, @links.contact_link(@model, @session))
      end

      def test_external_link
        assert_kind_of(HtmlGrid::Link, @links.external_link(@model, "key"))
      end

      def test_external_link__popup_links
        flexmock(@lnf, enabled?: true)
        assert_kind_of(HtmlGrid::Link, @links.external_link(@model, "key"))
      end

      def test_generic_definition
        assert_kind_of(HtmlGrid::Link, @links.generic_definition(@model, @session))
      end

      def test_help_link
        res = HtmlGrid::Link, @links.help_link(@modle, @session)
        res = res.last
        assert_kind_of(HtmlGrid::Link,res)
        assert(@oddb_legal.match(res.href.to_s))
      end

      def test_legal_note
        res = HtmlGrid::Link, @links.legal_note(@modle, @session)
        res = res.last # Why we get an array and not a single link??
        assert_kind_of(HtmlGrid::Link,res)
        assert(@oddb_legal.match(res.href.to_s))
      end

      def test_meddrugs_update
        assert_kind_of(ODDB::View::NavigationLink, @links.meddrugs_update(@model, @session))
      end
    end
  end # View
end # ODDB
