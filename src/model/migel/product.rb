#!/usr/bin/env ruby
# Migel::Product -- oddb -- 14.09.2005 -- spfenninger@ywesee.com

require 'util/language'
require 'model/text'

module ODDB
	module Migel
		class Product
			include SimpleLanguage
			ODBA_SERIALIZABLE = ['@descriptions']
			attr_reader :code, :accessories, :products
			attr_accessor :subgroup, :limitation, :price, :type, :date, 
				:unit, :limitation_text, :product_text
			alias :pointer_descr :code
			def initialize(code)
				@code = code
				@accessories = []
				@products = []
			end
			def accessory_code
				@code.split('.', 2).last
			end
			def add_accessory(acc)
				@accessories.push(acc)
				@accessories.odba_isolated_store
				acc
			end
			def add_product(prod)
				if(prod != nil)
					unless(@products.include?(prod))
						if(prod)
							prod.add_accessory(self)
						end
						products.push(prod)
						@products.odba_store
					end
				end
				prod
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
			def localized_name(language)
				[ @product_text, self ].compact.collect { |part|
					part.send(language)
				}.join(': ').gsub("\n", ' ')
			end
			def migel_code
				[ @subgroup.migel_code, @code ].join('.')
			end
			def product_code
				@code.split('.').first
			end
			def remove_accessory(acc)
				if(@accessories.delete(acc))
					@accessories.odba_isolated_store
					acc
				end
			end
			def remove_product(prod)
				prod.remove_accessory(self)
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
			def feedback(id)
				@feedbacks[id.to_i]
			end
			def feedbacks
				@feedbacks ||= {}
			end
			def create_feedback
				feedback = Feedback.new
				feedback.oid = self.feedbacks.keys.max.to_i.next
				self.feedbacks.store(feedback.oid, feedback) 
			end
		end
	end
end
