#!/usr/bin/env ruby
# State::User::RegisterDownload -- oddb -- 22.12.2004 -- hwyss@ywesee.com

require 'state/user/global'
require 'view/user/register_download'

module ODDB
	module State
		module User
class RegisterDownload < State::User::Global
	RECIPIENTS = [
		'hwyss@ywesee.com',
	]
	MAIL_FROM = '"Zeno R.R. Davatz" <zdavatz@ywesee.com>'
	VIEW = View::User::RegisterDownload
	def ask_for_authentication(recipient, challenge)
		lookandfeel = @session.lookandfeel
		outgoing = TMail::Mail.new
		outgoing.set_content_type('text', 'plain', 'charset'=>'ISO-8859-1')
		outgoing.to = [recipient]
		outgoing.from = MAIL_FROM
		outgoing.subject = lookandfeel.lookup(:auth_mail_subject)
		data = {
			:email			=>	recipient,
			:challenge	=>	challenge.key,
			:filename		=>	@session.user_input(:filename),
		}
		url = lookandfeel._event_url(:authenticate, data)
		outgoing.body = lookandfeel.lookup(:auth_mail_body, recipient, url)
		outgoing.date = Time.now
		outgoing['User-Agent'] = 'ODDB Download'
		recipients = [recipient] + RECIPIENTS
		Net::SMTP.start(SMTP_SERVER) { |smtp|
			smtp.sendmail(outgoing.encoded, MAIL_FROM, recipients)
		}
	end
	def download
		email = @session.user_input(:email)
		if(email.nil? || email.is_a?(SBSM::InvalidDataError))
			error = create_error(:e_missing_email, :email, email)
			@errors.store(:email, error)
			self
		else
			@session.set_cookie_input(:email, email)
			pointer = Persistence::Pointer.new([:admin_subsystem], 
				[:download_user, email])
			user = pointer.creator.resolve(@session.app)
			if(user.authenticated?)
				State::User::Download.new(@session, nil)
			else
				challenge = user.create_challenge
				ask_for_authentication(email, challenge)
				State::User::AuthInfo.new(@session, user)
			end
		end
	end
end
		end
	end
end
