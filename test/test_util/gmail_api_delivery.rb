#!/usr/bin/env ruby

# Report mails go out through the Gmail REST API when etc/oddb.yml says
# mail_delivery: gmail_api (since 11.11.2026, when Gmail refused the SMTP
# password).

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "mail"
require "base64"
require "flexmock/minitest"
require "util/gmail_api_delivery"

class TestGmailApiDelivery < Minitest::Test
  class FakeApi
    attr_reader :mailbox, :raw
    def initialize(mailbox) = (@mailbox = mailbox)
    def send_raw(raw)
      @raw = raw
      "msg-123"
    end
  end

  def test_the_encoded_mail_goes_to_send_raw_of_the_configured_mailbox
    api = nil
    factory = ->(box) { api = FakeApi.new(box) }
    mail = Mail.new do
      from "admin@ywesee.com"
      to %w[zdavatz@ywesee.com ngiger@ywesee.com]
      subject "ch.ODDB.org Report - Fach- und Patienteninfo Updates"
      body "Änderungen: 3"
    end
    mail.charset = "UTF-8"
    mail.delivery_method ODDB::GmailApiDelivery, mailbox: "zdavatz@ywesee.com", api_factory: factory
    mail.deliver
    assert_equal("zdavatz@ywesee.com", api.mailbox)
    decoded = Mail.new(api.raw)
    assert_equal(%w[zdavatz@ywesee.com ngiger@ywesee.com], decoded.to)
    assert_match(/\Ach.ODDB.org Report/, decoded.subject)
    assert_equal("Änderungen: 3", decoded.body.decoded.force_encoding("UTF-8"))
  end

  def test_attachments_travel_in_the_raw_message
    api = nil
    mail = Mail.new(from: "a@b.ch", to: "c@d.ch", subject: "x", body: "y")
    mail.add_file(filename: "report.csv", content: "a;b\n1;2\n")
    mail.delivery_method ODDB::GmailApiDelivery, mailbox: "m@ywesee.com",
      api_factory: ->(box) { api = FakeApi.new(box) }
    mail.deliver
    assert_equal(["report.csv"], Mail.new(api.raw).attachments.map(&:filename))
  end

  def test_errors_from_the_api_reach_the_caller
    failing = Class.new { def send_raw(_) = raise(RuntimeError, "401 invalid_grant") }
    mail = Mail.new(from: "a@b.ch", to: "c@d.ch", subject: "x", body: "y")
    mail.delivery_method ODDB::GmailApiDelivery, mailbox: "m", api_factory: ->(_) { failing.new }
    assert_raises(RuntimeError) { mail.deliver }
  end

  def test_a_send_token_is_handed_to_the_api
    api = FakeApi.new("admin@oddb.org")
    flexmock(ODDB::GmailApi).should_receive(:new).with("admin@oddb.org", nil, nil, "send-token").once.and_return(api)
    mail = Mail.new(from: "admin@oddb.org", to: "c@d.ch", subject: "x", body: "y")
    mail.delivery_method ODDB::GmailApiDelivery, mailbox: "admin@oddb.org", refresh_token: "send-token"
    mail.deliver
    assert(api.raw)
  end
end
