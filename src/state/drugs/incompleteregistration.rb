#!/usr/bin/env ruby
# State::Drugs::IncompleteReg -- oddb -- 19.06.2003 -- hwyss@ywesee.com 

require 'state/drugs/registration'
require 'state/drugs/incompleteregistrations'
require 'view/drugs/incompleteregistration'

module ODDB
	module State
		module Drugs
class IncompleteReg < State::Drugs::Registration
	SEQUENCE_STATE = State::Drugs::IncompleteSequence
	VIEW = View::Drugs::IncompleteRegistration
	def accept
		if(@model.acceptable? || @session.app.registration(@model.iksnr))
			mdl = @session.app.accept_incomplete_registration(@model)
			State::Drugs::Registration.new(@session, mdl)
		else
			#@errors.store(create_error(:e_incomplete))
			self
		end
	end
	def delete
		@session.app.delete(@model.pointer)
		State::Drugs::IncompleteRegs.new(@session, @session.app.incomplete_registrations)
	end
	def update
		result_state = self
		if(active = @session.app.registration(@model.iksnr))
			incomplete = @model
			@model = active
			result_state = super
			@model = incomplete
		end
		result_state
	end
	def update_incomplete
		keys = [:iksnr, :registration_date, :revision_date, :generic_type]
		do_update(keys)
	end
end
		end
	end
end
