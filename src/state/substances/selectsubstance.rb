#!/usr/bin/env ruby
# State::Stubstances::SelectSubstance -- ODDB -- 30.09.2004 -- hwyss@ywesee.com

require 'state/substances/global'
require 'view/substances/selectsubstance'

module ODDB
	module State
		module Substances
class SelectSubstance < State::Substances::Global
	class SubstanceSelection
		attr_accessor :source, :targets
		def initialize(source, targets)
			@source = source
			@targets = targets
		end
	end
	VIEW = View::Substances::SelectSubstance
	def merge
		new_state = self
		if((pointer = @session.user_input(:pointer)) \
			&& (target = pointer.resolve(@session.app)))
			if(target == @model.source)
				@errors.store(:substance, create_error('e_selfmerge_substance', 
					:substance, pointer))
			else
				@session.app.merge_substances(@model.source.pointer, pointer)
				new_state = State::Substances::Substance.new(@session, target)
			end
		else
			@errors.store(:substance, create_error('e_unknown_substance', 
				:substance, pointer))
		end
		new_state
	end
end
		end
	end
end
