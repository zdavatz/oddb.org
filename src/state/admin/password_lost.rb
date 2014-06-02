#!/usr/bin/env ruby
# encoding: utf-8
# State::Admin::PasswordLost -- oddb -- 17.02.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/admin/password_lost'
require 'util/mail'

module ODDB
	module State
		module Admin
class PasswordLost < State::Global
	VIEW = View::Admin::PasswordLost
	def password_request
		input = user_input(:email, :email)
    email = input[:email]
    unless(error?)
      token = Digest::MD5.hexdigest(rand.to_s)
      #hashed = Digest::MD5.hexdigest(token)
      time = Time.now + 48 * 60 * 60
      @session.yus_grant(email, 'reset_password', token, time)
      notify_user(email, token, time)
      Confirm.new(@session, :password_request_confirm)
    end
  rescue Yus::UnknownEntityError
    @errors.store(:email, create_error('e_unknown_user', :email, email))
		self
	end
	def notify_user(recipient, token, time)
		lnf = @session.lookandfeel
		url = lnf._event_url(:password_reset, {:token => token, :email => recipient})
		recipients = [recipient, 'password_lost']
		Util.send_mail(recipients,
									 lnf.lookup(:password_lost_subject),
		               lnf.lookup(:password_lost_body, recipient, url,
		                          time.strftime(lnf.lookup(:time_format_long)))
		              )
		recipients
	end
end
		end
	end
end
