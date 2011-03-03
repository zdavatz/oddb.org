#!/usr/bin/env ruby
# State::Interactions::Result -- oddb -- 03.03.2011 -- mhatakeyama@ywesee.com
# State::Interactions::Result -- oddb -- 26.05.2004 -- mhuggler@ywesee.com

require 'view/interactions/result'
require 'state/interactions/global'

module ODDB
	module State
		module Interactions
class Result < State::Interactions::Global
=begin
	class Facade < SimpleDelegator
		attr_reader :obj_class, :objects
		def initialize(obj_class)
			@obj_class = obj_class
			super(@obj_class)
			@objects = [] 
		end
		def add_object(obj)
			@objects.push(obj)
		end
		def empty?
			@objects.empty?
		end
		def objects 
			@objects.sort { |x, y| x.name <=> y.name }
		end
	end
=end
	DIRECT_EVENT = :result
	VIEW = View::Interactions::Result
	REVERSE_MAP = View::Interactions::ResultList::REVERSE_MAP
	ITEM_LIMIT = 150
	LIMITED = false
	attr_reader :object_count, :pages
	def init
		#@facades = {}
		@object_count = 0
		if(@model.nil? || @model.empty?)
			@default_view = ODDB::View::Interactions::EmptyResult
		else
			@model.each { |obj|
				@object_count += 1
			}
			@model.uniq!
			@model.sort! { |x, y| 
				x.name <=> y.name
			}
		end
	end
end
		end
	end
end
