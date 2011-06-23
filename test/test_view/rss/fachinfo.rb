#!/usr/bin/env ruby
# ODDB::View::Rss::TestFachinfo -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/rss/fachinfo'
require 'model/fachinfo'

module ODDB
  module View
    module Rss

class TestFachinfoItem < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :language    => 'language'
                         )
    language   = flexmock('language', :chapter_names => ['chapter_name'])
    flexmock(language, :language => language)
    @model     = flexmock('model', :language => language)
    @composite = ODDB::View::Rss::FachinfoItem.new(@model, @session)
  end
  def test_init
    assert_equal([[[0, 0], "chapter_name"]], @composite.init)
  end
end

class TestFachinfo < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :_event_url => '_event_url',
                          :resource   => 'resource',
                          :attributes => {}
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :language    => 'language'
                         )
    document   = flexmock('document', 
                          :is_a? => true,
                          :chapter_names => ['chapter_name']
                         )
    @model     = flexmock('model', 
                          :localized_name => 'localized_name',
                          :language => document,
                          :pointer  => 'pointer',
                          :revision => Time.local(2011,2,3)
                         )
    @component = ODDB::View::Rss::Fachinfo.new([@model], @session)
  end
  def test_to_html
    context = flexmock('context', :html => 'html')
    expected = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rss version=\"2.0\"\n  xmlns:trackback=\"http://madskills.com/public/xml/rss/module/trackback/\">\n  <channel>\n    <title>lookup</title>\n    <link>_event_url</link>\n    <description>lookup</description>\n    <language>language</language>\n    <image>\n      <url>resource</url>\n      <title>lookup</title>\n      <link>_event_url</link>\n    </image>\n    <item>\n      <title>localized_name</title>\n      <link>_event_url</link>\n      <description>html</description>\n      <author>ODDB.org</author>\n      <pubDate>Thu, 03 Feb 2011 00:00:00 +0100</pubDate>\n      <guid isPermaLink=\"true\">_event_url</guid>\n    </item>\n  </channel>\n</rss>"
    assert_equal(expected, @component.to_html(context))
  end
end

    end # Interactions
  end # View
end # ODDB
