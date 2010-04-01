#!/usr/bin/env ruby
# State::User::MailingList -- oddb -- 30.09.2003 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/user/mailinglist'
require 'tmail'
require 'util/smtp_tls'

module ODDB
	module State
		module User
class MailingList < State::User::Global
	VIEW = View::User::MailingList
	DIRECT_EVENT = :mailinglist
	def update
		if(@session.user_input(:subscribe))
			recipient = 'news-subscribe@generika.cc'
			info_message = :i_subscriber_mail_sent
		elsif(@session.user_input(:unsubscribe))
			recipient = 'news-unsubscribe@generika.cc'
			info_message = :i_unsubscriber_mail_sent
		end
		email = @session.user_input(:email)
		unless(email.is_a?(SBSM::InvalidDataError))
			send_email(email, recipient, info_message)
		else
			@errors.store(:mailinglist_email, create_error(email.message, :mailinglist_email, email.value))
		end
		self 
	end
	def send_email(subscriber, recipient, info_message)
		mail = TMail::Mail.new
		mail.from = subscriber 
		mail.to = recipient
		mail.date = Time.now
		begin
      config = ODDB.config
		  Net::SMTP.start(config.smtp_server, config.smtp_port, config.smtp_domain,
                      config.smtp_user, config.smtp_pass,
                      config.smtp_authtype) { |smtp|
				smtp.sendmail(mail.encoded, subscriber, recipient)
			}
			@infos.push(info_message)
		rescue
			@errors.store(:mailinglist_email, create_error('e_subscriber_mail_notsent', :mailinglist_email, subscriber))
		end
	end
end
		end
	end
end
