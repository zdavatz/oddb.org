#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestDose -- oddb.org -- 06.07.2011 -- mhatakeyama@ywesee.com 
# ODDB::TestDose -- oddb.org -- 25.02.2003 -- hwyss@ywesee.com 

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/dose'
require 'util/quanty'

class TestDose <Minitest::Test
  include FlexMock::TestCase
	def setup
		@dose = ODDB::Dose.new('1,7', 'mL')
	end
	def test_initialize1
		vals = ['Aspirin, Tabletten', '12', '500', 'mg', 'D']
		dose = ODDB::Dose.new(*vals[2,2])
		assert_equal(500, dose.qty)
		assert_equal('mg', dose.unit.to_s)
		assert_equal('500 mg', dose.to_s)
	end
	def test_initialize2
		vals = ['Hametum, Salbe', '62.5', 'mg/g', 'D']
		dose = ODDB::Dose.new(*vals[1,2])
		assert_equal(62.5, dose.qty)
		assert_equal('mg/g', dose.unit.to_s)
		assert_equal('62.5 mg/g', dose.to_s)
	end
	def test_initialize3
		dose = ODDB::Dose.new('1,7', 'mL')
		assert_equal(1.7, dose.qty)
		assert_equal('ml', dose.unit.to_s)
		assert_equal('1.7 ml', dose.to_s)
	end
	def test_initialize4
		compare = ODDB::Dose.new(6.25, 'mg/g')
		vals = ['62.5', 'mg/10g']
		dose = ODDB::Dose.new(*vals)
		assert_equal(6.25, dose.qty)
		assert_equal('mg/g', dose.unit.to_s)
		assert_equal('62.5mg / 10g', dose.to_s)
		assert_equal(0, compare<=>dose)
		assert_equal(compare, dose)
	end
	def test_initialize5
		compare = ODDB::Dose.new(0.5, 'mg/ml')
		vals = [1, 'mg/2ml']
		dose = ODDB::Dose.new(*vals)
		assert_equal(0.5, dose.qty)
		assert_equal('mg/ml', dose.unit.to_s)
		assert_equal('1mg / 2ml', dose.to_s)
		assert_equal(0, compare<=>dose)
		assert_equal(compare, dose)
	end
	def test_initialize6
		vals = ['62.5', ' mg / 10g']
		dose = ODDB::Dose.new(*vals)
		assert_equal(6.25, dose.qty)
		assert_equal('mg/g', dose.unit.to_s)
		assert_equal('62.5mg / 10g', dose.to_s)
	end
	def test_initialize7
		dose = ODDB::Dose.new('0.025', '%')
		assert_equal(0.025, dose.qty)
		assert_equal('%', dose.unit.to_s)
		assert_equal('0.025 %', dose.to_s)
	end
	def test_initialize8
		dose = ODDB::Dose.new('40-60', 'mg')
		assert_equal(50, dose.qty)
		assert_equal('mg', dose.unit.to_s)
		assert_equal('40-60 mg', dose.to_s)
	end
  def test_arithmetics
		dose1 = ODDB::Dose.new(10, 'mg')
		dose2 = ODDB::Dose.new(5, 'mg')
		dose3 = ODDB::Dose.new(2, 'ml')
    assert_equal dose1, dose2 + dose2
    assert_equal dose2, dose1 - dose2
    assert_equal dose1, dose2 * 2
    assert_equal dose2, dose1 / 2
    assert_equal ODDB::Dose.new(5, 'mg/ml'), dose1 / dose3
    assert_equal ODDB::Dose.new(100, 'mg mg'), dose1 ** 2
  end
	def test_comparable1
		dose1 = ODDB::Dose.new(10, 'mg')
		dose2 = ODDB::Dose.new(10, 'mg')
		assert_equal(dose1, dose2)
	end
	def test_comparable2
		dose1 = ODDB::Dose.new(10, 'mg')
		dose2 = ODDB::Dose.new(10, 'g')
		assert(dose2 > dose1, "dose2 was not > dose1")
	end
	def test_comparable3
		dose1 = ODDB::Dose.new(1000, 'I.E.')
		dose2 = ODDB::Dose.new(500, 'I.E.')
		assert(dose2 < dose1, "dose2 was not < dose1")
	end
	def test_comparable4
		dose1 = ODDB::Dose.new(1000, 'mg')
		dose2 = ODDB::Dose.new(500, 'I.E.')
		assert_equal(-1, dose2 <=> dose1, "dose2 was not < dose1")
	end
	def test_comparable5
		dose1 = ODDB::Dose.new(1000, 'mg')
		dose2 = ODDB::Dose.new(500, 'l')
		assert_equal(-1, dose2 <=> dose1, "dose2 was not < dose1")
	end
	def test_comparable6
		dose1 = ODDB::Dose.new(1000, 'mg')
		dose2 = ODDB::Dose.new(1, 'g')
		assert(dose2 == dose1, "dose2 was not == dose1")
	end
	def test_comparable7
		dose1 = ODDB::Dose.new('400-600', 'mg')
		dose2 = ODDB::Dose.new('0.4-0.6', 'g')
		assert(dose2 == dose1, "dose2 was not == dose1")
	end
	def test_comparable8
		dose1 = ODDB::Dose.new('1000', 'µg')
		dose2 = ODDB::Dose.new('1', 'mg')
		assert(dose2 == dose1, "dose2 was not == dose1")
	end
	def test_comparable9
		dose1 = ODDB::Dose.new('1000', nil) 
		dose2 = ODDB::Dose.new('1', 'mg')
		assert(dose2 > dose1, "dose2 was not > dose1")
		assert(dose1 < dose2, "dose1 was not < dose2")
	end
	def test_complex_unit
		dose = nil
		dose = ODDB::Dose.new(20.0, 'mg/5ml')
	end
	def test_from_quanty
		quanty = Quanty.new(1,'mg')
		result = ODDB::Dose.from_quanty(quanty)
		assert_instance_of(ODDB::Dose, result)
		assert_equal(ODDB::Dose.new(1, 'mg'), result)
    second = ODDB::Dose.from_quanty result
    assert_equal result, second
    assert_equal result.object_id, second.object_id
    other = flexmock('other')
    assert_kind_of(ODDB::Dose, ODDB::Dose.from_quanty(other))
	end	
	def test_multiplication
		dose1 = ODDB::Dose.new(1,'ml')
		dose2 = ODDB::Dose.new(1.7,'kg')
		assert_equal(ODDB::Dose.new(1.7, 'ml kg'), dose1 * dose2)
	end
	def test_robust_initalizer
		ODDB::Dose.new(12)
	end
	def test_robust_to_f
		dose = ODDB::Dose.new(12, 'mg')
		dose.to_f
	end
  def test_scale
    assert_nil @dose.scale
    dose = ODDB::Dose.new(100, 'µg / 2 h')
    assert_equal ODDB::Dose.new(2, 'h'), dose.scale
  end
  def test_ug_h
    dose = ODDB::Dose.new(100, 'µg/h')
    assert_equal('100 µg/h', dose.to_s)
  end
  def test_to_i
    assert_equal 1, @dose.to_i
  end
  def test_to_s
    assert_equal '1.7 ml', @dose.to_s
    dose = ODDB::Dose.new(100, 'µg / 2 h')
    assert_equal '100µg / 2h', dose.to_s
  end
  def test_want
    wanted = @dose.want 'cl'
    assert_instance_of ODDB::Dose, wanted
    assert_equal 'cl', wanted.unit
    assert_equal 0.17, wanted.qty
  end
end
