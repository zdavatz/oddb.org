#!/usr/bin/env ruby
# encoding: utf-8
# Here we test whether sending mails work
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'config'
require 'util/mail'
require 'pp'

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

    def test_mailing_configuration
      # setup is set tot test
      assert_equal(ODDB::Util::MailingTestConfiguration, Util.mailing_configuration_file)
      assert_equal([],                                                                                       Util.get_mailing_list_receivers('non_existent_id'))
      assert_equal(['ywesee_test@ywesee.com'],                                                               Util.get_mailing_list_receivers('test'))
      assert_equal(['ywesee_test@ywesee.com', 'customer@company.com'].sort,                                  Util.get_mailing_list_receivers('oddb'))
      assert_equal(['customer@company.com', 'ywesee_test@ywesee.com', 'customer2@another_company.com'].sort, Util.get_mailing_list_receivers('oddb2csv'))
      Util.use_mailing_list_configuration('dummy.txt')
      assert_operator(ODDB::Util::MailingTestConfiguration, :!=, Util.mailing_configuration_file)
    end

    def test_send_to_mailing_list_oddb2csv
      res = Util.send_mail('oddb2csv', "Test Mail from #{__FILE__}", "Test run at #{Time.now}")
      assert(res, "sending of mail to #{'oddb2csv'} must succeed")
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert(mails_sent.first.to.index('customer2@another_company.com'))
      assert(mails_sent.first.to.index('customer@company.com'))
      assert(mails_sent.first.to.index('ywesee_test@ywesee.com'))
    end
    def test_mailing_anrede
      # setup is set tot test
      assert_equal(['Dear Mrs. Smith', 'Dear Mr. Jones'].sort, Util.get_mailing_list_anrede('oddb2csv'))
    end

    def test_send_to_mailing_list_test_and_another_receiver # same use case as ipn
      res = Util.send_mail(['test', 'somebody@test.org'], "Test Mail from #{__FILE__}", "Test run at #{Time.now}")
      assert(res, "sending of mail to test and another receiver must succeed")
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert_equal(2, mails_sent.first.to.size)
      assert(mails_sent.first.to.index('somebody@test.org'))
      assert(mails_sent.first.to.index('ywesee_test@ywesee.com'))
    end

    def test_send_to_mailing_list_test
      res = Util.send_mail('test', "Test Mail from #{__FILE__}", "Test run at #{Time.now}")
      assert(res, "sending of mail to #{'test'} must succeed")
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert_equal(['ywesee_test@ywesee.com'], mails_sent[0].to)
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
      assert_operator(ODDB::Util::MailingTestConfiguration, :!=, Util.mailing_configuration_file)
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

    def test_send_an_email
      if Util.get_mailing_list_receivers('admin')
        skip "Cannot test sending an email if not admin list is defined"
      end
      res = Util.send_mail('admin', "Test Mail from #{__FILE__}", "Test run at #{Time.now}")
    end
  end
end

