#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::TestPaymentMethod -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/global'
require 'state/drugs/payment_method'

module ODDB
  module State
    module Drugs

class TestPaymentMethod <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @user    = flexmock('user')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user_input  => 'user_input',
                        :user => @user
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Drugs::PaymentMethod.new(@session, @model)
  end
  def test_init
    assert_equal(@user, @state.init)
  end
  def test_proceed_payment
    flexmock(@user, :creditable? => nil)
    assert_kind_of(ODDB::State::Drugs::RegisterDownload, @state.proceed_payment)
  end
  def test_proceed_payment__creditable
    flexmock(@session, :user_input => 'pm_invoice')
    flexmock(@user, :creditable? => true)
    assert_kind_of(ODDB::State::Drugs::RegisterDownload, @state.proceed_payment)
  end
end

    end # Drugs
  end # State
end # ODDB
