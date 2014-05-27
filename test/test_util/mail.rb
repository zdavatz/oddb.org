#!/usr/bin/env ruby
# encoding: utf-8
# Here we test whether sending mails work
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'config'
require 'util/mail'

# tries to send and receive a real mail using the Test user of etc/oddb.yaml
module ODDB
  class TestMailSending < Minitest::Test
    # see https://github.com/mikel/mail section Using Mail with Testing or Spec'ing Libraries
    # this is a how other users can check whether an action, e.g. running an exporter will actually send an email
    # part of it is implemented in the stub/mail function
    def setup
      Util.configure_mail :test
      Util.clear_sent_mails
    end

    def test_send_and_check_receiving_test_mail
      mails_sent = Util.sent_mails
      assert_equal(0, mails_sent.size)
      Mail.deliver do
        to 'mikel@me.com'
        from 'you@you.com'
        subject 'testing'
        body 'hello'
      end
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert_equal(['mikel@me.com'], mails_sent.first.to)
      assert_equal(['you@you.com'], mails_sent.first.from)
      assert_equal('testing', mails_sent.first.subject)
      assert_equal('hello', mails_sent.first.body.to_s)
      mails_sent = Util.sent_mails
      Mail.deliver do
        to 'you@you.com'
        from 'mikel@me.com'
        subject 'testing answer'
        body 'hello'
      end
      assert_equal(2, mails_sent.size)
      Util.clear_sent_mails
      mails_sent = Util.sent_mails
      assert_equal(0, mails_sent.size)
    end
  end

  class TestSendRealMail <Minitest::Test
    def setup
      Util.configure_mail :oddb_yml
      # No Util.clear_sent_mails here, as this would throw away my e-mails!
      @config = ODDB.config
    end

    def receive_mail
      cfg = @config
      Mail.defaults do
        retriever_method :pop3, :address    => cfg.smtp_server,
                                :port       => 995,
                                :user_name  => cfg.smtp_user,
                                :password   => cfg.smtp_pass,
                                :enable_ssl => true
      end
      mail = Mail.last
      assert(mail, 'must have received an e-mail')
    end

    def get_newest_email
      cfg = @config
      Mail.defaults do
        retriever_method :pop3, :address    => cfg.smtp_server,
                                :port       => 995,
                                :user_name  => cfg.smtp_user,
                                :password   => cfg.smtp_pass,
                                :enable_ssl => true
      end
      puts "get_newest_email"
      emails = Mail.last
      puts "get_newest_email #{emails.inspect}"
    end

    def test_send_and_receive_an_email
      return
      if Dir.glob(@config.config).size == 0
        skip "Cannot test sending/receiving e-email without a config file from #{@config.config}"
        return
      end
      skip "As I only receive old e-mail of 2013"
      get_newest_email
      res = Util.send_mail(@config.mail_to, "Test Mail from #{__FILE__}", "Test run at #{Time.now}")
      assert(res, "sending of mail to #{@config.mail_to} must succeed")
      get_newest_email
    end
  end
end

