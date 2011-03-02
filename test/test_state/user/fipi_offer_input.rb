#!/usr/bin/env ruby
# State::User::TestFiPiOfferInput -- oddb -- 02.03.2011 -- mhatakeyama@ywesee.com
# State::User::TestFiPiOfferInput -- oddb -- 09.09.2004 -- jlang@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/user/fipi_offer_input'

module ODDB
	module State
		module User
class TestFiPiOffer < Test::Unit::TestCase
	def setup
		@offer = FiPiOfferInput::FiPiOffer.new
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
		@offer.fi_update = 'update_adsf'
		assert_equal(0, @offer.fi_update_charge)
	end
	def test_pi_update_charge
		assert_equal(0, @offer.fi_update_charge)
		@offer.fi_update = 'update_adsf'
		assert_equal(0, @offer.fi_update_charge)
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
end
		end
	end
end
