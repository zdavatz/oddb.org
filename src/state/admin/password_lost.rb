#!/usr/bin/env ruby
# State::Admin::PasswordLost -- oddb -- 17.02.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/admin/password_lost'
require 'rmail'

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
	def notify_user(email, token, time)
		lnf = @session.lookandfeel
		mail = RMail::Message.new
		header = mail.header
		recipient = header.to = email
		header.from = MAIL_FROM
		header.subject = lnf.lookup(:password_lost_subject)
		url = lnf._event_url(:password_reset, {:token => token, :email => recipient})
		mail.body = lnf.lookup(:password_lost_body, recipient, url, 
			time.strftime(lnf.lookup(:time_format_long)))
		smtp = Net::SMTP.new(SMTP_SERVER)
		recipients = [recipient] + MAIL_TO
		smtp.start {
			recipients.each { |recipient|
				smtp.sendmail(mail.to_s, SMTP_FROM, recipient)
			}
		}
		recipients
	end
end
		end
	end
end
