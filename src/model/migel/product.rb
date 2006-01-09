#!/usr/bin/env ruby
# Migel::Product -- oddb -- 14.09.2005 -- spfenninger@ywesee.com

require 'util/language'
require 'model/text'
require 'model/feedback_observer'

module ODDB
	module Migel
		class Product
			include SimpleLanguage
			include FeedbackObserver
			ODBA_SERIALIZABLE = ['@descriptions']
			attr_reader :code, :accessories, :products, :product_text
			attr_accessor :subgroup, :limitation, :price, :type, :date, 
				:qty, :unit, :limitation_text
			alias :pointer_descr :code
			def initialize(code)
				@code = code
				@accessories = []
				@products = []
				@feedbacks = {}
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
			def checkout
				@limitation_text.odba_delete unless(@limitation_text.nil?)
				@product_text.odba_delete unless(@product_text.nil?)
				@unit.odba_delete unless(@unit.nil?)
				@accessories.each { |acc|
					acc.remove_product(self)
				}
				@accessories.odba_delete
				@products.each { |prd|
					prd.remove_accessory(self)
				}
				@products.odba_delete
				if(@feedbacks)
					@feedbacks.values.each { |fb| fb.odba_delete }
					@feedbacks.odba_delete
				end
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
			def delete_limitation_text
				if(lt = @limitation_text)
					@limitation_text = nil
					lt.odba_delete
					lt
				end
			end
			def delete_product_text
				if(pt = @product_text)
					@product_text = nil
					pt.odba_delete
					pt
				end
			end
			def delete_unit
				if(ut = @unit)
					@unit = nil
					ut.odba_delete
					ut
				end
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
		end
	end
end
