#!/usr/bin/env ruby
# encoding: utf-8
# TestEan -- oddb -- 01.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'model/ean13'

class TestEan <Minitest::Test
	def test_new_unchecked
		result = ODDB::Ean13.new_unchecked(" 768190061901 ")
		expected ="7681900619016"
		assert_equal(expected, result)
	end
	def test_new_unchecked2
    result = ODDB::Ean13.new_unchecked(" 76871639 ")
		expected ="7687163900007"
		assert_equal(expected, result)
	end
	def test_new_unchecked3
		assert_raises(SBSM::InvalidDataError) {
			ODDB::Ean13.new_unchecked(" 7687456789163 ")
		}
	end
	def test_initialize2
		result = ODDB::Ean13.new(" 7681900619016 ")
		expected = "7681900619016"
		assert_equal(expected, result)
	end
	def test_initialize3
		assert_raises(SBSM::InvalidDataError) {
			ODDB::Ean13.new(" 768134871639 ")
		}
	end
	def test_Ean13_checksum
		result = ODDB::Ean13.checksum("768045114015")
		expected = "4"
		assert_equal(expected, result)	
	end
	def test_Ean13_checksum2
		result = ODDB::Ean13.checksum("768048869017")
		expected = "2"
		assert_equal(expected, result)	
	end
	def test_Ean13_checksum3
		result = ODDB::Ean13.checksum("7680007007747")
		expected = "0"
		assert_equal(expected, result)	
	end
	def test_valid
		result = ODDB::Ean13.new("7681900619016")
		expected = "7681900619016"
		assert_equal(expected, result)	
	end
	def test_valid2
		assert_raises(SBSM::InvalidDataError) {
			ODDB::Ean13.new(" 7687456789163 ")
		}
	end
end
