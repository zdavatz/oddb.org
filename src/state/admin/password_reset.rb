#!/usr/bin/env ruby
# State::Admin::PasswordReset -- oddb -- 20.02.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/admin/login'
require 'view/admin/password_reset'

module ODDB
	module State
		module Admin 
class PasswordReset < Global
	VIEW = View::Admin::PasswordReset
	include LoginMethods
	def password_reset
		keys = [:set_pass_1, :set_pass_2]
		input = user_input(keys, keys)
		pass1 = input[:set_pass_1]
		pass2 = input[:set_pass_2]
		unless(error? || pass1 == pass2)
			err1 = create_error(:e_non_matching_set_pass, :set_pass_1, pass1)
			err2 = create_error(:e_non_matching_set_pass, :set_pass_2, pass2)
			@errors.store(:set_pass_1, err1)
			@errors.store(:set_pass_2, err2)
		end
		unless(error?)
			hash = {
				:pass_hash		=>	pass1,
				:reset_token	=>	nil,
				:reset_until	=>	Time.now,
			}
			ODBA.transaction { 
				@session.app.update(@model.pointer, hash, @model.unique_email)
			}
			@session.force_login(@model)
			autologin(@model, Confirm.new(@session, :password_reset_confirm))
		end
	end
end
		end
	end
end
