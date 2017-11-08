#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestLogo -- oddb.org -- 05.09.2011 -- mhatkeyama@ywesee.com
# ODDB::View::TestLogo -- oddb.org -- 01.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'view/logohead'
require 'view/logo'

module ODDB
  class Session
    DEFAULT_FLAVOR = 'gcc' unless defined?(DEFAULT_FLAVOR)
  end

  module View

    class PopupLogo
    end
class TestPopupLogo <Minitest::Test
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
                        :request_path => 'request_path',
                       )
    @model     = flexmock('model')
    @component = ODDB::View::PopupLogo.new(@model, @session)
  end
  def test_init
    assert_nil(@component.init)
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
end

class TestLogo <Minitest::Test
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
                        :request_path => 'request_path',
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
                        :request_path => 'request_path',
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

