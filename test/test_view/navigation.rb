#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestNavigation -- oddb.org -- 20.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/navigation'

module ODDB
  module View

class TestNavigation <Minitest::Test
  include FlexMock::TestCase
  def setup
    @navigation = flexmock('navigation',
                            :each_with_index => 'each_with_index',
                            :sort_by => [],
                            :empty? => false,
                            )
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :navigation => @navigation,
                          :attributes => {},
                          :direct_event => 'direct_event',
                          :_event_url => '_event_url'
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model')
    @composite = ODDB::View::Navigation.new(@model, @session)
  end
  def test_home
    assert_kind_of(ODDB::View::NavigationLink, @composite.home(@model))
  end
  def test_build_navigation
    state = flexmock('state', :direct_event => 'direct_event')
    assert_equal([state], @composite.build_navigation([state]))
  end
end

class TestZoneNavigation <Minitest::Test
  include FlexMock::TestCase
  def test_build_navigation
    @zone_navigation = flexmock('zone_navigation',
                                :sort_by => ['zone_navigation'],
                                :each_with_index => 'each_with_index',
                                :empty? => false,
                          )
    @lnf       = flexmock('lookandfeel', 
                          :lookup => 'lookup',
                          :attributes   => {},
                          :direct_event => 'direct_event',
                          :_event_url   => '_event_url',
                          :zone_navigation => @zone_navigation,
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model')
    @composite = ODDB::View::ZoneNavigation.new(@model, @session)
    expected = ["zone_navigation"]
    assert_equal(expected, @composite.build_navigation)
  end
  def test_build_navigation__else
    state = flexmock('state', :direct_event => 'direct_event')
    @lnf       = flexmock('lookandfeel', 
                          :lookup => 'lookup',
                          :attributes   => {},
                          :direct_event => 'direct_event',
                          :_event_url   => '_event_url',
                          :zone_navigation => [state],
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model')
    @composite = ODDB::View::ZoneNavigation.new(@model, @session)
    expected = [state]
    assert_equal(expected, @composite.build_navigation)
  end
end

class TestCountryNavigation <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {}
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model')
    @composite = ODDB::View::CountryNavigation.new(@model, @session)
  end
  def test_link
    assert_kind_of(HtmlGrid::Link, @composite.link('key', @model))
  end
end
  end # View
end # ODDB
