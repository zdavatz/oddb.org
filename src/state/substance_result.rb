#!/usr/bin/env ruby
# SubtanceResultState -- oddb -- 23.08.2004 -- maege@ywesee.com

require 'view/substance_result'
require 'state/result'

module ODDB
	class SubstanceResultState < GlobalState
		VIEW = SubstanceResultView
		REVERSE_MAP = ResultList::REVERSE_MAP
		ITEM_LIMIT = 100
		attr_reader :object_count, :pages
		def init
			@object_count = 0
			if(@model.nil? || @model.empty?)
				@default_view = EmptySubstanceResultView
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
		def result
			self
		end
	end
end
