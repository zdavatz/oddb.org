#!/usr/bin/env ruby

# Small helper class to unify sending mails
require "mail"
require "config"
require "util/logfile"
require "yaml"
$: << File.expand_path("../../src", File.dirname(__FILE__))
require "util/workdir"

module ODDB
  module Util
    # see also the file test/data/oddb_mailing_test.yml
    MailingTestConfiguration = File.join(PROJECT_ROOT, "test", "data", "oddb_mailing_test.yml")
    MailingDefaultConfiguration = File.join(PROJECT_ROOT, "etc", "oddb.yml")
    MailingListIds = "mailing_list_ids"
    MailingRecipients = "mail_recipients"
    @mail_configured = false
    @mailing_list_configuration = MailingTestConfiguration

    def self.use_mailing_list_configuration(path)
      @mailing_list_configuration = path
    end

    def self.mailing_configuration_file
      @mailing_list_configuration
    end

    def self.mail_from
      Util.configure_mail unless @mail_configured
      @cfg["mail_from"]
    end

    def self.mail_to
      Util.configure_mail unless @mail_configured
      @cfg["mail_to"]
    end

    def self.get_mailing_list_receivers(list_id)
      Util.configure_mail unless @mail_configured
      return [] unless @cfg and @cfg[MailingListIds] and @cfg[MailingListIds].index(list_id)
      receivers = []
      @cfg[MailingRecipients].each { |recipient| receivers << recipient[:email] if recipient[:lists] and recipient[:lists].index(list_id) }
      receivers.sort
    end

    def self.get_mailing_list_anrede(list_id)
      Util.configure_mail unless @mail_configured
      return [] unless @cfg and @cfg[MailingListIds]
      anreden = []
      lists = list_id.is_a?(Array) ? list_id : [list_id]
      lists.each { |list_name|
        @cfg[MailingRecipients].each { |recipient| anreden << recipient[:anrede] if recipient[:lists] and recipient[:lists].index(list_name) and recipient[:anrede] }
      }
      anreden.sort
    end

    # one time initialisation for delivering according to setup in etc/oddb.yml
    # can be overriden by calling Util.configure_mail(:test)
    # return default_from address
    def self.configure_mail(deliver_using = :oddb_yml)
      return if @mail_configured == deliver_using
      @mail_configured = deliver_using
      if deliver_using == :test
        @mailing_list_configuration = MailingTestConfiguration
        @cfg = YAML.load_file(@mailing_list_configuration)
        Mail.defaults { delivery_method :test }
      else
        @mailing_list_configuration = MailingDefaultConfiguration
        if File.exist?(@mailing_list_configuration)
          @cfg = YAML.load_file(@mailing_list_configuration)
          @cfg["smtp_auth"] ||= "plain"
          cfg = @cfg.clone
          Mail.defaults do
            delivery_method :smtp, {
              address: cfg["smtp_server"],
              port: cfg["smtp_port"],
              domain: cfg["smtp_domain"],
              user_name: cfg["smtp_user"],
              password: cfg["smtp_pass"],
              authentication: cfg["smtp_auth"],
              content_transfer_encoding: "UTF-8"
            }
          end
        else
          @cfg = nil
        end
      end
      msg = "#{__FILE__}: Configured email using #{@mailing_list_configuration} @cfg is now #{@cfg ? @cfg["smtp_server"].inspect : "nil"} #{@cfg ? @cfg["smtp_port"].inspect : ""} #{@cfg ? @cfg["smtp_user"].inspect : ""}"
      Util.debug_msg(msg)
      @mail_configured
    end

    # Parts must be of form content_type => body, e.g. 'text/html; charset=UTF-8' => '<h1>This is HTML</h1>'
    def self.send_mail(list_and_recipients, mail_subject, mail_body, override_from = nil)
      Util.configure_mail unless @mail_configured
      LogFile.append("oddb/debug", "Util.send_mail list_and_recipients #{list_and_recipients}", Time.now)
      recipients = Util.check_and_get_all_recipients(list_and_recipients)
      mail = Mail.new
      mail.from override_from || Util.mail_from
      mail.to recipients
      mail.subject mail_subject.respond_to?(:force_encoding) ? mail_subject.force_encoding("utf-8") : mail_subject
      mail.body mail_body.respond_to?(:force_encoding) ? mail_body.force_encoding("utf-8") : mail_body
      mail.body.charset = "UTF-8"
      log_and_deliver_mail(mail)
    rescue => e
      msg = "Util.send_mail rescue: error is #{e.inspect} recipients #{recipients.inspect} #{caller.join("\n")}"
      msg += "\n#{mail_subject}"
      msg += "\n#{mail_body.to_s[0..160]}"
      Util.debug_msg(msg)
      raise e
    end

    def self.oddb_ci_save_mail(mail)
      subject = mail.subject.to_s.gsub(/\W/, "_")
      name = File.join(ENV["ODDB_CI_SAVE_MAIL_IN"], subject)
      FileUtils.makedirs(ENV["ODDB_CI_SAVE_MAIL_IN"])
      File.open(name, "a+") do |file|
        file.puts "Subject: #{mail.subject.to_s}"
        file.puts mail.body.to_s
      end
      LogFile.debug("Saved Mail without attachments #{name}")
      puts("Saved Mail without attachments #{name} #{subject} #{@deliveries}")
    end

    def self.send_mail_with_attachments(list_and_recipients, mail_subject, mail_body, attachments, override_from = nil)
      Util.configure_mail unless @mail_configured
      LogFile.append("oddb/debug", "Util.send_mail send_mail_with_attachments #{list_and_recipients}", Time.now)
      LogFile.append("oddb/debug", "Util.send_mail send_mail_with_attachments subject #{mail_subject}", Time.now)
      LogFile.append("oddb/debug", "Util.send_mail send_mail_with_attachments body #{mail_body}", Time.now)
      # try sending the mail several times
      nr_times = 0

      mail = Mail.new
      mail.from override_from || Util.mail_from
      mail.to Util.check_and_get_all_recipients(list_and_recipients)
      mail.subject mail_subject.respond_to?(:force_encoding) ? mail_subject.force_encoding("utf-8") : mail_subject
      mail.body mail_body
      mail.body.charset = "UTF-8"
      attachments.each do |attachment|
        mail.add_file filename: attachment[:filename], content: attachment[:content], mime_type: attachment[:mime_type]
        if ENV["ODDB_CI_SAVE_MAIL_IN"]
          filename = File.join(ENV["ODDB_CI_SAVE_MAIL_IN"], attachment[:filename])
          FileUtils.makedirs(ENV["ODDB_CI_SAVE_MAIL_IN"])
          File.open(filename, "w+") { |f| f.puts attachment[:content] }
        end
      end
      e = nil
      1.upto(3).each do |idx|
        nr_times = idx
        begin
          oddb_ci_save_mail(mail) if ENV["ODDB_CI_SAVE_MAIL_IN"]
          mail.deliver
          LogFile.append("oddb/debug", "Returning after #{idx} tries")
          return true
        rescue => e
          msg = "Util.send_mail_with_attachments rescue: idx is #{nr_times} error is #{e.inspect} #{caller[0..10].inspect}"
          Util.debug_msg(msg)
          sleep(1)
        end
      end
      raise "Util.send_mail_with_attachments Unable to send after #{nr_times} tries. error is #{e.inspect} #{caller[0..10].inspect}"
    end

    # Utility methods for checking mails in  unit-tests
    def self.sent_mails
      Mail::TestMailer.deliveries
    end

    # Utility methods for clearing mails in  unit-tests
    def self.clear_sent_mails
      Mail::TestMailer.deliveries.clear
    end

    private

    def self.check_and_get_all_recipients(list_and_recipients)
      Util.configure_mail unless @mail_configured
      recipients = []
      if list_and_recipients and list_and_recipients.is_a?(Array)
        foundList = false
        list_and_recipients.each { |id|
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

    def self.log_and_deliver_mail(mail)
      Util.configure_mail unless @mail_configured
      mail.from << @cfg["mail_from"] unless mail.from.size > 0
      mail.reply_to = @cfg["reply_to"]
      if ENV["ODDB_CI_SAVE_MAIL_IN"]
        oddb_ci_save_mail(mail)
        res = true
      else
        Util.debug_msg("Util.log_and_deliver_mail to=#{mail.to} subject #{mail.subject} size #{mail.body.to_s.size} with #{mail.attachments.size} attachments. #{mail.body.inspect}")
        res = mail.deliver
      end
      res
    end

    def self.debug_msg(msg)
      LogFile.append("oddb/debug", " " + msg, Time.now)
      warn msg unless defined?(Minitest)
    end
  end
end
