#!/usr/bin/env ruby
# State::Admin::IncompleteReg -- oddb -- 19.06.2003 -- hwyss@ywesee.com 

require 'state/admin/registration'
require 'state/admin/incompleteregistrations'
require 'state/admin/incompletesequence'
require 'view/admin/incompleteregistration'

module ODDB
	module State
		module Admin
class IncompleteReg < State::Admin::Registration
	SEQUENCE_STATE = State::Admin::IncompleteSequence
	VIEW = View::Admin::IncompleteRegistration
	def accept
		update_incomplete()
		if(@model.acceptable? || @session.app.registration(@model.iksnr))
			mdl = @session.app.accept_incomplete_registration(@model)
			State::Admin::Registration.new(@session, mdl)
		else
			#@errors.store(create_error(:e_incomplete))
			self
		end
	end
	def delete
		ODBA.batch {
			@session.app.delete(@model.pointer)
		}
		State::Admin::IncompleteRegs.new(@session, @session.app.incomplete_registrations)
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
