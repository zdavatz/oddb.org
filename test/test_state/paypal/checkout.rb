#!/usr/bin/env ruby
# ODDB::State::PayPal::TestCheckout -- oddb.org -- 18.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
#$: << File.expand_path("..", File.dirname(__FILE__))

module ODDB
  module State
    module PayPal
      module Checkout
      end
    end
  end
end

require 'test/unit'
require 'flexmock'
require 'state/paypal/checkout'

module ODDB
  module State
    module PayPal
      class StubCheckout
        include Checkout
        def initialize(session, model)
          @session = session
          @model   = model
        end
      end
    end
  end
end

module ODDB
	module State
		module PayPal

class TestStubCheckout < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @session  = flexmock('session')
    @model    = flexmock('model')
    @checkout = ODDB::State::PayPal::StubCheckout.new(@session, @model)
  end
  def test_checkout_mandatory
    flexmock(@session, :logged_in? => nil)
    expected = [:salutation, :name_last, :name_first, :email, :pass, :set_pass_2]
    assert_equal(expected, @checkout.checkout_mandatory)
  end
  def test_checkout_keys
    flexmock(@session, :logged_in? => nil)
    expected = [:salutation, :name_last, :name_first, :email, :pass, :set_pass_2]
    assert_equal(expected, @checkout.checkout_keys)
  end
  def test_ajax_autofill
    flexmock(@session, 
             :user_input          => 'email',
             :yus_get_preferences => {'key' => 'value'},
             :logged_in?          => nil
            )
    assert_kind_of(ODDB::State::PayPal::AjaxCheckout, @checkout.ajax_autofill)
  end
  def test_currency
    assert_equal('EUR', @checkout.currency)
  end
=begin
  def test_user_input
    assert_equal('super', @checkout.user_input('keys', 'mandatory'))
  end
=end
end

		end # PayPal
	end # State
end # ODDB
