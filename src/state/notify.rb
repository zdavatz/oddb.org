#!/usr/bin/env ruby
# State::Notify -- oddb -- 19.10.2005 -- ffricker@ywesee.com

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
		txt.to_s.split(/(:?[\s-])/).each { |part|
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
    recipients = model.notify_recipient
		if(model.name && model.notify_sender && recipients.is_a?(Array) \
				&& !recipients.empty? && model.notify_message)
			mail = TMail::Mail.new
			mail.set_content_type('text', 'plain', 'charset'=>'ISO-8859-1')
			mail.to = recipients
			mail.from = @model.notify_sender
			mail.subject = "#{@session.lookandfeel.lookup(:notify_subject)} #{@model.name}"
			mail.date = Time.now
			mail.body = [
				@session.lookandfeel._event_url(:show, 
					{:pointer => CGI.escape(model.item.pointer.to_s)}),
				"\n",
				breakline(@model.notify_message, 75),
			].join("\n")
			Net::SMTP.start(SMTP_SERVER) { |smtp|
				smtp.sendmail(mail.encoded, SMTP_FROM, recipients) 
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
	def preview
		mandatory = [:name, :notify_sender, :notify_recipient]
		keys = mandatory + [:notify_message]
		input = user_input(keys, mandatory)
		unless(error?)
			@model.name = input[:name]
			@model.notify_sender = input[:notify_sender]
			@model.notify_recipient = input[:notify_recipient]
			@model.notify_message = input[:notify_message]
		end
		self
	end
end
	end
end
