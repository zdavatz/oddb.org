#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestGoogleAdSense -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'htmlgrid/component'
require 'htmlgrid/composite'
require 'view/google_ad_sense'

module ODDB
  module View

class TestGoogleAdSense <Minitest::Test
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model')
    @component = ODDB::View::GoogleAdSense.new(@model, @session)
  end
  def test_to_html
    html =  @component.to_html('context')
    assert_match(/adsbygoogle.js/, html)
    assert(html.index('data-ad-client="ca-pub-6948570700973491"'))
    assert(html.index('style="display:block height  250px width {@width}px"'))
  end
end


class GoogleAdSenseComposite < HtmlGrid::Composite
  CONTENT = HtmlGrid::Component
end

class TestGoogleAdSenseComposite <Minitest::Test
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
    @composite = ODDB::View::GoogleAdSenseComposite.new(@model, @session, 'left')
    assert_kind_of(ODDB::View::GoogleAdSense, @composite.ad_sense(@model, @session, 'right'))
  end
end

  end # View
end # ODDB

