#!/usr/bin/env ruby

# TestUpdater -- oddb.org -- 2026
# Regression coverage for the monthly change_flags merge. A monthly log is
# written once per import run and each run only reports what changed since the
# previous download, so a later run must not discard what an earlier run
# recorded for the same month.

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "stub/odba"
require "flexmock/minitest"
require "util/updater"

module ODDB
  class TestUpdaterChangeFlags < Minitest::Test
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end

    def setup
      @app = flexmock("app")
      @updater = Updater.new(@app)
      # Outside of a real app run @prevalence stays nil, which would make the
      # helper skip the merge entirely; inject a stub so the merge path runs.
      @prevalence = flexmock("prevalence")
      @updater.instance_variable_set(:@prevalence, @prevalence)
      @ptr_a = Persistence::Pointer.new([:registration, "12345"])
      @ptr_b = Persistence::Pointer.new([:registration, "67890"])
    end

    def stub_pointer(existing_flags)
      pointer = flexmock("pointer")
      log = flexmock("log")
      log.should_receive(:change_flags).and_return(existing_flags)
      pointer.should_receive(:resolve).with(@prevalence).and_return(log)
      pointer
    end

    # The regression: Swissmedic republished a corrected Packungen file, the
    # resulting diff carried only :size, and it used to overwrite the :new
    # registrations an earlier run had recorded for the same month.
    def test_keeps_previously_recorded_flags_for_untouched_registration
      pointer = stub_pointer({@ptr_a => [:new, :name_base]})
      values = {change_flags: {@ptr_b => [:size]}}
      result = @updater.send(:merge_previous_change_flags, pointer, values)
      assert_equal([:new, :name_base], result[:change_flags][@ptr_a])
      assert_equal([:size], result[:change_flags][@ptr_b])
    end

    def test_merges_flags_for_registration_present_in_both
      pointer = stub_pointer({@ptr_a => [:new]})
      values = {change_flags: {@ptr_a => [:size]}}
      result = @updater.send(:merge_previous_change_flags, pointer, values)
      assert_equal([:size, :new], result[:change_flags][@ptr_a])
    end

    def test_does_not_duplicate_flags
      pointer = stub_pointer({@ptr_a => [:new, :size]})
      values = {change_flags: {@ptr_a => [:size]}}
      result = @updater.send(:merge_previous_change_flags, pointer, values)
      assert_equal([:size, :new], result[:change_flags][@ptr_a])
    end

    def test_skips_nil_pointer_key
      # https://github.com/zdavatz/oddb.org/issues/175
      pointer = stub_pointer({nil => [:new]})
      values = {change_flags: {@ptr_a => [:size]}}
      result = @updater.send(:merge_previous_change_flags, pointer, values)
      assert_equal({@ptr_a => [:size]}, result[:change_flags])
    end

    def test_handles_missing_previous_log
      pointer = flexmock("pointer")
      pointer.should_receive(:resolve).with(@prevalence).and_return(nil)
      values = {change_flags: {@ptr_a => [:size]}}
      result = @updater.send(:merge_previous_change_flags, pointer, values)
      assert_equal({@ptr_a => [:size]}, result[:change_flags])
    end

    def test_handles_values_without_change_flags
      pointer = stub_pointer({@ptr_a => [:new]})
      values = {report: "no flags here"}
      result = @updater.send(:merge_previous_change_flags, pointer, values)
      assert_equal("no flags here", result[:report])
    end
  end

  class TestSwissmedicDegenerateDiff < Minitest::Test
    def teardown
      ODBA.storage = nil
      super
    end

    def setup
      @app = flexmock("app")
      @plugin = SwissmedicPlugin.new(@app)
    end

    def degenerate_changes(nr)
      (1..nr).each_with_object({}) { |idx, memo| memo["%05i" % idx] = [:size] }
    end

    def healthy_changes(nr)
      (1..nr).each_with_object({}) { |idx, memo|
        memo["%05i" % idx] = [:new, :name_base, :composition]
      }
    end

    def test_warns_on_size_only_mass_diff
      flexmock(LogFile).should_receive(:debug)
        .with(/SwissmedicDiff SUSPECT.*:size/m).once
      @plugin.send(:warn_if_degenerate_diff, degenerate_changes(1182))
    end

    def test_does_not_warn_on_healthy_diff
      flexmock(LogFile).should_receive(:debug).with(/SUSPECT/).never
      @plugin.send(:warn_if_degenerate_diff, healthy_changes(600))
    end

    def test_does_not_warn_on_small_diff
      # a normal month touches a few hundred registrations - never suspect
      flexmock(LogFile).should_receive(:debug).with(/SUSPECT/).never
      @plugin.send(:warn_if_degenerate_diff, degenerate_changes(191))
    end

    def test_handles_nil_changes
      flexmock(LogFile).should_receive(:debug).with(/SUSPECT/).never
      assert_nil(@plugin.send(:warn_if_degenerate_diff, nil))
    end
  end
end
