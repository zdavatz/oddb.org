#!/usr/bin/env ruby
# encoding: utf-8
# Here we test whether sending mails work
$: << File.expand_path("../../src", File.dirname(__FILE__))


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
    ReplyTo = ['default_reply_to@ywesee.com']
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
      assert_equal(['customer@company.com', 'ywesee_test@ywesee.com', 'customer2@another_company.com'].sort, Util.get_mailing_list_receivers('oddb_csv'))
      Util.use_mailing_list_configuration('dummy.txt')
      assert_operator(ODDB::Util::MailingTestConfiguration, :!=, Util.mailing_configuration_file)
    end

    def test_send_to_mailing_list_oddb_csv
      res = Util.send_mail('oddb_csv', "Test Mail from #{__FILE__}", "Test run at #{Time.now}")
      assert(res, "sending of mail to #{'oddb_csv'} must succeed")
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert(mails_sent.first.to.index('customer2@another_company.com'))
      assert(mails_sent.first.to.index('customer@company.com'))
      assert(mails_sent.first.to.index('ywesee_test@ywesee.com'))
    end
    def test_mailing_anrede
      # setup is set tot test
      assert_equal(['Dear Mrs. Smith', 'Dear Mr. Jones'].sort, Util.get_mailing_list_anrede('oddb_csv'))
      assert_equal(['Dear Mrs. Smith', 'Dear Mr. Jones'].sort, Util.get_mailing_list_anrede(['oddb_csv']))
    end

    def test_mailing_anrede_is_nil
      # setup is set tot test
      assert_equal([], Util.get_mailing_list_anrede('test_no_anrede'))
      res = Util.send_mail(['test_no_anrede'], "Test Mail from #{__FILE__}", "Test run at #{Time.now}")
      assert(res, "sending of mail to #{'test_no_anrede'} must succeed")
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert_equal(mails_sent.first.to, ['no_anrede@another_company.com'])
    end

    def test_mailing_with_utf_8
      # setup is set tot test
      assert_equal([], Util.get_mailing_list_anrede('test_no_anrede'))
      res = Util.send_mail(['test_no_anrede'], "Test mit möglichen UTF-8 #{__FILE__}", "èöÄÜçTest run at #{Time.now}")
      assert(res, "sending of mail to #{'test_no_anrede'} must succeed")
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert_equal(mails_sent.first.to, ['no_anrede@another_company.com'])
    end

    def test_send_to_mailing_list_test_and_another_receiver # same use case as ipn
      res = Util.send_mail(['test', 'somebody@test.org'], "Test Mail from #{__FILE__}", "Test run at #{Time.now}")
      assert(res, "sending of mail to test and another receiver must succeed")
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert_equal(2, mails_sent.first.to.size)
      assert_equal([Util.mail_from], mails_sent.first.from)
      assert_equal(ReplyTo, mails_sent.first.reply_to)
      assert(mails_sent.first.to.index('somebody@test.org'))
      assert(mails_sent.first.to.index('ywesee_test@ywesee.com'))
    end

    def test_send_to_mailing_list_test
      res = Util.send_mail('test', "Test Mail from #{__FILE__}", "Test run at #{Time.now}")
      assert(res, "sending of mail to #{'test'} must succeed")
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert_equal(['ywesee_test@ywesee.com'], mails_sent[0].to)
      assert_equal(ReplyTo, mails_sent.first.reply_to)
    end

    def test_send_and_check_receiving_test_mail
      saved_env = ENV['ODDB_CI_SAVE_MAIL_IN']
      ENV['ODDB_CI_SAVE_MAIL_IN'] = nil
      begin
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
      rescue => error
        puts error
      end
      ENV['ODDB_CI_SAVE_MAIL_IN'] = saved_env
    end
    def test_send_to_mailing_with_attachement
      attachment = {
        :filename => 'notifications.csv',
        :mime_type => 'text/csv',
        :content => 'example_content',
      }
      res  = Util.send_mail_with_attachments('oddb_csv', 'Täglicher CSV-Export der Notifications', 'mail_body', [attachment])
      assert(res, "sending of mail to #{'test'} must succeed")
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert(mails_sent.first.to.index('customer2@another_company.com'))
      assert_equal(1, mails_sent.first.attachments.size)
      assert_equal('notifications.csv', mails_sent.first.attachments.first.filename)
      assert_equal('text/csv', mails_sent.first.attachments.first.mime_type)
      assert_equal('example_content', mails_sent.first.attachments.first.body.decoded)
      assert_equal('mail_body', mails_sent.first.parts.first.body.to_s)
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
      if Util.get_mailing_list_receivers('admin').empty?
        skip "Cannot test sending an email if admin list is empty"
      end
      res = Util.send_mail('admin', "Test Mail from #{__FILE__}", "Test run at #{Time.now}")
    end
  end
end

