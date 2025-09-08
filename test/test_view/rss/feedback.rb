#!/usr/bin/env ruby

# ODDB::View::Rss::TestFeedback -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# ODDB::View::Rss::TestFeedback -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "htmlgrid/labeltext"
require "view/resulttemplate"
require "view/latin1"
require "view/rss/feedback"
require "model/package"
ENV["TZ"] = "UTC"

module ODDB
  module View
    module Rss
      class TestFeedbackTemplate < Minitest::Test
        def setup
          flexmock(ODBA.cache, next_id: 123)
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            attributes: {},
            _event_url: "_event_url")
          @session = flexmock("session", lookandfeel: @lnf)
          @item = flexmock("item",
            pointer: "pointer",
            odba_instance: ODDB::Package.new("123"))
          @model = flexmock("model",
            item: @item,
            time: Time.utc(2011, 2, 3),
            email: "email",
            name: "name",
            message: "message",
            helps: "helps",
            show_email: "show_email",
            experience: "experience",
            recommend: "recommend",
            impression: "impression")
          @template = ODDB::View::Rss::FeedbackTemplate.new(@model, @session)
        end

        def test_feedback__package
          assert_kind_of(ODDB::View::Drugs::FeedbackList, @template.feedback(@model))
        end
      end

      class TestFeedback < Minitest::Test
        def setup
          flexmock(ODBA.cache, next_id: 123)
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            attributes: {},
            _event_url: "_event_url",
            resource: "resource")
          @session = flexmock("session",
            lookandfeel: @lnf,
            language: "language")
          @item = flexmock("item",
            pointer: "pointer",
            name: "name",
            size: "size",
            odba_instance: ODDB::Package.new("123"))
          @model = flexmock("model",
            item: @item,
            time: Time.local(2011, 2, 3),
            email: "email",
            helps: "helps",
            name: "name",
            message: "message",
            show_email: "show_email",
            experience: "experience",
            recommend: "recommend",
            impression: "impression")

          @component = ODDB::View::Rss::Feedback.new([@model], @session)
        end

        def test_to_html__package
          context = flexmock("context", html: "html")
          expected = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<rss version=\"2.0\"
  xmlns:content=\"http://purl.org/rss/1.0/modules/content/\"
  xmlns:dc=\"http://purl.org/dc/elements/1.1/\"
  xmlns:trackback=\"http://madskills.com/public/xml/rss/module/trackback/\"
  xmlns:itunes=\"http://www.itunes.com/dtds/podcast-1.0.dtd\">
  <channel>
    <title>lookup</title>
    <link>_event_url</link>
    <description>lookup</description>
    <language>language</language>
    <image>
      <url>resource</url>
      <title>lookup</title>
      <link>_event_url</link>
    </image>
    <item>
      <title>lookup</title>
      <link>_event_url</link>
      <description>html</description>
      <author>ODDB.org</author>
      <pubDate>Thu, 03 Feb 2011 00:00:00 -0000</pubDate>
      <guid isPermaLink=\"true\">_event_url</guid>
      <dc:date>2011-02-03T00:00:00Z</dc:date>
    </item>
  </channel>
</rss>"
          assert_equal(expected, @component.to_html(context))
        end
      end
    end # Interactions
  end # View
end # ODDB
