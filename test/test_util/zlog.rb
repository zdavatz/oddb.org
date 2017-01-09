#!/usr/bin/env ruby
# encoding: utf-8
# TestLog -- oddb -- 26.05.2003 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'util/log'
require 'stub/odba'
require 'flexmock/minitest'
require 'util/logfile'
require 'util/mail'

module ODDB

   class TestLog <Minitest::Test
    TEST_SENDER   = 'default_mail_from@ywesee.com'
    LOG_RECEIVER  = 'ywesee_test@ywesee.com' # as defined in test/data/oddb_mailing_test.yml
    SUBJECT       = 'ch.ODDB.org Report - 08/1975'
    def setup
      Util.configure_mail :test
      Util.clear_sent_mails
      @log = ODDB::Log.new(Date.new(1975,8,21))
    end
    def test_notify_defaults
      @log.notify
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert_equal([LOG_RECEIVER], mails_sent.first.to) # as defined in test/data/oddb_mailing_test.yml
      assert_equal([TEST_SENDER], mails_sent.first.from)
      assert_equal(SUBJECT, mails_sent.first.subject)
      assert_equal('', mails_sent.first.body.to_s)
    end
    def test_notify
      hash = {
        :recipients => ['log'],
        :pointers =>   ['aPointer'],
        :report =>     "first lengthy report.\n"
      }
      @log.update_values(hash)
      @log.notify

      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert_equal([LOG_RECEIVER], mails_sent.first.to) # as defined in test/data/oddb_mailing_test.yml
      assert_equal([TEST_SENDER], mails_sent.first.from)
      assert_equal(SUBJECT, mails_sent.first.subject)
      assert_equal(hash[:report], mails_sent.first.body.to_s)
    end
    def test_notify_date_str
      hash = {
        :recipients => ['log'],
        :pointers =>   ['aPointer'],
        :report =>     "second lengthy report.\n",
        :date_str =>   'Today',
      }
      @log.update_values(hash)
      @log.notify('Subject')

      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert_equal([LOG_RECEIVER], mails_sent.first.to)
      assert_equal([TEST_SENDER], mails_sent.first.from)
      assert_equal('ch.ODDB.org Report - Subject - Today', mails_sent.first.subject)
      assert_equal(hash[:report], mails_sent.first.body.to_s)
    end
    def test_notify_file
      file = File.expand_path('../data/txt/log.txt', File.dirname(__FILE__))
      File.open(file, 'w+') { |f| f.puts "Dummy content" }
      hash = {
        :recipients => ['log'],
        :pointers =>   ['aPointer'],
        :report =>     "a lengthy report.\n",
        :files =>      { file => 'application/vnd.ms-excel' },
      }
      @log.update_values(hash)
      @log.notify
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert_equal([TEST_SENDER], mails_sent.first.from)
      assert_equal([LOG_RECEIVER], mails_sent.first.to)
      assert_equal(hash[:report], mails_sent.first.parts.first.decoded)
      assert_equal(SUBJECT, mails_sent.first.subject)
    end
    def test_notify_parts
      mail_body =  "We expected no SMeX/SL-Differences"
      part_content = "SMeX/SL-Differences (Registrations) 10.09.2014  0
SL hat anderen 5-Stelligen Swissmedic-Code als SMeX
"
      file = File.expand_path('../data/txt/log.txt', File.dirname(__FILE__))
      File.open(file, 'w+') { |f| f.puts "Dummy content" }
      hash = {
        :recipients => ['log'],
        :pointers =>   ['aPointer'],
        :report =>     mail_body,
        :parts  =>     [["text/plain", "SMeX_SL_Differences__Registrations__10.09.2014.txt", part_content]]
      }
      @log.update_values(hash)
      @log.notify
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert_equal([TEST_SENDER], mails_sent.first.from)
      assert_equal([LOG_RECEIVER], mails_sent.first.to)
      assert_equal(mail_body, mails_sent.first.parts.first.decoded)
      assert_equal(SUBJECT, mails_sent.first.subject)
      assert_equal(1, mails_sent.first.attachments.size)
      assert_equal(part_content, mails_sent.first.attachments.first.body.decoded)
    end
  end
end
