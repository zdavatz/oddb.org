#!/usr/bin/env ruby
# State::User::Download -- ODDB -- 29.10.2003 -- hwyss@ywesee.com

require 'state/user/global'
require 'view/user/download'
require 'view/user/register_download'

module ODDB
	module State
		module User
class Download < State::User::Global
	VOLATILE = true
	RECIPIENTS = [
		'hwyss@ywesee.com',
	]
	MAIL_FROM = 'zdavatz@ywesee.com'
	def init
		check_or_set_cookie
		super
	end
	def ask_for_feedback(recipient)
		outgoing = TMail::Mail.new
		outgoing.set_content_type('text', 'plain', 'charset'=>'ISO-8859-1')
		outgoing.to = [recipient]
		outgoing.subject = @session.lookandfeel.lookup(:download_mail_subject)
		outgoing.body = @session.lookandfeel.lookup(:download_mail_body, 
			recipient)
		outgoing.date = Time.now
		#outgoing.bcc = RECIPIENTS
		outgoing['User-Agent'] = 'ODDB Download'
		recipients = [recipient] + RECIPIENTS
		Net::SMTP.start(SMTP_SERVER) { |smtp|
			smtp.sendmail(outgoing.encoded, MAIL_FROM, recipients)
		}
	end
	def check_or_set_cookie
		if((email = @session.get_cookie_input(:email)) && !email.empty?)
			@default_view = View::User::Download
		elsif((email = @session.user_input(:email)) && !email.empty?)
			@session.set_cookie_input(:email, email)
			@default_view = View::User::Download
			ask_for_feedback(email)
		else
			@default_view = View::User::RegisterDownload
		end
	end
	def download
		check_or_set_cookie
	end
end
		end
	end
end
