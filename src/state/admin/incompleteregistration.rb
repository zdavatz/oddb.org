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
		flags = @session.user_input(:change_flags)
		if(@model.acceptable? || @session.app.registration(@model.iksnr))
			if(flags.nil? || flags.empty?)
				@errors.store(:change_flags, 
					create_error(:e_missing_change_flags, :change_flags, flags))
				self
			else
				reg = @session.app.accept_incomplete_registration(@model)
				log = @session.app.log_group(:swissmedic_journal).latest
				change_flags = flags.collect { |key, val|
					OuwerkerkPlugin::NUMERIC_FLAGS.index(key.to_i)
				}
				log.change_flags[reg.pointer] ||= []
				log.change_flags[reg.pointer] += change_flags
				log.change_flags[reg.pointer].uniq!
				log.odba_store
				State::Admin::Registration.new(@session, reg)
			end
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
