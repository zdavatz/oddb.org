#!/usr/bin/env ruby
# State::User::SuggestRegistration -- oddb -- 29.11.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/admin/registration'
require 'state/user/contributor'
require 'state/user/selectindication'
require 'view/user/suggest_registration'

module ODDB
	module State
		module User
class SuggestRegistration < Global
	include State::Admin::RegistrationMethods
	VIEW = View::User::SuggestRegistration
	RECIPIENTS = ['admin@ywesee.com']
	SELECT_STATE = State::User::SelectIndication
	def accept
		update
		keys = [:iksnr, :email_suggestion]
		input = user_input(keys, keys)
		unless(error?)
			@session[:allowed].delete(@model)
			send_notification(input[:email_suggestion])
			State::User::Confirm.new(@session, :suggestion_sent)
		end
	end
	def send_notification(email)
		from = email
		mail = TMail::Mail.new
		mail.set_content_type('text', 'plain', 'charset'=>'ISO-8859-1')
		mail.from = from 
		mail.subject = sprintf("%s %s", 
			@session.lookandfeel.lookup(:registration_subject),
			@model.name_base)
		mail.date = Time.now
		url = @session.lookandfeel._event_url(:resolve,
			{:pointer => @model.pointer})
		mail.body = [
			url,
		].join("\n")
		Net::SMTP.start(SMTP_SERVER) { |smtp|
			RECIPIENTS.each { |rec|
				mail.to = [rec]
				smtp.sendmail(mail.encoded, from, rec) 
			}
		}
	end
	def update
		iksnr = @session.user_input(:iksnr)
		if(@model.is_a?(Persistence::CreateItem) \
			&& (reg = @session.app.incomplete_registration_by_iksnr(iksnr)))
			@model = reg
			self
		else
			keys = [
				:iksnr, :inactive_date, :generic_type, :registration_date, 
				:revision_date, :market_date, :expiration_date, 
				:complementary_type, :export_flag, :email_suggestion, 
			]
			# check_input
			newstate = do_update(keys)
			mandatory = [:iksnr, :indication, :company_name]
			user_input(mandatory, mandatory)
			if(reg = @session.app.registration(@session.user_input(:iksnr)))
				filled = @model.fill_blanks(reg)
				@model.odba_store unless(filled.empty?)
				filled.each { |key| @errors.delete(key) }
				if(filled.include?(:company))
					@errors.delete(:company_name)
				end
			end
			newstate
		end
	end
end
		end
	end
end
