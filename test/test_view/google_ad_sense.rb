#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestGoogleAdSense -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/component'
require 'htmlgrid/composite'
require 'view/google_ad_sense'

module ODDB
  module View

class TestGoogleAdSense <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model')
    @component = ODDB::View::GoogleAdSense.new(@model, @session)
  end
  def test_to_html
    expected = "<script type=\"text/javascript\"><!--\ngoogle_ad_client = \"pub-6948570700973491\";\ngoogle_ad_width = \"250\";\ngoogle_ad_height = \"250\";\ngoogle_ad_format = \"250x250_as\";\ngoogle_ad_channel =\"\";\ngoogle_ad_type = \"text_image\";\ngoogle_color_border = \"DBE1D6\";\ngoogle_color_bg = \"E6FFD6\";\ngoogle_color_link = \"003366\";\ngoogle_color_url = \"FF3300\";\ngoogle_color_text = \"003399\";\n//--></script>\n<script type=\"text/javascript\"\n  src=\"http://pagead2.googlesyndication.com/pagead/show_ads.js\">\n\t</script>\n"
    assert_equal(expected, @component.to_html('context'))
  end
end


class GoogleAdSenseComposite < HtmlGrid::Composite
  include FlexMock::TestCase
  CONTENT = HtmlGrid::Component
end

class TestGoogleAdSenseComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup   => 'lookup',
                          :enabled? => nil
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model')
    @composite = ODDB::View::GoogleAdSenseComposite.new(@model, @session)
  end
  def test_content
    assert_kind_of(HtmlGrid::Component, @composite.content(@model, @session))
  end
  def test_active_sponsor
    sponsor = flexmock('sponsor', :valid? => true)
    flexmock(@session, :sponsor => sponsor)
    assert(@composite.active_sponsor?)
  end
  def test_active_sponsor__false
    sponsor = flexmock('sponsor', :valid? => false)
    flexmock(@session, :sponsor => sponsor)
    assert_equal(false, @composite.active_sponsor?)
  end
  def test_ad_sense
    sponsor = flexmock('sponsor', :valid? => false)
    user = flexmock('user', :valid? => false)
    @lnf       = flexmock('lookandfeel', 
                          :lookup   => 'lookup',
                          :enabled? => true
                         )
    @session   = flexmock('session', :lookandfeel => @lnf,  :sponsor => sponsor, :user => user)
    @composite = ODDB::View::GoogleAdSenseComposite.new(@model, @session)
    assert_kind_of(ODDB::View::GoogleAdSense, @composite.ad_sense(@model, @session))
  end
end

  end # View
end # ODDB

