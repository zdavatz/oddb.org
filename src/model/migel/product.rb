#!/usr/bin/env ruby
# Migel::Product -- oddb -- 14.09.2005 -- spfenninger@ywesee.com

require 'util/language'
require 'model/text'

module ODDB
	module Migel
		class Product
			include SimpleLanguage
			ODBA_SERIALIZABLE = ['@descriptions']
			attr_reader :code, :product, :accessories
			attr_accessor :subgroup, :limitation, :price, :type, :date, 
				:unit, :limitation_text, :product_text
			alias :pointer_descr :code
			def initialize(code)
				@code = code
				@accessories = []
			end
			def accessory_code
				@code.split('.', 2).last
			end
			def add_accessory(acc)
				@accessories.push(acc)
				@accessories.odba_isolated_store
				acc
			end
			def adjust_types(hash, app=nil)
				hash = hash.dup
				hash.each { |key, value|
					if(value.is_a?(Persistence::Pointer))
						hash[key] = value.resolve(app)
					end
				}
				hash
			end
			def create_limitation_text
				@limitation_text = LimitationText.new
			end
			def create_product_text
				@product_text = Text::Document.new
			end
			def create_unit
				@unit = Text::Document.new
			end
			def group
				@subgroup.group
			end
			def migel_code
				[ @subgroup.migel_code, @code ].join('.')
			end
			def product_code
				@code.split('.').first
			end
			def product=(prod)
				if(@product)
					@product.remove_accessory(self)
				end
				if(prod)
					prod.add_accessory(self)
				end
				@product = prod
			end
			def remove_accessory(acc)
				if(@accessories.delete(acc))
					@accessories.odba_isolated_store
					acc
				end
			end
			def search_terms(lang = :de)
				terms = [
					migel_code,
				]
				[ @subgroup.group, @subgroup, 
					@product_text, self ].compact.each { |item|
					terms.push(item.send(lang))
				}
				terms.delete_if { |str| str.empty? }
			end
			def search_text(lang = :de)
				text = search_terms(lang).join(' ').downcase
				text
			end
		end
	end
end
