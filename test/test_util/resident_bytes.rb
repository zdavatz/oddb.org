#!/usr/bin/env ruby

# The memory limit in ODDB::App#log_size is checked against resident memory,
# not vsize. Until 30.09.2026 it read vsize, which grows with every thread's
# reserved stack and arena: oddb exited at 6144 MB with under 1 GB resident.

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "stub/odba"
require "stub/config"
require "minitest/autorun"
require "util/oddbapp"

class TestResidentBytes < Minitest::Test
  def test_matches_vmrss
    skip "no /proc" unless File.exist?("/proc/self/status")
    vmrss = File.read("/proc/self/status")[/^VmRSS:\s+(\d+)/, 1].to_i * 1024
    rss = ODDB::App.resident_bytes
    assert_in_delta(vmrss, rss, 16 * 2**20)
  end

  def test_is_not_vsize
    skip "no /proc" unless File.exist?("/proc/self/stat")
    stat = File.read("/proc/self/stat")
    vsize = stat[(stat.rindex(")") + 2)..].split(" ").at(20).to_i
    # 50 idle threads reserve address space without touching memory
    threads = Array.new(50) { Thread.new { sleep } }
    grown = File.read("/proc/self/stat")
    grown_vsize = grown[(grown.rindex(")") + 2)..].split(" ").at(20).to_i
    assert_operator(grown_vsize - vsize, :>, 100 * 2**20, "vsize should grow with threads")
    assert_operator(ODDB::App.resident_bytes, :<, grown_vsize / 2)
  ensure
    threads&.each(&:kill)
  end
end
