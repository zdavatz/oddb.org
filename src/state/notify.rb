#!/usr/bin/env ruby
# State::Notify -- oddb -- 28.06.2007 -- hwyss@ywesee.com

require 'rmail'

module ODDB
	module State
module Notify
	class Notification
		attr_accessor :name, :notify_sender, :notify_recipient, :notify_message, 
			:item
		def empty?
			[
				@name,
				@notify_sender, 
				@notify_recipient,
				@notify_message,
			].join.empty?
		end
	end
	def init
		@model = Notification.new
		if(pointer = @session.user_input(:pointer))
			@model.item = pointer.resolve(@session)
		end
	end
	def breakline(txt, length)
		name = ''
		line = ''
		txt.to_s.split(/(:?[\s-])/u).each { |part|
			if((line.length + part.length) > length)
				name << line << "\n"
				line = part
			else
				line << part
			end
		}
		name << line
	end
	def notify_send 
 		mandatory = [:name, :notify_sender, :notify_recipient]
		keys = mandatory + [:notify_message]
		input = user_input(keys, mandatory)
		if(error?)
      puts @errors.inspect
      return self
		end
    @model.name = input[:name]
    @model.notify_sender = input[:notify_sender]
    @model.notify_recipient = input[:notify_recipient]
    @model.notify_message = input[:notify_message]
    recipients = model.notify_recipient
		if(model.name && model.notify_sender && recipients.is_a?(Array) \
				&& !recipients.empty?)
			mail = RMail::Message.new
      header = mail.header
      header.add('Content-Type', 'multipart/alternative')
      header.add('Date', Time.now.rfc822)
      from = header.from = 'zdavatz@ywesee.com'
      to = header.to = recipients
			header.subject = "#{@session.lookandfeel.lookup(:notify_subject)} #{@model.name}"
      header.add('Reply-To', @model.notify_sender)
      header.add('Mime-Version', '1.0')

      text = RMail::Message.new
      header = text.header
      header.add('Content-Type', 'text/plain', nil, 'charset' => 'UTF-8')
      text.body = [
				breakline(@model.notify_message, 75),
				"\n",
				@session.lookandfeel._event_url(:show, 
					{:pointer => CGI.escape(model.item.pointer.to_s)}),
			].join("\n")
      mail.add_part text

      htmlpart = RMail::Message.new
      header = htmlpart.header
      header.add('Content-Type', 'text/html', nil, 'charset' => 'UTF-8')
      header.add('Content-Transfer-Encoding', 'quoted-printable')
      html = View::NotifyMail.new(@model, @session).to_html(@session.cgi)
      htmlpart.body = [html].pack('M')
      mail.add_part htmlpart

			Net::SMTP.start(SMTP_SERVER) { |smtp|
				smtp.sendmail(mail.to_s, SMTP_FROM, recipients) 
			}
			logger = @session.notification_logger
			key = [
				self.class.const_get(:ITEM_TYPE),
				@model.item.send(self.class.const_get(:CODE_KEY)),
			]
			logger.log(key, 
				@model.notify_sender, @model.notify_recipient, Time.now)
			logger.odba_store
			klass = self.class.const_get(:CONFIRM_STATE)
			klass.new(@session, @model)
		end
	end
end
	end
end
