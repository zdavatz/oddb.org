#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Rss::TestFeedback -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/resulttemplate'
require 'view/latin1'
require 'view/rss/feedback'
require 'model/package'
require 'model/migel/product'

module ODDB
  module View
    module Rss

class TestFeedbackTemplate < Test::Unit::TestCase
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
  def test_feedback__migel_product
    flexmock(@item, :odba_instance => ODDB::Migel::Product.new('123'))
    assert_kind_of(ODDB::View::Migel::FeedbackList, @template.feedback(@model))
  end
end

class TestFeedback < Test::Unit::TestCase
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
                         :show_email => 'show_email',
                         :experience => 'experience',
                         :recommend  => 'recommend',
                         :impression => 'impression'
                        )

    @component = ODDB::View::Rss::Feedback.new([@model], @session)
  end
  def test_to_html__package
    context = flexmock('context', :html => 'html')
    expected = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rss version=\"2.0\"\n  xmlns:trackback=\"http://madskills.com/public/xml/rss/module/trackback/\">\n  <channel>\n    <title>lookup</title>\n    <link>_event_url</link>\n    <description>lookup</description>\n    <language>language</language>\n    <image>\n      <url>resource</url>\n      <title>lookup</title>\n      <link>_event_url</link>\n    </image>\n    <item>\n      <title>lookup</title>\n      <link>_event_url</link>\n      <description>html</description>\n      <author>ODDB.org</author>\n      <pubDate>Thu, 03 Feb 2011 00:00:00 +0100</pubDate>\n      <guid isPermaLink=\"true\">_event_url</guid>\n    </item>\n  </channel>\n</rss>"
    assert_equal(expected, @component.to_html(context))
  end
  def test_to_html__migel_product
    flexmock(@item, :odba_instance => ODDB::Migel::Product.new('123'))
    context = flexmock('context', :html => 'html')
    expected = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rss version=\"2.0\"\n  xmlns:trackback=\"http://madskills.com/public/xml/rss/module/trackback/\">\n  <channel>\n    <title>lookup</title>\n    <link>_event_url</link>\n    <description>lookup</description>\n    <language>language</language>\n    <image>\n      <url>resource</url>\n      <title>lookup</title>\n      <link>_event_url</link>\n    </image>\n    <item>\n      <title>lookupname</title>\n      <link>_event_url</link>\n      <description>html</description>\n      <author>ODDB.org</author>\n      <pubDate>Thu, 03 Feb 2011 00:00:00 +0100</pubDate>\n      <guid isPermaLink=\"true\">_event_url</guid>\n    </item>\n  </channel>\n</rss>"
    assert_equal(expected, @component.to_html(context))
  end

end

    end # Interactions
  end # View
end # ODDB
