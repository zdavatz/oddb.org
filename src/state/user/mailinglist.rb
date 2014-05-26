#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::User::MailingList -- oddb.org -- 23.12.2011 -- mhatakeyama@ywesee.com
# ODDB::State::User::MailingList -- oddb.org -- 30.09.2003 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/user/mailinglist'
require 'util/mail'

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
		Util.send_mail(recipient, "Unknown subject for MailingList?", info_message, subscriber)
	end
end
		end
	end
end
