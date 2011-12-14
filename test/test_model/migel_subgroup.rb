#!/usr/bin/env ruby
# encoding: utf-8
# TestCreateSubgroup -- oddb -- 13.09.2005 -- spfenninger@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'stub/odba'
require 'test/unit'
require 'flexmock'
require 'model/migel/group'

module ODDB
  module Migel
    class TestSubgroup < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @subgroup = Subgroup.new('01')
      end
      def test_checkout
        prod = flexmock 'product'
        @subgroup.products.store '02', prod
        assert_raises(RuntimeError) do
          @subgroup.checkout
        end
        @subgroup.products.clear
        assert_nothing_raised do
          @subgroup.checkout
        end
      end
      def test_create_limitation_text
        assert_nil @subgroup.limitation_text
        res = @subgroup.create_limitation_text
        assert_instance_of LimitationText, res
        assert_equal res, @subgroup.limitation_text
      end
      def test_create_product
        product = @subgroup.create_product('01.02.2')
        assert_instance_of(ODDB::Migel::Product, product)
        assert_equal({'01.02.2' => product }, @subgroup.products)
        assert_equal('01.02.2', product.code)
        assert_equal(@subgroup, product.subgroup)
        assert_equal(product, @subgroup.product('01.02.2'))
      end
      def test_delete_limitation_text
        lt = flexmock :odba_delete => true
        @subgroup.instance_variable_set '@limitation_text', lt
        @subgroup.delete_limitation_text
        assert_nil @subgroup.limitation_text
      end
      def test_delete_product
        prod = flexmock 'product'
        @subgroup.products.store '02', prod
        @subgroup.delete_product '02'
        assert_equal({}, @subgroup.products)
      end
      def test_group_code
        @subgroup.group = flexmock :code => '03'
        assert_equal '03', @subgroup.group_code
      end
      def test_migel_code
        @subgroup.group = flexmock :code => '03'
        assert_equal '03.01', @subgroup.migel_code
      end
    end
  end
end
