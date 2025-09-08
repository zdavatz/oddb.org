#!/usr/bin/env ruby

# Here we test whether sending mails work
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "config"
require "util/log"
require "pp"

# tries to send and receive a real mail using the Test user of etc/oddb.yaml
module ODDB
  class TestLogNotify < Minitest::Test
    # see https://github.com/mikel/mail section Using Mail with Testing or Spec'ing Libraries
    # this is a how other users can check whether an action, e.g. running an exporter will actually send an email
    # part of it is implemented in the stub/mail function
    ReplyTo = ["default_reply_to@ywesee.com"]
    TEST_RECEIVER = "ywesee_test@ywesee.com" # as defined in test/data/oddb_mailing_test.yml
    LOG_RECEIPIENTS = ["log"]
    TEST_SUBJECT = "ch.ODDB.org Report"
    TEST_SUBJECT_2 = "another_test_subject"
    ENV["ODDB_CI_SAVE_MAIL_IN"] = nil
    def setup
      Util.configure_mail :test
      Util.clear_sent_mails
    end

    def test_log_simple
      log = Log.new(Date.today)
      res = log.notify
      assert(res, "sending of mail to test must succeed")
      assert_equal(LOG_RECEIPIENTS, res)
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      mail = mails_sent.first
      assert(mail.subject.match(/#{TEST_SUBJECT}/o), "Subject must match #{TEST_SUBJECT}")
      assert(mail.to.index(TEST_RECEIVER))
      assert_equal("", mail.body.to_s)
      assert_equal(0, mail.attachments.size)
    end

    def test_log_with_1_file
      log = Log.new(Date.today)
      log.files.store("/etc/hosts", "text/plain")
      res = log.notify(TEST_SUBJECT_2)
      assert(res, "sending of mail to test must succeed")
      assert_equal(LOG_RECEIPIENTS, res)
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      mail = mails_sent.first
      assert(mail.subject.match(/#{TEST_SUBJECT_2}/o), "Subject must match #{TEST_SUBJECT_2}")
      assert(mail.to.index(TEST_RECEIVER))
      assert_equal("", mail.body.to_s)
      assert_equal(1, mail.attachments.size)
      assert_equal("hosts", mail.attachments.first.filename)
      assert_equal("text/plain", mail.attachments.first.mime_type)
      assert(mail.attachments.first.body.decoded.size > 0, "must have some content in file /etc/hosts")
      assert(mail.attachments.first.body.decoded.match(/localhost/), "/etc/hosts usually contains an entry for localhost")
    end

    def test_log_with_1_part
      log = Log.new(Date.today)
      log.parts.push ["text/plain", "test_file", "example_content"]

      res = log.notify(TEST_SUBJECT_2)
      assert(res, "sending of mail to test must succeed")
      assert_equal(LOG_RECEIPIENTS, res)
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      mail = mails_sent.first
      assert(mail.subject.match(/#{TEST_SUBJECT_2}/o), "Subject must match #{TEST_SUBJECT_2}")
      assert(mail.to.index(TEST_RECEIVER))
      assert_equal("", mail.body.to_s)
      assert_equal(1, mail.attachments.size)
      assert_equal("test_file", mail.attachments.first.filename)
      assert_equal("text/plain", mail.attachments.first.mime_type)
      assert_equal("example_content", mail.attachments.first.body.decoded)
    end

    def test_log_with_1_part_and_1_file
      log = Log.new(Date.today)
      log.parts.push ["text/csv", "test_file", "example_content"]
      log.files.store("/etc/hosts", "text/plain")
      res = log.notify(TEST_SUBJECT_2)
      assert(res, "sending of mail to test must succeed")
      assert_equal(LOG_RECEIPIENTS, res)
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      mail = mails_sent.first
      assert(mail.subject.match(/#{TEST_SUBJECT_2}/o), "Subject must match #{TEST_SUBJECT_2}")
      assert(mail.to.index(TEST_RECEIVER))
      assert_equal("", mail.body.to_s)
      assert_equal(2, mail.attachments.size)
      assert_equal("hosts", mail.attachments.first.filename)
      assert_equal("text/plain", mail.attachments.first.mime_type)
      assert(mail.attachments.first.body.decoded.size > 0, "must have some content in file /etc/hosts")
      assert(mail.attachments.first.body.decoded.match(/localhost/), "/etc/hosts usually contains an entry for localhost")

      second = mail.attachments.last
      assert_equal("test_file", second.filename)
      assert_equal("text/csv", second.mime_type)
      assert_equal("example_content", second.body.decoded)
    end

    def test_log_with_body
      test_body = "content_for_mail_body_ng"
      log = Log.new(Date.today)
      log.report = test_body.clone
      log.parts.push ["text/csv", "test_file", "example_content"]
      log.files.store("/etc/hosts", "text/plain")
      res = log.notify(TEST_SUBJECT_2)
      assert(res, "sending of mail to test must succeed")
      assert_equal(LOG_RECEIPIENTS, res)
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      mail = mails_sent.first
      assert(mail.subject.match(/#{TEST_SUBJECT_2}/o), "Subject must match #{TEST_SUBJECT_2}")
      assert(mail.to.index(TEST_RECEIVER))
      assert_equal(test_body, mail.parts.first.decoded)
      assert_equal(2, mail.attachments.size)
    end
  end
end
