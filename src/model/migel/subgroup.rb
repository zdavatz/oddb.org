#!/usr/bin/env ruby
#  -- oddb -- 19.09.2005 -- ffricker@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'model/migel/product'
require 'model/limitationtext'
require 'util/language'

module ODDB
	module Migel
		class Subgroup
			include SimpleLanguage 
			ODBA_SERIALIZABLE = ['@descriptions']
			attr_accessor :group
			attr_reader :products, :code, :limitation_text
			def initialize(productcd)
				@products = {}
				@code = productcd
			end
			def create_limitation_text
				@limitation_text = LimitationText.new
			end
			def create_product(productcd)
				product = Product.new(productcd)
				product.subgroup = self
				@products.store(productcd, product)
			end
			def product(code)
				@products[code]
			end
		end
	end
end
