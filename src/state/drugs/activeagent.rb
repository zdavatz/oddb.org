#!/usr/bin/env ruby
# State::Drugs::ActiveAgent -- oddb -- 22.04.2003 -- hwyss@ywesee.com 

require 'state/drugs/global'
require 'model/selectsubstance'
require 'state/drugs/selectsubstance'
require 'view/drugs/activeagent'

module ODDB
	module State
		module Drugs
class ActiveAgent < State::Drugs::Global
	VIEW = View::Drugs::RootActiveAgent
	def	delete
		sequence = @model.parent(@session.app) 
		@session.app.delete(@model.pointer)
		ODDB::Sequence.new(@session, sequence)
	end	
	def update
		keys = [:substance, :dose]
		input = user_input(keys, [:substance])
		newstate = self
		unless (error?)
			substance = @session.app.substance(input[:substance]) 
			if(substance.nil?)
				selection = self.substance_selection
				model = ODDB::SelectSubstance.new(input, selection, @model)
				newstate = State::Drugs::SelectSubstance.new(@session, model)
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
			ODDB::ActiveAgent.new(@session, item)
		else
			error = create_error(:e_no_seq_to_activeagent, :substance, @model.substance)
			@errors.store(:substance, error)
			self
		end
	end
end
class CompanyActiveAgent < State::Drugs::ActiveAgent
	def init
		super
		unless(allowed?)
			@default_view = View::Drugs::ActiveAgent
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
	end
end
