#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::TestAllZones -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/all_zones'

module ODDB 
  module State

class StubSuper
  def zone
    'zone_super'
  end
  def zone_navigation
    'zone_navigation_super'
  end
end
class StubAllZones < StubSuper
  include AllZones
  def initialize(previous)
    @previous = previous
  end
end

class TestAllZones < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @previous = flexmock('previous')
    @state = ODDB::State::StubAllZones.new(@previous)
  end
  def test_zone
    flexmock(@previous, :zone => 'zone')
    assert_equal('zone', @state.zone)
  end
  def test_zone__else
    assert_equal('zone_super', @state.zone)
  end
  def test_zone_navigation
    flexmock(@previous, :zone_navigation => 'zone_navigation')
    assert_equal('zone_navigation', @state.zone_navigation)
  end
  def test_zone_navigation__else
    assert_equal('zone_navigation_super', @state.zone_navigation)
  end
end
  end # State
end # ODDB
