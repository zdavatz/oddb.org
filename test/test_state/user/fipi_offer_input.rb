#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::User::TestFiPiOfferInput -- oddb.org -- 28.04.2011 -- mhatakeyama@ywesee.com
# ODDB::State::User::TestFiPiOfferInput -- oddb.org -- 09.09.2004 -- jlang@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/user/fipi_offer_input'
require 'htmlgrid/select'
require 'state/user/fipi_offer_confirm'

module ODDB
	module State
		module User

class TestFiPiOffer <Minitest::Test
  include FlexMock::TestCase
	def setup
		@offer = ODDB::State::User::FiPiOfferInput::FiPiOffer.new
	end
	def test_fi_quantity
		assert_equal(0, @offer.fi_quantity)
		@offer.fi_quantity = 2
		assert_equal(2, @offer.fi_quantity)
		@offer.fi_quantity = "3"
		assert_equal(3, @offer.fi_quantity)
		@offer.fi_quantity = ""
		assert_equal(0, @offer.fi_quantity)
		@offer.fi_quantity = "0"
		assert_equal(0, @offer.fi_quantity)
		@offer.fi_quantity = 0
		assert_equal(0, @offer.fi_quantity)
	end
	def test_pi_quantity
		assert_equal(0, @offer.fi_quantity)
		@offer.fi_quantity = 2
		assert_equal(2, @offer.fi_quantity)
		@offer.fi_quantity = "3"
		assert_equal(3, @offer.fi_quantity)
		@offer.fi_quantity = ""
		assert_equal(0, @offer.fi_quantity)
		@offer.fi_quantity = "0"
		assert_equal(0, @offer.fi_quantity)
		@offer.fi_quantity = 0
		assert_equal(0, @offer.fi_quantity)
	end
	def test_fi_update_charge
		assert_equal(0, @offer.fi_update_charge)
		@offer.fi_update = 'update_ywesee'
		assert_equal(150, @offer.fi_update_charge)
	end
	def test_pi_update_charge
		assert_equal(0, @offer.pi_update_charge)
		@offer.pi_update = 'update_ywesee'
		assert_equal(90, @offer.pi_update_charge)
	end
	def test_calculate_total
		assert_equal(2500, @offer.calculate_total)
	end
	def test_calculate_fi_update
		assert_equal(0, @offer.calculate_fi_update)
		@offer.fi_quantity = 1
		@offer.fi_update = 'update_ywesee'
		assert_equal(150, @offer.calculate_fi_update)
		@offer.fi_quantity = 3
		@offer.fi_update = 'update_ywesee'
		assert_equal(450, @offer.calculate_fi_update)
	end
	def test_calculate_pi_update
		assert_equal(0, @offer.calculate_pi_update)
		@offer.pi_quantity = 1
		@offer.pi_update = 'update_ywesee'
		assert_equal(90, @offer.calculate_pi_update)
		@offer.pi_quantity = 3
		@offer.pi_update = 'update_ywesee'
		assert_equal(270, @offer.calculate_pi_update)
	end
  def test_activation_count
    assert_equal(2, @offer.activation_count)
  end
  def test_fi_charge
    assert_equal(350, @offer.fi_charge)
  end
  def test_pi_charge
    assert_equal(120, @offer.pi_charge)
  end
  def test_pi_quantity
    assert_equal(0, @offer.pi_quantity)
  end
  def test_calculate_fi_charge
    @offer.fi_quantity = 100
    assert_equal(35000, @offer.calculate_fi_charge)
  end
  def test_calculate_pi_charge
    @offer.pi_quantity = 100
    assert_equal(12000, @offer.calculate_pi_charge)
  end
end

class TestFiPiOfferInput <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @state   = ODDB::State::User::FiPiOfferInput.new(@session, @model)
  end
  def test_calculate_offer
    flexmock(@session, :user_input => {:name => 'name'})
    assert_equal(@state, @state.calculate_offer)
  end
  def test_calculate_offer__quant_more_0
    flexmock(@session, :user_input => {:name => 'name', :fi_quantity => 1, :pi_quantity => 2})
    assert_kind_of(ODDB::State::User::FiPiOfferConfirm, @state.calculate_offer)
  end

end


		end
	end
end
