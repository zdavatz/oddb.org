#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::User::TestRegisterDownload -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../../../src', File.dirname(__FILE__))


module ODDB
  module State
    module PayPal
      module Checkout
      end
    end
  end
end
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/user/register_download'


module ODDB
  module State
    module User

class TestRegisterDownload <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', :logged_in? => nil)
    @state   = ODDB::State::User::RegisterDownload.new(@model, @session)
  end
  def test_checkout_mandatory
    expected = [:salutation, :name_last, :name_first, :email, :pass, :set_pass_2, :address, :plz, :city, :phone]
    assert_equal(expected, @state.checkout_mandatory)
  end
  def test_checkout_keys
    expected = [:salutation, :name_last, :name_first, :email, :pass, :set_pass_2, :address, :plz, :city, :phone, :business_area, :company_name]
    assert_equal(expected, @state.checkout_keys)
  end
end

    end # User
  end # State
end # ODDB
