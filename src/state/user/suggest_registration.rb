#!/usr/bin/env ruby
# State::User::SuggestRegistration -- oddb -- 29.11.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/admin/registration'
require 'state/user/contributor'
require 'view/user/suggest_registration'

module ODDB
	module State
		module User
class SuggestRegistration < Global
	include State::Admin::RegistrationMethods
	VIEW = View::User::SuggestRegistration
	RECIPIENTS = ['hwyss@ywesee.com']
	def accept
		keys = [:iksnr, :email]
		input = user_input(keys, keys)
		unless(error?)
			@session[:allowed].delete(@model)
			send_notification(input[:email])
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
		keys = [:iksnr, :registration_date, :revision_date, :generic_type]
		do_update(keys, [:iksnr])
		(@session[:allowed] ||= []).push(@model).uniq!
		self.extend(State::User::Contributor)
		self
	end
end
		end
	end
end
