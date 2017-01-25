#!/usr/bin/env ruby
$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'ruby-units'
require 'util/money'
require 'minitest/autorun'
module ODDB
  class TestSequence <Minitest::Test
    def setup
      @size = Unit.new('30 ml')
      @mdose = Unit.new('40 mg/ml')
      @ddose = Unit.new('0.5 g')
      @factor = 1.0
    end
    def test_case_Disflatyl
      price = Unit.new('6.45 USD')
      _ddd_price = price / ((@mdose * @size).base / @ddose.base)
      assert_equal('2.6875 USD', _ddd_price.to_s)
    end
    def test_case_Disflatyl_SFR
      price_sfr = ODDB::Util::Money.new(6.45)
      _ddd_price_swiss = price_sfr / ((@mdose * @size).base / @ddose.base)
      assert_equal('2.69', _ddd_price_swiss.to_s)
    end
    def test_600_ui
      result = Unit.new('600 UI')
      assert_equal(true, result)
    end
    def test_10_UI_per_ml
      result = Unit.new('10 UI/ml')
      assert_equal(true, result)
    end
  end
end

