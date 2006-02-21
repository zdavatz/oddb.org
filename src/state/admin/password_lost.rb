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
		unless(error?)
			if((email = input[:email]) && (user = @session.user_by_email(email)))
				token = Digest::MD5.hexdigest(rand.to_s)
				time = Time.now + 48 * 60 * 60
				args = {
					:reset_token => Digest::MD5.hexdigest(token),
					:reset_until => time,
				}
				@session.app.update(user.pointer, args, :unknown)
				notify_user(user, token)
				Confirm.new(@session, :password_request_confirm)
			else
				@errors.store(:email, create_error('e_unknown_user', :email, email))
				self
			end
		end
	end
	def notify_user(user, token)
		lnf = @session.lookandfeel
		mail = RMail::Message.new
		header = mail.header
		recipient = header.to = user.unique_email
		header.from = MAIL_FROM
		header.subject = lnf.lookup(:password_lost_subject)
		url = lnf._event_url(:password_reset, {:token => token, :email => recipient})
		mail.body = lnf.lookup(:password_lost_body, recipient, url, 
			user.reset_until.strftime(lnf.lookup(:time_format_long)))
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
