#!/usr/bin/env ruby
#  -- oddb -- 14.09.2005 -- spfenninger@ywesee.com


$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'model/migel/group'
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
=begin
			def test_is_accessory?
				assert_equal(false, @product.is_accessory?)
				acc = Product.new('01.01.2')
				assert_equal(true, acc.is_accessory?)
			end
=end
		end
	end
end
