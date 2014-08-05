#!/usr/bin/env ruby
# encoding: utf-8
# Small helper class to unify sending mails
require 'mail'
require 'config'
require 'util/logfile'
require 'yaml'

module ODDB
  module Util
    # see also the file test/data/oddb_mailing_test.yml
    MailingTestConfiguration     = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test', 'data', 'oddb_mailing_test.yml'))
    MailingDefaultConfiguration  = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'etc', 'oddb.yml'))
    MailingListIds               = 'mailing_list_ids'
    MailingRecipients            = 'mail_recipients'
    @mail_configured             = false
    @mailing_list_configuration  = MailingTestConfiguration

    def Util.use_mailing_list_configuration(path)
      @mailing_list_configuration = path
    end

    def Util.mailing_configuration_file
      @mailing_list_configuration
    end

    def Util.mail_from
      Util.configure_mail unless @mail_configured
      @cfg['mail_from']
    end

    def Util.mail_to
      Util.configure_mail unless @mail_configured
      @cfg['mail_to']
    end

    def Util.get_mailing_list_receivers(list_id)
      Util.configure_mail unless @mail_configured
      return [] unless @cfg and @cfg[MailingListIds] and @cfg[MailingListIds].index(list_id)
      receivers = []
      @cfg[MailingRecipients].each { |recipient| receivers << recipient[:email] if recipient[:lists] and recipient[:lists].index(list_id) }
      receivers.sort
    end
    def Util.get_mailing_list_anrede(list_id)
      Util.configure_mail unless @mail_configured
      return [] unless @cfg and @cfg[MailingListIds]    
      anreden = []
      lists = list_id.is_a?(Array) ? list_id : [list_id]
      lists.each{ |list_name|
        @cfg[MailingRecipients].each { |recipient| anreden << recipient[:anrede] if recipient[:lists].index(list_name) and recipient[:anrede]}
      }
      anreden.sort
    end

    # one time initialisation for delivering according to setup in etc/oddb.yml
    # can be overriden by calling Util.configure_mail(:test)
    # return default_from address
    def Util.configure_mail(deliver_using = :oddb_yml)
      return if @mail_configured == deliver_using
      @mail_configured = deliver_using
      if deliver_using == :test
        @mailing_list_configuration = MailingTestConfiguration
        @cfg = YAML.load_file(@mailing_list_configuration)
        Mail.defaults do delivery_method :test end
      else
        @mailing_list_configuration = MailingDefaultConfiguration
        unless File.exists?(@mailing_list_configuration)
          @cfg = nil
        else
          @cfg = YAML.load_file(@mailing_list_configuration)
          cfg = @cfg.clone
          Mail.defaults do
            delivery_method :smtp, {
              :address => cfg['smtp_server'],
              :port => cfg['smtp_port'],
              :domain => cfg['smtp_domain'],
              :user_name => cfg['smtp_user'],
              :password => cfg['smtp_pass'],
              :authentication => cfg['smtp_auth']
            }
          end
        end
      end
      msg = "#{__FILE__}: Configured email using #{@mailing_list_configuration} @cfg is now #{@cfg ? @cfg['smtp_server'].inspect : 'nil' } #{@cfg ? @cfg['smtp_port'].inspect : ''} #{@cfg ? @cfg['smtp_user'].inspect : ''}"
      Util.debug_msg(msg)
      @mail_configured
    end

    # Parts must be of form content_type => body, e.g. 'text/html; charset=UTF-8' => '<h1>This is HTML</h1>'
    def Util.send_mail(list_and_recipients, mail_subject, mail_body, override_from = nil, parts = {})
      LogFile.append('oddb/debug', "Util.send_mail list_and_recipients #{list_and_recipients}", Time.now)
      recipients = Util.check_and_get_all_recipients(list_and_recipients)
      mail = Mail.new
      mail.from    override_from ? override_from : Util.mail_from
      mail.to      recipients
      mail.subject mail_subject
      mail.body    mail_body
      log_and_deliver_mail(mail)
    rescue => e
      msg = "Util.send_mail rescue: error is #{e.inspect} recipients #{recipients.inspect} #{caller[0..10].inspect}"
      Util.debug_msg(msg)
      raise e
    end

    def Util.send_mail_with_attachments(list_and_recipients, subject, body, attachments, override_from = nil)
      LogFile.append('oddb/debug', "Util.send_mail send_mail_with_attachments #{list_and_recipients}", Time.now)
      recipients = Util.check_and_get_all_recipients(list_and_recipients)
      mail = Mail.new
      mail.from    override_from ? override_from : Util.mail_from
      mail.to      recipients
      mail.subject = subject
      mail.body = body
      attachments.each { |attachment|
        mail.attachments[attachment[:filename]] = {
                                                  :mime_type => attachment[:mime_type],
                                                  :content   => attachment[:content],
                                                }
      }
      log_and_deliver_mail(mail)
    rescue => e
      msg = "Util.send_mail_with_attachments rescue: error is #{e.inspect} #{caller[0..10].inspect}"
      Util.debug_msg(msg)
      raise e
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
    def Util.check_and_get_all_recipients(list_and_recipients)
      Util.configure_mail unless @mail_configured
      recipients = []
      if list_and_recipients and list_and_recipients.is_a?(Array)
        foundList = false
        list_and_recipients.each{
          |id|
            recvs = Util.get_mailing_list_receivers(id)
            if recvs.size > 0
              foundList = true
              recipients += recvs
            else
              recipients << id
            end
        }
      else
        recipients = Util.get_mailing_list_receivers(list_and_recipients)
        foundList = recipients.size > 0
      end
      raise "At least one recipient must be a list #{list_and_recipients.inspect}" unless foundList
      raise "No recipients defined for list_and_recipients #{list_and_recipients}" unless recipients.size > 0
      recipients.sort
    end
    
    def Util.log_and_deliver_mail(mail)
      Util.configure_mail unless @mail_configured
      mail.from << @cfg.mail_from unless mail.from.size > 0
      mail.reply_to = @cfg['reply_to']
      Util.debug_msg("Util.log_and_deliver_mail to=#{mail.to} subject #{mail.subject} size #{mail.body.inspect}")
      mail.deliver
    end

    def Util.debug_msg(msg)
      LogFile.append('oddb/debug', ' ' + msg, Time.now)
      system("logger '#{msg.gsub(/['\n]/, '"')}'")
      $stderr.puts msg unless defined?(MiniTest)
    end
  end
end