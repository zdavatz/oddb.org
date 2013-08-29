#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestTabNavigation -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/tab_navigation'
require 'view/navigationlink'

module ODDB
  module View

class TestTabNavigation < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup   => 'lookup',
                          :enabled? => nil,
                          :zones    => ['zone1', 'zone2'],
                          :attributes => {}
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model')
    @composite = ODDB::View::TabNavigation.new(@model, @session)
  end
  def test_init
    expected = {[0, 0] => "tabnavigation", [2, 0] => "tabnavigation"}
    assert_equal(expected, @composite.init)
  end
  def test_init__enabled
    flexmock(@lnf, :enabled? => true)
    expected = {[0, 0] => "tabnavigation", [2, 0] => "tabnavigation"}
    assert_equal(expected, @composite.init)
  end
  def test_build_navigation
    assert_equal(["zone1", "zone2"], @composite.build_navigation)
  end
  def test_build_custom_navigation__tab_navigation_link
    assert_equal(['zone1', 'zone2'], @composite.build_custom_navigation)
  end
  def test_build_custom_navigation__navigation_link
    zone = flexmock('zone', 
                    :is_a? => true,
                    :direct_event => 'direct_event'
                   )
    flexmock(@lnf, :zones => [zone])
    assert_equal([zone], @composite.build_custom_navigation)
  end
  def test_to_html
    expected = "<TABLE cellspacing=\"0\" class=\"component tabnavigation right\"><TR><TD>lookup</TD><TD>lookup</TD><TD>lookup</TD></TR></TABLE>"
    context  = flexmock('context', :table => 'table')
    assert_equal(expected, @composite.to_html(context))
  end
  def test_to_html__components_empty
    flexmock(@lnf, :zones => [])
    composite = ODDB::View::TabNavigation.new(@model, @session)
    context  = flexmock('context', :table => 'table')
    assert_equal('&nbsp;', composite.to_html(context))
  end

end

  end # View
end # ODDB
