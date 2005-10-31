#!/usr/bin/env ruby
# State::Migel::Result -- oddb -- 04.10.2005 -- ffricker@ywesee.com

require 'util/oddbapp'
require 'view/migel/result'
require 'view/drugs/result'
require 'delegate'

module ODDB
	module State
		module Migel
class Result < State::Migel::Global
	VIEW = View::Migel::Result
	DIRECT_EVENT = :result
	LIMITED = true
	class SubgroupFacade < SimpleDelegator
		attr_reader :products
		def initialize(subgroup)
			@products = []
			super(subgroup)
		end
		def add_product(prod)
			@products.push(prod)
			prod
		end
	end
	def init
		if(@model.nil? || @model.empty?)
			@default_view = View::Drugs::MigelEmptyResult
		else
		subgroups = {}
		@model.each { |product|
			sg = product.subgroup
			subgroup = (subgroups[sg.migel_code] ||= SubgroupFacade.new(sg))
			subgroup.add_product(product)
		}
		@model = subgroups.values.sort_by { |sg| sg.migel_code }
		@model.each { |sg| sg.products.sort! { |a,b| a.code <=> b.code } }
		end
	end
	def sort
		get_sortby!
		@model.each { |subgroup| 
			subgroup.products.sort! { |a, b| compare_entries(a, b) }
			subgroup.products.reverse! if(@sort_reverse)
		}
		self
	end
end
		end
	end
end
