#!/usr/bin/env ruby

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "tmpdir"
require "util/price_archives"

class TestPriceArchives < Minitest::Test
  Price = Struct.new(:amount, :valid_from, :authority) do
    include Comparable
    def <=>(other) = amount <=> other.amount
    def -(other) = amount - other.amount
    def to_f = amount.to_f
    def to_s = format("%.2f", amount)
  end

  def package(name, *prices)
    pack = flexmock(name)
    pack.should_receive(:price_public).and_return { |i| prices[i || 0] }
    pack.should_receive(:name).and_return(name)
    pack.should_receive(:size).and_return("30 Tabletten")
    pack.should_receive(:iksnr).and_return("12345")
    pack.should_receive(:seqnr).and_return("01")
    pack.should_receive(:ikscd).and_return("001")
    pack
  end

  def setup
    @root = Dir.mktmpdir("price_archives")
    %w[de fr].each { |l| Dir.mkdir(File.join(@root, l)) }
    oct = Time.local(2026, 10, 1)
    sep = Time.local(2026, 9, 1)
    packs = [
      # newest first, as Package#price_public(index) hands them out
      package("Cut", Price.new(8.0, oct, :sl), Price.new(10.0, sep, :sl)),
      package("Rise", Price.new(12.0, oct, :sl), Price.new(10.0, Time.local(2020, 1, 1), :sl)),
      package("New", Price.new(5.0, oct, :sl)),
      package("NotSl", Price.new(5.0, oct, :lppv)),
      package("Empty")
    ]
    app = flexmock("app")
    app.should_receive(:each_package).and_return { |&block| packs.each(&block) }
    @archives = ODDB::PriceArchives.new(app, root: @root)
  end

  def teardown
    FileUtils.rm_rf(@root)
  end

  def test_collect_sorts_changes_into_kind_and_month
    buckets = @archives.collect
    assert_equal(%w[Cut], buckets[:price_cut]["2026-10"].map { |e| e[:name] })
    assert_equal(%w[Rise], buckets[:price_rise]["2026-10"].map { |e| e[:name] })
    # the first price of an SL pack is an introduction, in its own month
    assert_equal(%w[New], buckets[:sl_introduction]["2026-10"].map { |e| e[:name] })
    assert_equal(%w[Cut], buckets[:sl_introduction]["2026-09"].map { |e| e[:name] })
    assert_equal(%w[Rise], buckets[:sl_introduction]["2020-01"].map { |e| e[:name] })
    assert_in_delta(-20.0, buckets[:price_cut]["2026-10"].first[:percent])
    assert_equal(5, @archives.packs)
  end

  def test_collect_can_be_limited_to_months
    buckets = @archives.collect(months: ["2026-10"])
    assert_equal(["2026-10"], buckets.values.flat_map(&:keys).uniq)
    assert_equal(3, @archives.changes)
  end

  def test_write_puts_one_file_per_kind_month_and_language
    written = @archives.write(@archives.collect(months: ["2026-10"]))
    assert_equal(6, written)
    text = File.read(File.join(@root, "de", "price_cut-2026-10.rss"))
    assert_match(%r{<title>01\.10\.2026: Cut, 30 Tabletten, 8\.00, -20\.0%</title>}, text)
    assert_match(%r{/show/reg/12345/seq/01/pack/001</link>}, text)
    # every language gets the same local date; Time#utc used to shift the
    # second directory written into the previous day
    %w[de fr].each { |lang|
      assert_match(/<title>01\.10\.2026: Cut/, File.read(File.join(@root, lang, "price_cut-2026-10.rss")), lang)
    }
    assert(File.exist?(File.join(@root, "fr", "sl_introduction-2026-10.rss")))
    refute(File.exist?(File.join(@root, "de", "price_cut-2026-09.rss")))
  end
end
