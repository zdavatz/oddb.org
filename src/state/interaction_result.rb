#!/usr/bin/env ruby
# InteractionResultState -- oddb -- 26.05.2004 -- maege@ywesee.com

require 'view/interaction_result'
require 'state/result'

module ODDB
	class InteractionResultState < GlobalState
=begin
		class InteractionFacade < SimpleDelegator
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
		VIEW = InteractionResultView
		REVERSE_MAP = ResultList::REVERSE_MAP
		ITEM_LIMIT = 150
		attr_reader :object_count, :pages
		def init
			@facades = {}
			@object_count = 0
			if(@model.nil? || @model.empty?)
				@default_view = EmptyResultView
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
=begin
		def check_facades(obj_class, obj)
			if(@facades.keys.include?(obj_class))
				@facades[obj_class].add_object(obj)
			else
				facade = InteractionFacade.new(obj_class)
				facade.add_object(obj)
				@facades.store(facade.obj_class, facade)
			end
		end
=end
		def result
			self
		end
	end
end
