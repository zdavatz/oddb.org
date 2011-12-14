#!/usr/bin/env ruby
# encoding: utf-8
# State::Admin::SelectSubstance -- oddb -- 25.04.2003 -- hwyss@ywesee.com

require 'state/admin/global'
require 'view/admin/selectsubstance'

module ODDB
	module State
		module Admin
module SelectSubstanceMethods
	def update
		pointer = @session.user_input(:pointer)
		substance = nil
    if(pointer.is_a?(SBSM::InvalidDataError))
      pointer = Persistence::Pointer.new(:substance).creator
      update = {
        'lt'	=>	@model.user_input[:substance],
      }
      substance = @session.app.update(pointer, update, unique_email)
    else
			substance = pointer.resolve(@session.app)
    end
		active_agent = @model.active_agent
		aptr = active_agent.pointer
		hash = {
			:dose				=>	@model.user_input[:dose],
			:substance	=>	substance.pointer,
		}
		if(active_agent.is_a?(Persistence::CreateItem))
			active_agent.append(substance.name)
			aptr = active_agent.inner_pointer
		end
		if(!error? && (klass = resolve_state(aptr)))
      model = @session.app.update(@model.pointer, hash, unique_email)
			klass.new(@session, model)
		end
	end
end
class SelectSubstance < State::Admin::Global
	VIEW = View::Admin::SelectSubstance
	include State::Admin::SelectSubstanceMethods
end
		end
	end
end
