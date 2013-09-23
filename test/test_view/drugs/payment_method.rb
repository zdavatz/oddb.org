#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::TestPaymentMethod -- oddb.org -- 22.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/errormessage'
require 'htmlgrid/select'
require 'htmlgrid/list'
require 'view/paypal/invoice'
require 'view/drugs/payment_method'


module ODDB
  module View
    module Drugs

class TestPaymentMethodForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :error       => 'error',
                        :error?      => nil
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::Drugs::PaymentMethodForm.new(@model, @session)
  end
  def test_init
    assert_nil(@form.init)
  end
  def test_init__error
    flexmock(@session, :error? => true)
    assert_equal('processingerror', @form.init)
  end
  def test_hidden_fields
    state = flexmock('state', 
                     :search_query => 'search_query',
                     :search_type  => 'search_type'
                    )
    flexmock(@session, 
             :state => state,
             :zone  => 'zone'
            )
    flexmock(@lnf, 
             :flavor   => 'flavor',
             :language => 'language'
            )
    context = flexmock('context', :hidden => 'hidden')
    expected = "hiddenhiddenhiddenhiddenhiddenhiddenhidden"
    assert_equal(expected, @form.hidden_fields(context))
  end
end

    end # Drugs
  end # View
end # ODDB

