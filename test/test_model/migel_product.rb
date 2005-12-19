#!/usr/bin/env ruby
#  -- oddb -- 14.09.2005 -- spfenninger@ywesee.com


$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'model/migel/group'
require 'model/migel/product'
require 'stub/odba'
require 'flexmock'

module ODDB
	module Migel
		class TestCreateProduct < Test::Unit::TestCase
			def setup
				@subgroup = FlexMock.new
				@subgroup.mock_handle(:code) { '04' }
				#@subgroup.mock_handle(:group_code) { '03' }
				@subgroup.mock_handle(:migel_code) { '03.04' }
				@product = Product.new('01.00.2')
				@product.subgroup = @subgroup
			end
			def test_migel_code
				assert_equal('03.04.01.00.2', @product.migel_code)
			end
			def test_search_terms
				@group = FlexMock.new
				@group.mock_handle(:de) { 'group' }
				@subgroup.mock_handle(:group) { @group }
				@subgroup.mock_handle(:de) { 'subgroup' }
				expected = ['03.04.01.00.2', 'group', 'subgroup' ]
				assert_equal(expected, @product.search_terms)
			end
			def test_product_writer
				product = FlexMock.new
				product.mock_handle(:add_accessory, 1) { |acc| 
					assert_equal(@product, acc)
				}
				res = @product.add_product(product)
				assert_equal(product, res)
				assert_equal([product], @product.products)
				@product.add_product(product)
				assert_equal([product], @product.products)
				product.mock_verify
			end
			def test_product_writer__nil
				assert_nothing_raised { @product.add_product(nil) }
				assert_equal([], @product.products)
			end
			def test_product_writer__remove
				product = FlexMock.new
				product.mock_handle(:add_accessory) { |acc| 
					assert_equal(@product, acc)
				}
				@product.add_product(product)
				assert_equal([product], @product.products)
				product.mock_handle(:remove_accessory, 1) { |acc| 
					assert_equal(@product, acc)
				}
				@product.remove_product(product)
				assert_equal([product], @product.products)
				product.mock_verify
			end
			def test_add_accessory
				odba = ODBA.cache = FlexMock.new
				odba.mock_handle(:store, 2) { |arg|
					assert_equal(@product.accessories, arg)
				}
				acc = FlexMock.new
				res = @product.add_accessory(acc)
				assert_equal([acc], @product.accessories)
				assert_equal(acc, res)
				acc2 = FlexMock.new
				res = @product.add_accessory(acc2)
				assert_equal([acc, acc2], @product.accessories)
				assert_equal(acc2, res)
			ensure
				ODBA.cache = nil
			end
			def test_remove_accessory
				odba = ODBA.cache = FlexMock.new
				odba.mock_handle(:store, 2) { |arg|
					assert_equal(@product.accessories, arg)
				}
				acc = FlexMock.new
				acc2 = FlexMock.new
				@product.accessories.push(acc)
				@product.accessories.push(acc2)
				res = @product.remove_accessory(acc)
				assert_equal([acc2], @product.accessories)
				assert_equal(acc, res)
				res = @product.remove_accessory(acc)
				assert_equal([acc2], @product.accessories)
				assert_equal(nil, res)
				res = @product.remove_accessory(acc2)
				assert_equal([], @product.accessories)
				assert_equal(acc2, res)
			ensure
				ODBA.cache = nil
			end
		end
	end
end
