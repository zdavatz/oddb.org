#!/usr/bin/env ruby
# State::Substances::Result -- oddb -- 23.08.2004 -- maege@ywesee.com

require 'view/substances/result'

module ODDB
	module State
		module Substances
class Result < State::Substances::Global
	VIEW = View::Substances::Result
	DIRECT_EVENT = :search
	#REVERSE_MAP = View::Substances::ResultList::REVERSE_MAP
	ITEM_LIMIT = 100
	attr_reader :object_count, :pages
	def init
		@object_count = 0
		if(@model.nil? || @model.empty?)
			@default_view = View::Substances::EmptyResult
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
