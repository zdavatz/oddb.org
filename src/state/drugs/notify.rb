#!/usr/bin/env ruby
# Notify -- oddb -- 21.03.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'state/drugs/global'
require 'view/drugs/notify'
require 'state/drugs/notify_confirm'
require 'util/logfile'

module ODDB
	module State
		module Drugs
class Notify < State::Drugs::Global
	VIEW = View::Drugs::Notify
	class Notification
		attr_accessor :name, :notify_sender, :notify_recipient, :notify_message, :package
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
			@model.package = pointer.resolve(@session)
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
		mail = TMail::Mail.new
		mail.set_content_type('text', 'plain', 'charset'=>'ISO-8859-1')
		mail.to = @model.notify_recipient
		mail.from = @model.notify_sender
		mail.subject = "#{@session.lookandfeel.lookup(:notify_subject)} #{@model.name}"
		mail.date = Time.now
		mail.body = [
			@session.lookandfeel._event_url(:show, {:pointer => model.package.pointer}),
			"\n",
			breakline(@model.notify_message, 75),
		].join("\n")
		Net::SMTP.start(SMTP_SERVER) { |smtp|
			smtp.sendmail(mail.encoded, SMTP_FROM, @model.notify_recipient) 
		}
		NotifyConfirm.new(@session, @model)
	end
	def preview
		mandatory = [:name, :notify_sender, :notify_recipient]
		keys = mandatory + [:notify_message]
		input = user_input(keys, mandatory)
		@model.name = input[:name]
		@model.notify_sender = input[:notify_sender]
		@model.notify_recipient = input[:notify_recipient]
		@model.notify_message = input[:notify_message]
		self
	end
end
		end
	end
end
