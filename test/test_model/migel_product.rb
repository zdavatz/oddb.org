#!/usr/bin/env ruby
#  -- oddb -- 14.09.2005 -- spfenninger@ywesee.com


$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'util/searchterms'
require 'model/migel/group'
require 'model/migel/product'
require 'stub/odba'
require 'flexmock'

module ODDB
	module Migel
		class TestCreateProduct < Test::Unit::TestCase
			def setup
				@subgroup = FlexMock.new
				@subgroup.should_receive(:code).and_return { '04' }
				@subgroup.should_receive(:migel_code).and_return { '03.04' }
				@product = Product.new('01.00.2')
				@product.subgroup = @subgroup
			end
			def test_migel_code
				assert_equal('03.04.01.00.2', @product.migel_code)
			end
			def test_search_terms
				@group = FlexMock.new 'group'
				@group.should_receive(:de).and_return { 'group' }
        lt = LimitationText.new
        lt.descriptions.store 'de', 'Limitation-Text'
        @group.should_receive(:limitation_text).and_return lt
				@subgroup.should_receive(:group).and_return { @group }
				@subgroup.should_receive(:de).and_return { 'subgroup' }
        @subgroup.should_receive(:limitation_text).and_return nil
				expected = [ '030401002', 'group', 'Limitation',
                     'LimitationText', 'Limitation Text', 'subgroup' ]
				assert_equal(expected, @product.search_terms)
			end
			def test_product_writer
				product = FlexMock.new
				product.should_receive(:add_accessory, 1).and_return { |acc| 
					assert_equal(@product, acc)
				}
				res = @product.add_product(product)
				assert_equal(product, res)
				assert_equal([product], @product.products)
				@product.add_product(product)
				assert_equal([product], @product.products)
				product.flexmock_verify
			end
			def test_product_writer__nil
				assert_nothing_raised { @product.add_product(nil) }
				assert_equal([], @product.products)
			end
			def test_product_writer__remove
				product = FlexMock.new
				product.should_receive(:add_accessory).and_return { |acc| 
					assert_equal(@product, acc)
				}
				@product.add_product(product)
				assert_equal([product], @product.products)
				product.should_receive(:remove_accessory, 1).and_return { |acc| 
					assert_equal(@product, acc)
				}
				@product.remove_product(product)
				assert_equal([product], @product.products)
				product.flexmock_verify
			end
			def test_add_accessory
				odba = ODBA.cache = FlexMock.new
				odba.should_receive(:store, 2).and_return { |arg|
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
				odba.should_receive(:store, 2).and_return { |arg|
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
