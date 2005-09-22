#!/usr/bin/env ruby
# Migel::Product -- oddb -- 14.09.2005 -- spfenninger@ywesee.com

require 'util/language'
require 'model/text'

module ODDB
	module Migel
		class Product
			include SimpleLanguage
			ODBA_SERIALIZABLE = ['@descriptions']
			attr_reader :code
			attr_accessor :subgroup, :price, :type, :date, 
				:unit, :limitation_text
			def initialize(code)
				@code = code
				@products = {}
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
			def create_unit
				@unit = ODDB::Text::Document.new
			end
		end
	end
end

