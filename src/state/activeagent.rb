#!/usr/bin/env ruby
# ActiveAgentState -- oddb -- 22.04.2003 -- hwyss@ywesee.com 

require 'state/global'
require 'state/selectsubstance'
require 'model/selectsubstance'
require 'view/activeagent'

module ODDB
	class ActiveAgentState < GlobalState
		VIEW = RootActiveAgentView
		def	delete
			sequence = @model.parent(@session.app) 
			@session.app.delete(@model.pointer)
			SequenceState.new(@session, sequence)
		end	
		def update
			keys = [:substance, :dose]
			input = user_input(keys, [:substance])
			newstate = self
			unless (error?)
				substance = @session.app.substance(input[:substance]) 
				if(substance.nil?)
					selection = self.substance_selection
					model = SelectSubstance.new(input, selection, @model)
					newstate = SelectSubstanceState.new(@session, model)
				elsif(@model.substance != substance && \
					@model.sequence.active_agent(substance))
					error = create_error(:e_seq_dup_substance, :substance, input[:substance])
					@errors.store(:substance, error)
				else
					if(@model.is_a?(Persistence::CreateItem))
						@model.append(input[:substance])
					end
					input[:substance] = substance.pointer
					@model = @session.app.update(@model.pointer, input)
				end
			end
			newstate
		end
		def substance_selection 
			sub = @session.user_input(:substance)
			sequence = @model.parent(@session.app)
			comparable = @session.app.soundex_substances(sub)
			comparable - sequence.substances
		end
		def new_active_agent
			unless((sequence = @model.sequence).nil?)
				aa_pointer = sequence.pointer + [:active_agent]
				item = Persistence::CreateItem.new(aa_pointer)
				item.carry(:iksnr, sequence.iksnr)
				item.carry(:name_base, sequence.name_base)
				item.carry(:sequence, sequence)
				item.carry(:dose, " ")
				item.carry(:substance, " ")
				ActiveAgentState.new(@session, item)
			else
				error = create_error(:e_no_seq_to_activeagent, :substance, @model.substance)
				@errors.store(:substance, error)
				self
			end
		end
	end
	class CompanyActiveAgentState < ActiveAgentState
		def init
			super
			unless(allowed?)
				@default_view = ActiveAgentView
			end
		end
		def delete
			if(allowed?)
				super
			end
		end
		def update
			if(allowed?)
				super
			end
		end
		private
		def allowed?
			((seq = @model.sequence) && @session.user_equiv?(seq.company))
		end
	end
end
