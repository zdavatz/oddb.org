#!/usr/bin/env ruby
# State::Admin::ActiveAgent -- oddb -- 22.04.2003 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'model/selectsubstance'
require 'state/admin/selectsubstance'
require 'state/admin/sequence'
require 'view/admin/activeagent'

module ODDB
	module State
		module Admin
module ActiveAgentMethods
	def	delete
		sequence = @model.parent(@session.app) 
		if(klass = resolve_state(sequence.pointer))
			@session.app.delete(@model.pointer)
			klass.new(@session, sequence)
		end
	end	
	def new_active_agent
		unless((sequence = @model.sequence).nil?)
			aa_pointer = sequence.pointer + [:active_agent]
			item = Persistence::CreateItem.new(aa_pointer)
			item.carry(:iksnr, sequence.iksnr)
			item.carry(:name_base, sequence.name_base)
			item.carry(:sequence, sequence)
			#item.carry(:dose, " ")
			#item.carry(:substance, " ")
			if (klass=resolve_state(aa_pointer))
				klass.new(@session, item)
			else
				self
			end
		else
			error = create_error(:e_no_seq_to_activeagent, :substance, @model.substance)
			@errors.store(:substance, error)
			self
		end
	end
	def update
		keys = [:substance, :dose, :chemical_substance, :chemical_dose,
			:spagyric_dose, :equivalent_substance, :equivalent_dose]
		input = user_input(keys, [:substance])
		newstate = self
		unless (error?)
			substance = @session.substance(input[:substance]) 
			if(substance.nil?)
				selection = self.substance_selection
				model = ODDB::SelectSubstance.new(input, selection, @model)
				newstate = self.class::SELECT_STATE.new(@session, model)
			elsif(@model.substance != substance && \
				@model.sequence.active_agent(substance))
				error = create_error(:e_seq_dup_substance, :substance, input[:substance])
				@errors.store(:substance, error)
			else
				if(@model.is_a?(Persistence::CreateItem))
					@model.append(input[:substance])
				end
				chem = input[:chemical_substance]
				if(chemical = @session.substance(chem))
					input[:chemical_substance] = chemical.pointer
				elsif(chem.empty?)
					input[:chemical_substance] = nil
					input[:chemical_dose] = nil
				else
					error = create_error(:e_unknown_substance, 
						:chemical_substance, chem)
					@errors.store(:chemical_substance, error)
					input.delete(:chemical_substance)
					input.delete(:chemical_dose)
				end
				input[:substance] = substance.pointer
				ODBA.transaction { 
					@model = @session.app.update(@model.pointer, input, 
																			unique_email)
				}
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
end
class ActiveAgent < State::Admin::Global
	VIEW = View::Admin::RootActiveAgent
	SELECT_STATE = State::Admin::SelectSubstance
	include ActiveAgentMethods
end
class CompanyActiveAgent < State::Admin::ActiveAgent
	def init
		super
		unless(allowed?)
			@default_view = View::Admin::ActiveAgent
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
end
		end
	end
end
