#!/usr/bin/env ruby
# Migel::Group -- oddb -- 13.09.2005 -- ffricker@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'model/migel/subgroup'
require 'util/language'
require 'model/text'

module ODDB
	module Migel
		class Group 	
			include SimpleLanguage
			ODBA_SERIALIZABLE = ['@descriptions']
			attr_reader :subgroups, :code
			attr_accessor :limitation_text, :group
			alias :pointer_descr :code
			def initialize(sgcd)
				@code = sgcd
				@subgroups = {}
			end
			def checkout
				raise "cannot delete nonempty group" unless(@groups.empty?)
				@groups.odba_delete
				@limitation_text.odba_delete unless(@limitation_text.nil?)
			end
			def create_limitation_text
				@limitation_text = LimitationText.new
			end
			def create_subgroup(sgcd)
				subgroup = Subgroup.new(sgcd)
				subgroup.group = self
				@subgroups.store(sgcd, subgroup)
			end
			def delete_limitation_text
				if(lt = @limitation_text)
					@limitation_text = nil
					lt.odba_delete
					lt
				end
			end
			def delete_subgroup(code)
				if(sbg = @subgroups[code])
					@subgroups.odba_isolated_store
					sbg
				end
			end
			def migel_code
				@code
			end
			def subgroup(code)
				@subgroups[code]
			end
		end
	end
end
