#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Rss::TestFachinfo -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/rss/fachinfo'
require 'model/fachinfo'

module ODDB
  module View
    module Rss

class TestFachinfoItem <Minitest::Test
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

class TestFachinfo <Minitest::Test
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
                          :revision => Time.local(2011,2,3),
                          :iksnrs   => ['iksnrs'],
                         )
    @component = ODDB::View::Rss::Fachinfo.new([@model], @session)
  end
  def test_to_html
    context = flexmock('context', :html => 'html')
    expected = %(<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:content="http://purl.org/rss/1.0/modules/content/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
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
      <title>localized_name</title>
      <link>_event_url</link>
      <description>html</description>
      <author>ODDB.org</author>
      <pubDate>Thu, 03 Feb 2011 00:00:00 +0100</pubDate>
      <guid isPermaLink="true">_event_url</guid>
      <dc:date>2011-02-03T00:00:00+01:00</dc:date>
    </item>
  </channel>
</rss>)
    assert_equal(expected, @component.to_html(context))
  end
end
    end # Interactions
  end # View
end # ODDB
