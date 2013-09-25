#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestNavigationLink -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/navigation'

module ODDB
  module View

class TestNavigationLink <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :enabled?   => nil,
                        :direct_event => 'direct_event',
                        :_event_url   => '_event_url'
                       )
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @link    = ODDB::View::NavigationLink.new('name', @model, @session)
  end
  def test_init
    assert_equal('_event_url', @link.init)
  end
  def test_to_html
    context = flexmock('context', :a => 'a')
    assert_equal('a', @link.to_html(context))
  end
end

class TestLanguageNavigationLink <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :language   => 'language'
                       )
    @session = flexmock('session', 
                        :lookandfeel  => @lnf,
                        :request_path => 'request_path'
                       )
    @model   = flexmock('model')
    @link    = ODDB::View::LanguageNavigationLink.new('name', @model, @session)
  end
  def test_init
    assert_equal('/name/', @link.init)
  end
end

class TestLanguageNavigationLinkShort <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :language   => 'language'
                       )
    @session = flexmock('session', 
                        :lookandfeel  => @lnf,
                        :request_path => 'request_path'
                       )
    @model   = flexmock('model')
    @link    = ODDB::View::LanguageNavigationLinkShort.new('name', @model, @session)
  end
  def test_init
    assert_equal('Name', @link.init)
  end
end

class TestCurrencyNavigationLink <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel  => @lnf,
                        :currency     => 'currency',
                        :request_path => 'request_path'
                       )
    @model   = flexmock('model')
    @link    = ODDB::View::CurrencyNavigationLink.new('name', @model, @session)
  end
  def test_init
    assert_equal('_event_url', @link.init)
  end
  def test_init__else
    flexmock(@session, :request_path => 'aaa/bbb/ccc/ddd/currency/eee')
    expected = "aaa/bbb/ccc/ddd/currency/name"
    assert_equal(expected, @link.init)
  end

end

  end # View
end # ODDB
