#!/usr/bin/env ruby

$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "util/resilient_loop"

module ODDB
  LoopName = "tst_loop"
  class TestResilientLoop < Minitest::Test
    TimeoutValue = 0.1
    def setup
      sleep(TimeoutValue * 2)
      @r_loop = nil
      super
    end

    def teardown
      @r_loop.finished
      super
      sleep(TimeoutValue * 2)
    end

    def test_full_loop_no_problem
      @r_loop = ResilientLoop.new(LoopName)
      assert_nil(@r_loop.state_id)
      result = []
      loop_entries = [0, 1, 2, 3]
      loop_entries.each { |entry|
        @r_loop.try_run(entry, TimeoutValue) { result << entry }
      }
      @r_loop.finished
      assert_equal(loop_entries, result)
      assert_nil(@r_loop.state_id)
    end

    def test_full_loop_always_timeout
      @r_loop = ResilientLoop.new(LoopName)
      assert_nil(@r_loop.state_id)
      result = []
      loop_entries = [0, 1, 2, 3]
      begin
        loop_entries.each { |entry|
          @r_loop.try_run(entry, TimeoutValue) {
            sleep(TimeoutValue * 2)
            result << entry
          }
        }
        @r_loop.finished
      rescue Timeout::Error
      end
      assert_equal([], result)
      assert_nil(@r_loop.state_id)
    end

    def test_full_loop_recovers_from_first_timeout
      @r_loop = ResilientLoop.new(LoopName)
      assert_nil(@r_loop.state_id)
      result = []
      loop_entries = [0, 1, 2, 3, 4, 5, 6]
      toggle = false
      begin
        loop_entries.each { |entry|
          @r_loop.try_run(entry, TimeoutValue) {
            toggle = !toggle
            sleep(TimeoutValue * 2) if toggle
            result << entry
          }
        }
      rescue Timeout::Error
      end
      assert_equal(loop_entries, result)
      assert_nil(@r_loop.state_id)
    end

    def test_skip_some_entries
      failAtEntry = 2
      # first simulate a loop which has a timeout at id == 2 (aka failAtEntry)
      @r_loop = ResilientLoop.new(LoopName)
      result = []
      loop_entries = [0, 1, 2, 3, 4]
      assert_raises(Timeout::Error) do
        loop_entries.each { |entry|
          next if @r_loop.must_skip?(entry)
          @r_loop.try_run(entry, TimeoutValue) do
            sleep(TimeoutValue * 2) if entry == failAtEntry
            result << entry
          end
        }
      end
      assert_equal([0, 1], result)
      assert_nil(@r_loop.state_id)
      assert_equal(0, @r_loop.nr_skipped)
      assert(File.exist?(@r_loop.state_file))

      # now start with a fresh loop
      @r_loop = ResilientLoop.new(LoopName)
      assert(File.exist?(@r_loop.state_file))
      assert_equal(1, @r_loop.state_id)
      result = []
      loop_entries.each { |entry|
        next if @r_loop.must_skip?(entry)
        @r_loop.try_run(entry, TimeoutValue) { result << entry }
      }
      assert_nil(@r_loop.state_id)
      assert_equal([2, 3, 4], result)
      assert_equal(2, @r_loop.nr_skipped)
    end
  end
end
