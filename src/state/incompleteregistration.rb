#!/usr/bin/env ruby
# IncompleteRegState -- oddb -- 19.06.2003 -- hwyss@ywesee.com 

require 'state/registration'
require 'state/incompleteregistrations'
require 'view/incompleteregistration'

module ODDB
	class IncompleteRegState < RegistrationState
		SEQUENCE_STATE = IncompleteSequenceState
		VIEW = IncompleteRegistrationView
		def accept
			if(@model.acceptable? || @session.app.registration(@model.iksnr))
				mdl = @session.app.accept_incomplete_registration(@model)
				RegistrationState.new(@session, mdl)
			else
				#@errors.store(create_error(:e_incomplete))
				self
			end
		end
		def delete
			@session.app.delete(@model.pointer)
			IncompleteRegsState.new(@session, @session.app.incomplete_registrations)
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
