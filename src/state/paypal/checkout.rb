#!/usr/bin/env ruby
# State::PayPal::Checkout -- ODDB -- 28.04.2005 -- hwyss@ywesee.com

require 'state/paypal/redirect'
require 'state/admin/login'
require 'view/ajax/json'
require 'model/invoice'

module ODDB
	module State
		module PayPal
class AjaxCheckout < Global
  VOLATILE = true
  VIEW = View::Ajax::Json
end
module Checkout
  include State::Admin::LoginMethods
	CURRENCY = 'EUR'
  def ajax_autofill
    email = @session.user_input(:email)
    prefs = {:email => email}
    keys = checkout_keys()
    keys.delete(:email)
    begin
      prefs.update @session.yus_get_preferences(email, keys)
    rescue Yus::YusError
      prefs = {} # return an empty hash
    end
    AjaxCheckout.new(@session, prefs)
  end
	def checkout
		## its possible that we know this user already -> log them in.
    missing_keys = [:email, :pass] - @session.input_keys
    if(@session.logged_in?)
      @user = @session.user
    elsif(missing_keys.empty?)
      begin
        @user ||= @session.login
        reconsider_permissions(@user, self)
        @session.force_login(@user)
      rescue Yus::UnknownEntityError 
        # ignore: in this case we simply create a new user in 'create_user'
      rescue Yus::AuthenticationError
        @errors.store(:pass, create_error(:e_authentication_error, :pass, nil))
      end
    end
		input = user_input(checkout_keys(), checkout_mandatory())
		if(error?)
			self
		else
			ODBA.transaction { 
				create_user(input)
				State::PayPal::Redirect.new(@session, create_invoice(input))
			}
		end
	rescue SBSM::ProcessingError => err
		@errors.store(err.key, err)
		self
	end
	def checkout_mandatory
		keys = [ :salutation, :name_last, :name_first, ]
    unless(@session.logged_in?)
      keys.push(:email, :pass, :set_pass_2 )
    end
    keys
	end
	def checkout_keys
		checkout_mandatory()
	end
	def create_invoice(input)
		pointer = Persistence::Pointer.new([:invoice])
    args = {
      :currency => currency,
      :yus_name => input[:email] || @user.email,
    }
		invoice = @session.app.update(pointer.creator, args, unique_email)
		@model.items.each { |abstract|
			item_ptr = invoice.pointer + [:item]
			time = Time.now
			file = abstract.text
			duration = abstract.duration
			expiry = InvoiceItem.expiry_time(duration, time)
			data = {
				:duration			=> duration,
				:expiry_time	=> expiry,
				:price				=> abstract.price,
				:quantity			=> abstract.quantity,
				:text					=> file,
				:time					=> time,
				:type					=> abstract.type,
				:data					=> abstract.data,
				:vat_rate			=> VAT_RATE,
			}
			item = @session.app.update(item_ptr.creator, data, unique_email)
		}
		invoice
	end
	def create_user(input)
		hash = input.dup 
    ## don't store passwords in cookie vars...
		hash.delete(:set_pass_2)
		pass = hash.delete(:pass)
    ## but store the rest of the input there
		hash.each { |key, val| @session.set_cookie_input(key, val) }
    email = hash.delete(:email)
		unless(@user.is_a?(YusUser))
      @user = @session.app.yus_create_user(email, pass)
		end
    hash.delete_if { |key, value| value.to_s.empty? }
		@user.set_preferences(hash) unless(hash.empty?)
    reconsider_permissions(@user, self)
		@session.force_login(@user)
	rescue Yus::DuplicateNameError => e
		raise create_error(:e_duplicate_email, :email, input[:email])
	rescue RuntimeError, Yus::YusError => e
		raise create_error(e.message, :email, input[:email])
	end
	def currency
		self.class.const_get(:CURRENCY)
	end
	def user_input(keys, mandatory)
		input = super
		pass1 = input[:pass]
		pass2 = input[:set_pass_2]
    unless(@user || pass1 == pass2)
			err1 = create_error(:e_non_matching_set_pass, :pass, pass1)
			err2 = create_error(:e_non_matching_set_pass, :set_pass_2, pass2)
			@errors.store(:pass, err1)
			@errors.store(:set_pass_2, err2)
		end
		msg = 'e_need_all_input'
		@errors.each { |key, err|
			if(err.message.match(/^e_missing_/))
				@errors.store(key, create_error(msg, key, err.value))
			end
		}
		input
	end
end
		end
	end
end
