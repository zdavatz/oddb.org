#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Rss::TestFeedback -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# ODDB::View::Rss::TestFeedback -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/resulttemplate'
require 'view/latin1'
require 'view/rss/feedback'
require 'model/package'

module ODDB
  module View
    module Rss

class TestFeedbackTemplate <Minitest::Test
  include FlexMock::TestCase
  def setup
    flexmock(ODBA.cache, :next_id => 123)
    @lnf      = flexmock('lookandfeel', 
                         :lookup     => 'lookup',
                         :attributes => {},
                         :_event_url => '_event_url'
                        )
    @session  = flexmock('session', :lookandfeel => @lnf)
    @item     = flexmock('item', 
                         :pointer => 'pointer',
                         :odba_instance => ODDB::Package.new('123')
                        )
    @model    = flexmock('model', 
                         :item  => @item,
                         :time  => Time.local(2011,2,3),
                         :email => 'email',
                         :name => 'name',
                         :message => 'message',
                         :helps => 'helps',
                         :show_email => 'show_email',
                         :experience => 'experience',
                         :recommend  => 'recommend',
                         :impression => 'impression'
                        )
    @template = ODDB::View::Rss::FeedbackTemplate.new(@model, @session)
  end
  def test_feedback__package
    assert_kind_of(ODDB::View::Drugs::FeedbackList, @template.feedback(@model))
  end
end

class TestFeedback <Minitest::Test
  include FlexMock::TestCase
  def setup
    flexmock(ODBA.cache, :next_id => 123)
    @lnf      = flexmock('lookandfeel', 
                         :lookup     => 'lookup',
                         :attributes => {},
                         :_event_url => '_event_url',
                         :resource   => 'resource'
                        )
    @session  = flexmock('session', 
                         :lookandfeel => @lnf,
                         :language    => 'language'
                        )
    @item     = flexmock('item', 
                         :pointer => 'pointer',
                         :name    => 'name',
                         :size    => 'size',
                         :odba_instance => ODDB::Package.new('123')
                        )
    @model    = flexmock('model', 
                         :item  => @item,
                         :time  => Time.local(2011,2,3),
                         :email => 'email',
                         :helps => 'helps',
                         :name => 'name',
                         :message => 'message',
                         :show_email => 'show_email',
                         :experience => 'experience',
                         :recommend  => 'recommend',
                         :impression => 'impression'
                        )

    @component = ODDB::View::Rss::Feedback.new([@model], @session)
  end
  def test_to_html__package
    context = flexmock('context', :html => 'html')
    expected = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rss version=\"2.0\"\n  xmlns:content=\"http://purl.org/rss/1.0/modules/content/\"\n  xmlns:dc=\"http://purl.org/dc/elements/1.1/\"\n  xmlns:trackback=\"http://madskills.com/public/xml/rss/module/trackback/\"\n  xmlns:itunes=\"http://www.itunes.com/dtds/podcast-1.0.dtd\">\n  <channel>\n    <title>lookup</title>\n    <link>_event_url</link>\n    <description>lookup</description>\n    <language>language</language>\n    <image>\n      <url>resource</url>\n      <title>lookup</title>\n      <link>_event_url</link>\n    </image>\n    <item>\n      <title>lookup</title>\n      <link>_event_url</link>\n      <description>html</description>\n      <author>ODDB.org</author>\n      <pubDate>Thu, 03 Feb 2011 00:00:00 +0100</pubDate>\n      <guid isPermaLink=\"true\">_event_url</guid>\n      <dc:date>2011-02-03T00:00:00+01:00</dc:date>\n    </item>\n  </channel>\n</rss>"
    assert_equal(expected, @component.to_html(context))
  end
end
    end # Interactions
  end # View
end # ODDB
