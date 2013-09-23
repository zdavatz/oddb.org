#!/usr/bin/env ruby
# encoding: utf-8
# TestComparison -- oddb -- 20.03.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'state/drugs/compare'
require 'model/dose'

module ODDB
	module State 
		module Drugs
class Compare
	class Comparison
		attr_reader :comparables
		class PackageFacade
			attr_reader :package
		end
	end
end
		end
	end
end
class StubComparisonPackage
	attr_reader :comparable_size, :price_public, :name_base
	attr_accessor :comparables, :atc_class
	def initialize(size, price, name=nil)
		@comparable_size, @price_public, @name_base = size, price, name
	end
	def sequence
		self
	end
	def comparables
		if(@comparables)
			@comparables
		else
			[]
		end
	end
end

module ODDB
	module State
		module Drugs
class TestComparison <Minitest::Test
	def setup
		@original = StubComparisonPackage.new(ODDB::Dose.new(10, 'Tabletten'), 1000)
		@pack1 = StubComparisonPackage.new(ODDB::Dose.new(20, 'Tabletten'), 1000)
		@pack2 = StubComparisonPackage.new(ODDB::Dose.new(10, 'Tabletten'), 500)
		@pack3 = StubComparisonPackage.new(ODDB::Dose.new(5, 'Tabletten'), 1000)
		@pack4 = StubComparisonPackage.new(ODDB::Dose.new(5, 'Tabletten'), 0, "a")
		@pack5 = StubComparisonPackage.new(ODDB::Dose.new(5, 'Tabletten'), nil, "b")
		@original.comparables = [@pack1, @pack2, @pack3, @pack4, @pack5]
		@comp = Compare::Comparison.new(@original)
	end
	def test_empty
		assert_equal(false, @comp.empty?)
	end
	def test_price_difference1
		assert_equal(-0.5, @comp.comparables.first.price_difference)
	end
	def test_price_difference2
		assert_equal(-0.5, @comp.comparables[1].price_difference)
	end
	def test_price_difference3
		assert_equal(1.0, @comp.comparables[2].price_difference)
	end
	def test_sort
		assert_equal([@pack2, @pack1, @pack3, @pack4, @pack5], @comp.comparables.collect { |c| c.package})
	end
	def test_enumerable
		collection = @comp.collect { |pack| pack }
		assert_equal(6, collection.size) 
		assert_equal(@original, collection.first.package)
	end
	def test_comparables
		original = StubComparisonPackage.new(ODDB::Dose.new(10, 'Tabletten'), 1000)
		comp = Compare::Comparison.new(original)
		assert_equal(true, comp.empty?)
	end
end
class TestPackageFacade <Minitest::Test
	def setup
		pack1 = StubComparisonPackage.new(ODDB::Dose.new(5, 'Tabletten'), nil)
		pack2 = StubComparisonPackage.new(ODDB::Dose.new(5, 'Tabletten'), 374)
		original = StubComparisonPackage.new(ODDB::Dose.new(5, 'Tabletten'), nil)
		@pack1 = Compare::Comparison::PackageFacade.new(pack1, original)
		@pack2 = Compare::Comparison::PackageFacade.new(pack2, original)
	end
	def test_comparable
		@pack1 <=> @pack2
    assert(@pack1 != @pack2)
	end
end
		end
	end
end
