#!/usr/bin/env ruby
# State::Drugs::SelectSubstance -- oddb -- 25.04.2003 -- hwyss@ywesee.com

require 'state/drugs/global'
require 'view/drugs/selectsubstance'

module ODDB
	module State
		module Drugs
class SelectSubstance < State::Drugs::Global
	VIEW = View::Drugs::SelectSubstance
	def update
		pointer = @session.user_input(:pointer)
		substance = pointer.resolve(@session.app)
		if(pointer.skeleton == [:create])
			update = {
				'lt'	=>	@model.user_input[:substance],
			}
			@session.app.update(substance.pointer, update)
		end
		if (error?)
			self
		else
			hash = {
				:dose				=>	@model.user_input[:dose],
				:substance	=>	substance.pointer,
			}
			if(@model.active_agent.is_a?(Persistence::CreateItem))
				@model.active_agent.append(substance.name)
			end
			model = @session.app.update(@model.pointer, hash)
			State::Drugs::ActiveAgent.new(@session, model)
		end
	end
end
		end
	end
end
