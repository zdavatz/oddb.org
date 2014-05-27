#!/usr/bin/env ruby
# encoding: utf-8
# TestLog -- oddb -- 26.05.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'util/log'
require 'stub/odba'
require 'flexmock'
require 'util/logfile'
require 'util/mail'

module ODDB

   class TestLog <Minitest::Test
    include FlexMock::TestCase
    def setup
      Util.configure_mail :test
      Util.clear_sent_mails
      @log = ODDB::Log.new(Date.new(1975,8,21))
    end
    def test_notify
      hash = {
        :recipients	=>	['hwyss@ywesee.com'],
        :pointers => ['aPointer'],
        :report =>	"first lengthy report.\n"
      }
      @log.update_values(hash)
      @log.notify

      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert_equal(['hwyss@ywesee.com'], mails_sent.first.to)
      assert_equal([ODDB::Log::MAIL_FROM], mails_sent.first.from)
      assert_equal('ch.ODDB.org Report - 08/1975', mails_sent.first.subject)
      assert_equal(hash[:report], mails_sent.first.body.to_s)
    end
    def test_notify_date_str
      hash = {
        :recipients	=>	['hwyss@ywesee.com'],
        :pointers => ['aPointer'],
        :report =>	"second lengthy report.\n",
        :date_str =>	'Today',
      }
      @log.update_values(hash)
      @log.notify('Subject')

      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert_equal(['hwyss@ywesee.com'], mails_sent.first.to)
      assert_equal([ODDB::Log::MAIL_FROM], mails_sent.first.from)
      assert_equal('ch.ODDB.org Report - Subject - Today', mails_sent.first.subject)
      assert_equal(hash[:report], mails_sent.first.body.to_s)
    end
    def test_notify_file
      file = File.expand_path('../data/txt/log.txt', File.dirname(__FILE__))
      File.open(file, 'w+') { |f| f.puts "Dummy content" }
      hash = {
        :recipients	=>	['hwyss@ywesee.com'],
        :pointers => ['aPointer'],
        :report =>	"a lengthy report.\n",
        :files =>	{ file =>	'application/vnd.ms-excel' },
      }
      @log.update_values(hash)
      @log.notify
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert_equal(ODDB.config.mail_to, mails_sent.first.to)
      assert_equal([ODDB::Util::EmailTestAddressFrom], mails_sent.first.from)
      assert_equal(hash[:report], mails_sent.first.body.to_s)
      assert_equal('ch.ODDB.org Report - 08/1975', mails_sent.first.subject)
    end
  end
end
