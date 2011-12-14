#!/usr/bin/env ruby
# encoding: utf-8
#  -- oddb -- 14.09.2005 -- spfenninger@ywesee.com


$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'stub/odba'
require 'test/unit'
require 'util/searchterms'
require 'model/migel/group'
require 'model/migel/product'
require 'flexmock'

module ODDB
	module Migel
		class TestProduct < Test::Unit::TestCase
      include FlexMock::TestCase
			def setup
				@subgroup = FlexMock.new
				@subgroup.should_receive(:code).and_return { '04' }
				@subgroup.should_receive(:migel_code).and_return { '03.04' }
				@product = Product.new('01.00.2')
				@product.subgroup = @subgroup
			end
      def test_accessory_code
        assert_equal '00.2', @product.accessory_code
      end
      def test_adjust_types
        ptr = Persistence::Pointer.new([:migel_product, :id])
        app = flexmock 'application'
        app.should_receive(:migel_product).with(:id).and_return 'resolved'
        data = {
          :something => ptr
        }
        expected = {
          :something => 'resolved'
        }
        assert_equal expected, @product.adjust_types(data, app)
      end
      def test_checkout
        acc1 = flexmock 'accessory1'
        acc1.should_receive(:remove_product).times(1).and_return do
          @product.accessories.delete acc1
          assert true
        end
        acc2 = flexmock 'accessory2'
        acc2.should_receive(:remove_product).times(1).and_return do
          @product.accessories.delete acc2
          assert true
        end
        @product.accessories.push acc1, acc2
        prod1 = flexmock 'product1'
        prod1.should_receive(:remove_accessory).times(1).and_return do
          assert true
        end
        prod2 = flexmock 'product2'
        prod2.should_receive(:remove_accessory).times(1).and_return do
          assert true
        end
        @product.products.push prod1, prod2
        fb1 = flexmock :odba_store => true
        fb1.should_receive(:item=).with(nil).times(1).and_return do
          @product.feedbacks.delete fb1
          assert true
        end
        fb2 = flexmock :odba_store => true
        fb2.should_receive(:item=).with(nil).times(1).and_return do
          @product.feedbacks.delete fb2
          assert true
        end
        @product.feedbacks.push fb1, fb2
        @product.checkout
        assert_equal [], @product.accessories
        assert_equal [], @product.feedbacks
      end
      def test_create_limitation_text
        assert_nil @product.limitation_text
        res = @product.create_limitation_text
        assert_instance_of LimitationText, res
        assert_equal res, @product.limitation_text
      end
      def test_create_product_text
        assert_nil @product.product_text
        res = @product.create_product_text
        assert_instance_of Text::Document, res
        assert_equal res, @product.product_text
      end
      def test_create_unit
        assert_nil @product.unit
        res = @product.create_unit
        assert_instance_of Text::Document, res
        assert_equal res, @product.unit
      end
      def test_delete_limitation_text
        lt = flexmock :odba_delete => true
        @product.instance_variable_set '@limitation_text', lt
        @product.delete_limitation_text
        assert_nil @product.limitation_text
      end
      def test_delete_product_text
        lt = flexmock :odba_delete => true
        @product.instance_variable_set '@product_text', lt
        @product.delete_product_text
        assert_nil @product.product_text
      end
      def test_delete_unit
        lt = flexmock :odba_delete => true
        @product.instance_variable_set '@unit', lt
        @product.delete_unit
        assert_nil @product.unit
      end
      def test_localized_name
        @product.descriptions.update 'fr' => 'Description', 'de' => 'Beschreibung'
        assert_equal 'Beschreibung', @product.localized_name(:de)
        assert_equal 'Description', @product.localized_name(:fr)
        pt = @product.create_product_text
        pt.descriptions.store 'de', 'ProductText'
        assert_equal 'ProductText: Beschreibung', @product.localized_name(:de)
        assert_equal 'ProductText: Description', @product.localized_name(:fr)
      end
			def test_migel_code
				assert_equal('03.04.01.00.2', @product.migel_code)
			end
			def test_product_code
				assert_equal('01', @product.product_code)
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
      def test_search_text
        @group = FlexMock.new 'group'
        @group.should_receive(:de).and_return { 'group' }
        lt = LimitationText.new
        lt.descriptions.store 'de', 'Limitation-Text'
        @group.should_receive(:limitation_text).and_return lt
        @subgroup.should_receive(:group).and_return { @group }
        @subgroup.should_receive(:de).and_return { 'subgroup' }
        @subgroup.should_receive(:limitation_text).and_return nil
        expected = '030401002 group limitation limitationtext limitation text subgroup'
        assert_equal(expected, @product.search_text)
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
