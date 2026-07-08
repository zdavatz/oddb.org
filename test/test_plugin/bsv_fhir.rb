#!/usr/bin/env ruby

# TestBsvFhirPlugin -- oddb.org -- 2026
# Regression coverage for the SL-introduction (Kassenzulässigkeit) change-flag
# logic in BsvFhirPlugin#fix_flags_with_rss_logic_for.

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "stub/odba"
require "model/package"
require "util/money"
require "util/logfile"
require "plugin/bsv_fhir"
require "flexmock/minitest"

module ODDB
  class TestBsvFhirPluginFlags < Minitest::Test
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end

    def setup
      @app = flexmock("app")
      @plugin = BsvFhirPlugin.new(@app)
      @listener = flexmock("preparations_listener")
      @plugin.instance_variable_set(:@preparations_listener, @listener)
      @pointer = flexmock("pointer")
    end

    # A valid_from inside the RSS window (today, which is always covered by the
    # range used by fix_flags_with_rss_logic_for).
    def in_range_time
      today = Date.today
      Time.local(today.year, today.month, today.day)
    end

    def public_price(amount, authority: :sl, valid_from: in_range_time)
      money = Util::Money.new(amount, :public, "CH")
      money.authority = authority
      money.valid_from = valid_from
      money
    end

    # Regression: the new price has already been unshifted to price_public(0) by
    # the time fix_flags_with_rss_logic_for runs, so "previous" must be read from
    # price_public(1). A brand-new SL entry (no prior price => price_public(1) is
    # nil) must be flagged :sl_entry so the med-drugs xls lists the new
    # Kassenzulässigkeit. Reading price_public(0) here (the old bug) would always
    # return the freshly stored price and never flag it.
    def test_flags_sl_entry_for_new_sl_price
      price = public_price(12.30)
      pack = flexmock("pack")
      pack.should_receive(:price_public).with(1).and_return(nil)
      pack.should_receive(:pointer).and_return(@pointer)
      @listener.should_receive(:flag_change).with(@pointer, :sl_entry).once
      @plugin.send(:fix_flags_with_rss_logic_for, pack, price, "12345")
    end

    def test_flags_price_cut_when_price_drops
      price = public_price(10.00)
      pack = flexmock("pack")
      pack.should_receive(:price_public).with(1).and_return(public_price(12.00))
      pack.should_receive(:data_origin).with(:price_public).and_return(:sl)
      pack.should_receive(:pointer).and_return(@pointer)
      @listener.should_receive(:flag_change).with(@pointer, :price_cut).once
      @plugin.send(:fix_flags_with_rss_logic_for, pack, price, "12345")
    end

    def test_flags_price_rise_when_price_increases
      price = public_price(15.00)
      pack = flexmock("pack")
      pack.should_receive(:price_public).with(1).and_return(public_price(12.00))
      pack.should_receive(:data_origin).with(:price_public).and_return(:sl)
      pack.should_receive(:pointer).and_return(@pointer)
      @listener.should_receive(:flag_change).with(@pointer, :price_rise).once
      @plugin.send(:fix_flags_with_rss_logic_for, pack, price, "12345")
    end

    def test_does_not_flag_new_entry_when_authority_not_sl
      price = public_price(12.30, authority: :bag)
      pack = flexmock("pack")
      pack.should_receive(:price_public).with(1).and_return(nil)
      @listener.should_receive(:flag_change).never
      @plugin.send(:fix_flags_with_rss_logic_for, pack, price, "12345")
    end

    def test_does_not_flag_when_valid_from_out_of_range
      price = public_price(12.30, valid_from: Time.local(2000, 1, 1))
      pack = flexmock("pack")
      @listener.should_receive(:flag_change).never
      @plugin.send(:fix_flags_with_rss_logic_for, pack, price, "12345")
    end

    def test_returns_without_error_when_price_nil
      pack = flexmock("pack")
      @listener.should_receive(:flag_change).never
      assert_nil(@plugin.send(:fix_flags_with_rss_logic_for, pack, nil, "12345"))
    end
  end
end
