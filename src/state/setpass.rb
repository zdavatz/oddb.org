#!/usr/bin/env ruby
# SetPassState -- oddb -- 22.07.2003 -- hwyss@ywesee.com 

require 'view/setpass'
require 'util/persistence'
require 'state/global_predefine'

module ODDB
	class SetPassState < GlobalState
		VIEW = SetPassView 
		def update
			keys = [:unique_email, :set_pass_1, :set_pass_2]
			input = user_input(keys, keys)
			pass1 = input[:set_pass_1]
			pass2 = input[:set_pass_2]
			email = input[:unique_email]
			unless(pass1 == pass2)
				err1 = create_error(:e_non_matching_set_pass, :set_pass_1, pass1)
				err2 = create_error(:e_non_matching_set_pass, :set_pass_2, pass2)
				@errors.store(:set_pass_1, err1)
				@errors.store(:set_pass_2, err2)
			end
			unless(error?)
				hash = {
					:unique_email	=>	email,
					:pass_hash		=>	pass1,
				}
				mdl = @model.model
				if(@model.is_a? Persistence::CreateItem)
					hash.store(:model, mdl.pointer)
				end
				begin
					@session.app.update(@model.pointer, hash)
					if(klass = resolve_state(mdl.pointer))
						klass.new(@session, mdl)
					end
				rescue RuntimeError => e
					err = create_error(e.message, :unique_email, email)
					@errors.store(:unique_email, err)
					self
				end
			end
		end
	end
end
