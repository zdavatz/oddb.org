#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::PayPal::TestReturn -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/paypal/return'

module ODDB
  module State
    module PayPal

class TestReturn < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    item     = flexmock('item')
    @model   = flexmock('model', 
                        :items => {'key' => item},
                        :yus_name => 'yus_name',
                        :oid => 'oid'
                       )
    @state   = ODDB::State::PayPal::Return.new(@session, @model)
  end
  def test_init
    assert_nil(@state.init)
  end
  def test_back
    assert_nil(@state.back)
  end
  def test_paypal_return
    flexmock(@session, :desired_state => 'desired_state')
    flexmock(@model, 
             :types => [:poweruser],
             :payment_received? => true
            )
    assert_equal('desired_state', @state.paypal_return)
  end
  def test_paypal_return__else
    flexmock(@model, 
             :types => [],
             :payment_received? => false
            )
    assert_equal(@state, @state.paypal_return)
  end
end

    end # PayPal
  end # State
end # ODDB
