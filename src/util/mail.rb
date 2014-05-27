#!/usr/bin/env ruby
# encoding: utf-8
# Small helper class to unify sending mails
require 'mail'
require 'config'
require 'util/logfile'

module ODDB
  module Util
    EmailTestAddressFrom =  'test_ywesee@ywesee.com'
    @mail_configured = false
    @mail_from       = EmailTestAddressFrom

    # one time initialisation for delivering according to setup in etc/oddb.yml
    # can be overriden by calling Util.configure_mail(:test)
    # return default_from address
    def Util.configure_mail(deliver_using = :oddb_yml)
      if @mail_configured == deliver_using
        @mail_from = @mail_configured == :test ? EmailTestAddressFrom : config.mail_from
      end
      @mail_configured = deliver_using
      if deliver_using == :test
        Mail.defaults do	delivery_method :test end
        @mail_from = EmailTestAddressFrom
      else
        config = ODDB.config
        @mail_from = config.mail_from
        Mail.defaults do
          delivery_method :smtp, {
            :address => config.smtp_server,
            :port => config.smtp_port,
            :domain => config.smtp_domain,
            :user_name => config.smtp_user,
            :password => config.smtp_pass,
            :authentication => defined?(config.smtp_auth) ? config.smtp_auth : nil,
          }
        end
        system("logger '#{__FILE__}: Configured email using #{config.class}'")
      end
      @mail_configured
    end

    # Parts must be of form content_type => body, e.g. 'text/html; charset=UTF-8' => '<h1>This is HTML</h1>'
    def Util.send_mail(recipients, mail_subject, mail_body, override_from = nil, parts = {})
      Util.configure_mail unless @mail_configured
      recipients = [recipients] unless recipients.class == Array
      recipients.delete_if{ |x| x == nil }
      recipients = [ EmailTestAddressFrom ] unless recipients and recipients.size > 0
      mail = Mail.new
      mail.from    override_from ? override_from : @mail_from
      mail.to      recipients
      mail.subject mail_subject
      mail.body    mail_body
      log_and_deliver_mail(mail)
    end

    def Util.send_mail_with_attachments(subject, body, attachments)
      mail = Mail.new
      mail.from = @mail_from
      mail.subject = subject
      mail.body = body
      attachments.each { |attachment|
        mail.attachments[attachment[:filename]] = {
                                                  :mime_type => attachment[:mime_type],
                                                  :content   => attachment[:content],
                                                }
      }
      log_and_deliver_mail(mail)
    end

    # Utility methods for checking mails in  unit-tests
    def Util.sent_mails
      Mail::TestMailer.deliveries
    end

    # Utility methods for clearing mails in  unit-tests
    def Util.clear_sent_mails
      Mail::TestMailer.deliveries.clear
    end
  private
    def Util.log_and_deliver_mail(mail)
      Util.configure_mail unless @mail_configured
      mail.from << @mail_from unless mail.from.size > 0
      mail.to   ||= ODDB.config.mail_to
      LogFile.append('oddb/debug', " mail to=#{mail.to} subject #{mail.subject} size #{mail.body.inspect}")
      res = mail.deliver
      msg = "#{__FILE__}: send_mail to #{mail.to} #{mail.subject} res #{res.inspect}"
      LogFile.append('oddb/debug', msg)
      system("logger '#{msg}'")
      res
    end
  end
end