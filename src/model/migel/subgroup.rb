#!/usr/bin/env ruby
# Migel::Subgroup -- oddb -- 19.09.2005 -- ffricker@ywesee.com

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
			attr_reader :products, :code, :limitation_text, :subgroup
			alias :pointer_descr :code
			def initialize(code)
				@products = {}
				@code = code
			end
			def checkout
				raise "cannot delete nonempty subgroup" unless(@products.empty?)
				@products.odba_delete
				@limitation_text.odba_delete unless(@limitation_text.nil?)
			end
			def create_limitation_text
				@limitation_text = LimitationText.new
			end
			def create_product(productcd)
				product = Product.new(productcd)
				product.subgroup = self
				@products.store(productcd, product)
			end
			def create_limitation_text
				@limitation_text = LimitationText.new
			end
			def delete_limitation_text
				if(lt = @limitation_text)
					@limitation_text = nil
					lt.odba_delete
					lt
				end
			end
			def delete_product(code)
				if(prd = @products.delete(code))
					@products.odba_isolated_store
					prd
				end
			end
			def group_code
				@group.code 
			end
			def migel_code
				[ @group.migel_code, @code ].join('.')
			end
			def product(code)
				@products[code]
			end
		end
	end
end
