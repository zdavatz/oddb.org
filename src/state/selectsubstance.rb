#!/usr/bin/env ruby
# SelectSubstanceState -- oddb -- 25.04.2003 -- hwyss@ywesee.com

require 'state/global'
require 'view/selectsubstance'

module ODDB
	class SelectSubstanceState < GlobalState
		VIEW = SelectSubstanceView
		def update
			pointer = @session.user_input(:pointer)
			substance = pointer.resolve(@session.app)
			hash = {
				:dose	=>	@model.user_input[:dose],
				:substance	=>	substance.name,
			}
			if (error?)
				self
			else
				if(@model.active_agent.is_a?(Persistence::CreateItem))
					@model.active_agent.append(substance.name)
				end
				model = @session.app.update(@model.pointer, hash)
				ActiveAgentState.new(@session, model)
			end
		end
	end
end
