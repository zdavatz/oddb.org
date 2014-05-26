#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Notify -- oddb.org -- 27.04.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Notify -- oddb.org -- 28.06.2007 -- hwyss@ywesee.com

require 'mail'
require 'util/mail'

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
  attr_reader :passed_turing_test
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
    unless @passed_turing_test
      mandatory.push :captcha
    end
		keys = mandatory + [:notify_message]
		input = user_input(keys, mandatory)
    if(@passed_turing_test)
      # do nothing
    elsif((candidates = input[:captcha]) && candidates.any? { |key, word|
      @session.lookandfeel.captcha.valid_answer? key, word })
      @passed_turing_test = true
    else
      @errors.store(:captcha, create_error('e_failed_turing_test',
        :captcha, nil))
    end
    if msg = input[:message]
      input[:message] = msg[0,500]
    end
    @model.name = input[:name]
    @model.notify_sender = input[:notify_sender]
    @model.notify_recipient = input[:notify_recipient]
    @model.notify_message = input[:notify_message]
    if(error?)
      return self
    end
    recipients = model.notify_recipient
		if(model.name && model.notify_sender && recipients.is_a?(Array) \
				&& !recipients.empty?)
      body = [
				breakline(@model.notify_message, 75),
				"\n",
				@session.lookandfeel._event_url(:show,
					{:pointer => CGI.escape(model.item.pointer.to_s)}),
			].join("\n")
			Util.send_mail(recipients,
											"#{@session.lookandfeel.lookup(:notify_subject)} #{@model.name}",
											body,
											nil, # don't override from
											{ 'text/html; charset=UTF-8' => ODDB::View::NotifyMail.new(@model, @session).to_html(@session.cgi) }
										)
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
