#!/usr/bin/env ruby
# SequenceState -- oddb -- 11.03.2003 -- hwyss@ywesee.com 

require 'state/global'
require 'view/sequence'
require 'model/sequence'
require 'state/package'
require 'state/activeagent'
require 'state/assign_deprived_sequence.rb'

module ODDB
	class SequenceState < GlobalState
		VIEW = RootSequenceView
		def assign_patinfo
			AssignDeprivedSequenceState.new(@session, @model)
		end
		def delete
			registration = @model.parent(@session.app) 
			@session.app.delete(@model.pointer)
			RegistrationState.new(@session, registration)
		end
		def new_active_agent
			pointer = @session.user_input(:pointer)
			model = pointer.resolve(@session.app)
			aa_pointer = pointer + [:active_agent]
			item = Persistence::CreateItem.new(aa_pointer)
			item.carry(:iksnr, model.iksnr)
			item.carry(:name_base, model.name_base)
			item.carry(:sequence, model)
			if (klass=resolve_state(aa_pointer))
				klass.new(@session, item)
			else
				self
			end
		end
		def new_package
			pointer = @session.user_input(:pointer)
			model = pointer.resolve(@session.app)
			p_pointer = pointer + [:package]
			item = Persistence::CreateItem.new(p_pointer)
			item.carry(:iksnr, model.iksnr)
			item.carry(:name_base, model.name_base)
			item.carry(:sequence, model)
			if (klass=resolve_state(p_pointer))
				klass.new(@session, item)
			else
				self
			end
		end
		def update
			if(@model.is_a? Persistence::CreateItem)
				seqnr = @session.user_input(:seqnr)
				error =	if(seqnr.is_a? RuntimeError)
					seqnr
				elsif(seqnr.empty?)
					create_error(:e_missing_seqnr, :seqnr, seqnr)
				elsif(@model.parent(@session.app).sequence(seqnr))
					create_error(:e_duplicate_seqnr, :seqnr, seqnr)
				end
				if error
					@errors.store(:seqnr, error)
					return self
				end
				@model.append(seqnr)
			end
			input = [
				:dose,
				:name_base, 
				:name_descr,
			].inject({}) { |inj, key|
				value = @session.user_input(key)
				if(value.is_a? RuntimeError)
					@errors.store(key, value)
				else
					inj.store(key, value)
				end
				inj
			}
			galform = @session.user_input(:galenic_form)
			if(@session.app.galenic_form(galform))
				input.store(:galenic_form, galform)
			else
				@errors.store(:galenic_form, create_error(:e_unknown_galenic_form, :galenic_form, galform))
			end
			atc_code = @session.user_input(:code)
			if(atc_code.is_a?(RuntimeError))
				@errors.store(atc_code.key, atc_code)
			elsif((descr = @session.user_input(:atc_descr)) \
				&& !descr.empty?)
				pointer = Persistence::Pointer.new([:atc_class, atc_code])
				values = {
					@session.language	=> descr,	
				}
				@session.app.update(pointer.creator, values)
				input.store(:atc_class, atc_code)
			elsif(@session.app.atc_class(atc_code))
				input.store(:atc_class, atc_code)
			else
				@errors.store(:atc_class, create_error(:e_unknown_atc_class, :code, atc_code))
			end
			@model = @session.app.update(@model.pointer, input)
			self
		end
	end
	class CompanySequenceState < SequenceState
		def init
			super
			unless(allowed?)
				@default_view = SequenceView 
			end
		end
		def delete
			if(allowed?)
				super
			end
		end
		def new_active_agent
			if(allowed?)
				super
			end
		end
		def new_package
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
			@session.user_equiv?(@model.company)
		end
	end
end
