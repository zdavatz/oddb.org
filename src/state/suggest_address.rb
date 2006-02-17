#!/usr/bin/env ruby
# State::SuggestAddress -- oddb -- 04.08.2005 -- jlang@ywesee.com

require 'view/suggest_address'
require 'state/suggest_address_confirm'

module ODDB
	module State
		class SuggestAddress < State::Global
			VIEW = View::SuggestAddress
			RECIPIENTS = [ 'zdavatz@ywesee.com', 'hwyss@ywesee.com' ]
			def address_send
				if(sugg = save_suggestion)
					send_notification(sugg)
					AddressConfirm.new(@session, sugg)
				end
			end
			def save_suggestion
				pointer = Persistence::Pointer.new(:address_suggestion)
				mandatory = [:name, :email]
				keys = [:additional_lines, :address, :location,
					:fon, :fax, :title, :canton, :message, 
					:address_type, :email_suggestion] + mandatory
				input = user_input(keys, mandatory)
				input[:fax] = input[:fax].to_s.split(/\s*,\s*/)
				input[:fon] = input[:fon].to_s.split(/\s*,\s*/)
				lns = input[:additional_lines].to_s
				input.store(:additional_lines, 
					lns.split(/[\n\r]+/))
				input.store(:type, input.delete(:address_type))
				input.store(:address_pointer, @model.pointer)
				parent = @model.parent(@session)
				input.store(:fullname, parent.fullname)
				input.store(:time, Time.now)
				unless error?
					@session.set_cookie_input(:email, input[:email])
					@session.app.update(pointer.creator, input, unique_email)
				end
			end
			def send_notification(suggestion)
				from = suggestion.email_suggestion 
				mail = TMail::Mail.new
				mail.set_content_type('text', 'plain', 'charset'=>'ISO-8859-1')
				mail.from = from #'suggest_address@oddb.org'
				mail.subject = "#{@session.lookandfeel.lookup(:address_subject)} #{suggestion.fullname}"
				mail.date = Time.now
				url = @session.lookandfeel._event_url(:resolve,
					{:pointer => suggestion.pointer})
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
		end
	end
end
