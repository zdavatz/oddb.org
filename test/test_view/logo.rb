#!/usr/bin/env ruby
# ODDB::View::TestLogo -- oddb.org -- 28.06.2011 -- mhatkeyama@ywesee.com
# ODDB::View::TestLogo -- oddb.org -- 01.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/logo'

module ODDB
  module View

class TestPopupLogo < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :enabled?   => nil,
                          :resource   => 'resource'
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model')
    @component = ODDB::View::PopupLogo.new(@model, @session)
  end
  def test_init
    assert_equal('lookup', @component.init)
  end
  def test_to_html
    flexmock(@lnf, :_event_url => '_event_url')
    context = flexmock('context', :a => 'a')
    assert_equal('a', @component.to_html(context))
  end
  def test_logo_src
    flexmock(@lnf, 
             :enabled? => true,
             :resource_localized => 'resource_localized'
            )
    assert_equal('resource_localized', @component.logo_src('key'))
  end
  def test_zone_logo_src
    flexmock(@lnf, 
             :enabled? => true,
             :resource_localized => 'resource_localized'
            )
    state = flexmock('state', :zone => 'zone')
    flexmock(@session, :state => state)
    assert_equal('resource_localized', @component.zone_logo_src('key'))
  end
end

class TestLogo < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :enabled?   => nil,
                        :resource   => 'resource'
                       )
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @logo    = ODDB::View::Logo.new(@model, @session)
  end
  def test_to_html
    context = flexmock('context')
    assert_equal('&nbsp;', @logo.to_html(context))
  end
  def test_to_html__enabled
    flexmock(@lnf, 
             :enabled?   => true,
             :_event_url => '_event_url'
            )
    context = flexmock('context', :a => 'a')
    assert_equal('a', @logo.to_html(context))
  end
end
  end # View
end # ODDB

