#!/usr/bin/env ruby

# TestInvoicer -- oddb.org -- 21.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "plugin/invoicer"
require "util/persistence"
require "util/log"
require "util/today"

class TestInvoicer < Minitest::Test
  def setup
    @app = flexmock("app")
    @invoicer = ODDB::Invoicer.new(@app)
  end

  def test_create_invoice
    pointer = flexmock("pointer")
    flexmock(pointer,
      :+ => pointer,
      :dup => pointer,
      :creator => nil)

    invoice = flexmock("invoice", pointer: pointer)
    flexmock(@app,
      update: invoice)
    flexmock(ODDB::Persistence::Pointer).new_instances do |p|
      p.should_receive(:creator)
    end
    item = {"key" => "value"}
    assert_equal([item], @invoicer.create_invoice("email", [item]))
  end

  def test_ensure_yus_user
    # ensure_yus_user now just returns invoice_email (no Yus interaction)
    comp_or_hosp = flexmock("comp_or_hosp", invoice_email: "invoice_email")
    assert_equal("invoice_email", @invoicer.ensure_yus_user(comp_or_hosp))
  end

  def test_rp2fr
    assert_in_delta(1.234, @invoicer.rp2fr(123.4), 0.01)
  end
end
