#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Migel::Product -- oddb.org -- 15.08.2011 -- mhatakeyama@ywesee.com
# ODDB::Migel::Product -- oddb.org -- 14.09.2005 -- spfenninger@ywesee.com

require 'util/language'
require 'model/text'
require 'model/feedback_observer'
require 'util/searchterms'
require 'model/migel/item'

module ODDB
	module Migel
		class Product
			include SimpleLanguage
			include FeedbackObserver
			ODBA_SERIALIZABLE = ['@descriptions']
			attr_reader :code, :accessories, :products, :product_text, :items
			attr_accessor :subgroup, :limitation, :price, :type, :date, 
				:qty, :unit, :limitation_text
			alias :pointer_descr :code
			def initialize(code)
				@code = code
				@accessories = []
				@products = []
				@feedbacks = []
        @items = {}
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
      def create_item(pharmacode)
        @items ||= {} 
        itm = ODDB::Migel::Item.new(self)
        @items.store(pharmacode, itm)
        itm
      end
      def item(pharmacode)
        @items[pharmacode]
      end
      def delete_item(pharmacode)
        if(itm = @items.delete(pharmacode))
          @items.odba_isolated_store
          itm
        end
      end
			def adjust_types(hash, app=nil)
				hash = hash.dup
				hash.dup.each { |key, value|
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
				@accessories.dup.each { |acc|
					acc.remove_product(self)
				}
				@accessories.odba_delete
				@products.each { |prd|
					prd.remove_accessory(self)
				}
				@products.odba_delete
				if(@feedbacks)
					@feedbacks.dup.each { |fb| fb.item = nil; fb.odba_store }
					@feedbacks.odba_delete
				end
        @items.odba_delete
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
				terms = [ migel_code, ]
        [ group, group.limitation_text, @subgroup, @subgroup.limitation_text,
          @product_text, self, @limitation_text ].compact.each { |item|
					terms.push(item.send(lang))
				}
				ODDB.search_terms(terms)
			end
			def search_text(lang = :de)
				search_terms(lang).join(' ').downcase
			end
		end
	end
end
