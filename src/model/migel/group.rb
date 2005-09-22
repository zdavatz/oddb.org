#!/usr/bin/env ruby
#  -- oddb -- 13.09.2005 -- ffricker@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'model/migel/subgroup'
require 'util/language'

module ODDB
	module Migel
		class Group 	
			include SimpleLanguage
			ODBA_SERIALIZABLE = ['@descriptions']
			attr_reader :subgroups, :code
			def initialize(sgcd)
				@code = sgcd
				@subgroups = {}
			end
			def create_subgroup(sgcd)
				subgroup = Subgroup.new(sgcd)
				subgroup.group = self
				@subgroups.store(sgcd, subgroup)
			end
			def subgroup(code)
				@subgroups[code]
			end
		end
	end
end
