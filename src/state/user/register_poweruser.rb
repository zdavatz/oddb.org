#!/usr/bin/env ruby
# State::User::RegisterPowerUser -- oddb -- 29.07.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/paypal/checkout'
require 'view/user/register_poweruser'

module ODDB
	module State
		module User
class RenewPowerUser < Global
	include State::PayPal::Checkout
	VIEW = View::User::RenewPowerUser
	def checkout_mandatory
		[:pointer]
	end
	def create_user(input)
		input[:pointer].resolve(@session)
	end
end
class RegisterPowerUser < Global
	include State::PayPal::Checkout
	VIEW = View::User::RegisterPowerUser
	def checkout_mandatory
		[ :salutation, :name, :name_first, :email, :pass, :set_pass_2 ]
	end
	def checkout
		## its possible that we know this user already -> log them in.
		@user ||= @session.login
		if(!@user.nil? && @user.valid?)
			@session.desired_state 
		else
			super
		end
	end
	def create_user(input)
		hash = input.dup 
		hash.delete(:set_pass_2)
		hash.store(:pass_hash, hash.delete(:pass))
		hash.store(:unique_email, hash.delete(:email))
		pointer = if(@user.respond_to?(:pointer))
			@user.pointer
		else
			Persistence::Pointer.new(:poweruser).creator
		end
		@user = @session.app.update(pointer, hash)
		@session.force_login(@user)
		@user
	rescue RuntimeError => e
		raise create_error(e.message, :email, input[:email])
	end
	def user_input(keys, mandatory)
		input = super
		pass1 = input[:pass]
		pass2 = input[:set_pass_2]
		unless(pass1 == pass2)
			err1 = create_error(:e_non_matching_set_pass, :pass, pass1)
			err2 = create_error(:e_non_matching_set_pass, :set_pass_2, pass2)
			@errors.store(:pass, err1)
			@errors.store(:set_pass_2, err2)
		end
		input
	end
end
		end
	end
end
