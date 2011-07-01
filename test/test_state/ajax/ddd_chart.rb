#!/usr/bin/env ruby
# ODDB::State::Ajax::TestDDDChart -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'sbsm/state'
require 'state/ajax/ddd_chart'

module ODDB
  module State
    module Ajax

class TestDDDChart < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @comparable = flexmock('comparable', 
                          :ddd_price => 'ddd_price',
                          :name_base => 'name_base',
                          :size => 'size'
                         )
    sequence = flexmock('sequence', :comparables => [@comparable])
    @package = flexmock('package', 
                        :generic_group_comparables => [@comparable],
                        :sequence  => sequence,
                        :ddd_price => 'ddd_price',
                        :name_base => 'name_base',
                        :size => 'size'
                       )
    flexmock(@comparable, :public_packages => [@package])
    flexmock(sequence, :public_packages => [@package])
    registration = flexmock('registration', :package => @package)
    @session = flexmock('session', 
                        :lookandfeel  => @lnf,
                        :user_input   => '12345123',
                        :registration => registration
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Ajax::DDDChart.new(@session, @model)
  end
  def test_init
    expected = [@comparable, @package]
    assert_equal(expected, @state.init)
  end
end

    end # Ajax
  end # State
end # ODDB
