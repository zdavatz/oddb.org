#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestLogo -- oddb.org -- 05.09.2011 -- mhatkeyama@ywesee.com
# ODDB::View::TestLogo -- oddb.org -- 01.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/logo'

module ODDB
  class Session
    DEFAULT_FLAVOR = 'gcc'
  end

  module View
    
    class PopupLogo
    end
class TestPopupLogo < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :enabled?   => true,
                        :resource   => 'resource',
                        :resource_localized   => 'resource_localized',
                        :_event_url   => '_event_url',
                       )
    @zone = flexmock('zone', :zone => 'zone')
    @session = flexmock('session',
                        :state => @zone,
                        :lookandfeel => @lnf,
                        :flavor => Session::DEFAULT_FLAVOR,
                        :get_cookie_input => 'get_cookie_input',
                       )
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
  def test_to_html__desitin
    attrs = {'href' => 'href'}
    flexmock(@lnf, :attributes => attrs)
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
    def test_to_html
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :enabled?   => nil,
                        :resource   => 'resource'
                       )
    @session = flexmock('session',
                        :lookandfeel => @lnf,
                        :flavor => Session::DEFAULT_FLAVOR,
                        :get_cookie_input => nil,
                       )
    @model   = flexmock('model')
    @logo    = ODDB::View::Logo.new(@model, @session)
    context = flexmock('context')
    assert_equal('&nbsp;', @logo.to_html(context))
  end
  def test_to_html__enabled
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :enabled?   => true,
                        :resource   => 'resource',
                        :resource_localized   => 'resource_localized',
                        :_event_url   => '_event_url',
                       )
    @zone = flexmock('zone', :zone => 'zone')
    @session = flexmock('session',
                        :state => @zone,
                        :lookandfeel => @lnf,
                        :flavor => Session::DEFAULT_FLAVOR,
                        :get_cookie_input => nil,
                       )
    @model   = flexmock('model')
    @logo    = ODDB::View::Logo.new(@model, @session)
    context = flexmock('context', :a => 'a')
    assert_equal('a', context.a)
    assert_equal('a', @logo.to_html(context))
  end
end
  end # View
end # ODDB

