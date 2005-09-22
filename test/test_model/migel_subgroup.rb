#!/usr/bin/env ruby
# TestCreateSubgroup -- oddb -- 13.09.2005 -- spfenninger@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'model/migel/group'

module ODDB
	module Migel
		class TestSubgroup < Test::Unit::TestCase
			def setup
				@subgroup = Subgroup.new('01')
			end
			def test_create__product
				product = @subgroup.create_product('01.02.2')
				assert_instance_of(ODDB::Migel::Product, product)
				assert_equal({'01.02.2' => product }, @subgroup.products)
				assert_equal('01.02.2', product.code)
				assert_equal(@subgroup, product.subgroup)
				assert_equal(product, @subgroup.product('01.02.2'))
			end
		end
	end
end
