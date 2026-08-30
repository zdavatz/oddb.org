#!/usr/bin/env ruby

# ODDB::TestPatinfoYearFeeds -- oddb.org -- 30.08.2026

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))

require "stub/odba"
require "minitest/autorun"
require "fileutils"
require "tmpdir"
require "date"
require "model/patinfo"
require "util/patinfo_year_feeds"
require "util/rss_reader"

module ODDB
  class TestPatinfoYearFeeds < Minitest::Test
    ChangeLogItem = Struct.new(:time) do
      def odba_id
        nil
      end
    end

    class Document
      attr_reader :change_log
      def initialize(times)
        @change_log = times.collect { |t| ChangeLogItem.new(t) }
      end

      def odba_id
        nil
      end
    end

    # Eine echte Patinfo, damit der Klassentest in each_patinfo greift - der
    # prueft ueber odba_instance und nicht ueber is_a? auf dem Stub.
    class Patinfo < ODDB::Patinfo
      attr_reader :descriptions
      def initialize(documents)
        @descriptions = documents
      end

      def odba_instance
        self
      end

      def odba_id
        object_id
      end
    end

    class Package
      attr_reader :ikscd, :name_base, :patinfo
      def initialize(ikscd, name_base, patinfo)
        @ikscd = ikscd
        @name_base = name_base
        @patinfo = patinfo
      end
    end

    class Sequence
      attr_reader :seqnr, :packages
      def initialize(seqnr, packages)
        @seqnr = seqnr
        @packages = packages.each_with_object({}) { |pac, memo| memo[pac.ikscd] = pac }
      end
    end

    class Registration
      attr_reader :iksnr, :sequences
      def initialize(iksnr, sequences)
        @iksnr = iksnr
        @sequences = sequences.each_with_object({}) { |seq, memo| memo[seq.seqnr] = seq }
      end

      def odba_id
        nil
      end
    end

    class App
      def initialize(registrations)
        @registrations = registrations
      end

      def each_registration(&block)
        @registrations.each(&block)
      end
    end

    def setup
      @dir = Dir.mktmpdir
      super
    end

    def teardown
      FileUtils.rm_rf(@dir)
      super
    end

    def build(registrations)
      PatinfoYearFeeds.new(App.new(registrations), root: @dir)
    end

    def patinfo(de: [], fr: [])
      Patinfo.new({"de" => Document.new(de), "fr" => Document.new(fr)})
    end

    def registration(iksnr, name, seqnr: "01", ikscd: "002", **dates)
      pi = patinfo(**dates)
      Registration.new(iksnr, [Sequence.new(seqnr, [Package.new(ikscd, name, pi)])])
    end

    def test_one_document_reaches_every_year_it_changed_in
      reg = registration("12345", "Dafalgan",
        de: [Date.new(2017, 4, 19), Date.new(2018, 1, 26), Date.new(2019, 12, 20)])
      buckets = build([reg]).collect
      assert_equal([2017, 2018, 2019], buckets["de"].keys.sort)
      assert_equal("Dafalgan", buckets["de"][2017].first.name)
      assert_equal("12345", buckets["de"][2017].first.iksnr)
    end

    # Der Unterschied zur Fachinfo: der Diff wird ueber Registrierung, Sequenz
    # und Packung adressiert, sonst findet Session#choosen_info_diff nichts.
    def test_the_link_carries_sequence_and_package
      reg = registration("56195", "Tramal", seqnr: "01", ikscd: "002",
        de: [Date.new(2019, 12, 20)])
      builder = build([reg])
      builder.write(builder.collect, apply: true)
      items = ODDB::RssReader.new(File.join(@dir, "de", "patinfo-2019.rss"), :all).items
      assert_equal(1, items.size)
      assert_match(%r{/de/gcc/show/patinfo/56195/01/002/diff/20\.12\.2019\z}, items.first.link)
      assert_equal("Swissmedic-Registration 56195", items.first.description)
    end

    # Dieselbe Patinfo haengt an mehreren Packungen - das ist eine Aenderung,
    # nicht zwei. Verlinkt wird ueber die erste gefundene Packung.
    def test_one_patinfo_on_two_packages_is_one_entry
      pi = patinfo(de: [Date.new(2020, 3, 1)])
      reg = Registration.new("12345",
        [Sequence.new("01", [Package.new("001", "Dafalgan", pi),
          Package.new("002", "Dafalgan", pi)])])
      assert_equal(1, build([reg]).collect["de"][2020].size)
    end

    # Ohne franzoesisches Dokument keine franzoesische Geschichte.
    # SimpleLanguage#description faellt auf die erste vorhandene Sprache
    # zurueck; wer ueber #fr fragt, bekaeme den deutschen Text.
    def test_a_missing_language_yields_no_entries
      pi = Patinfo.new({"de" => Document.new([Date.new(2020, 3, 1)])})
      reg = Registration.new("12345", [Sequence.new("01", [Package.new("002", "Dafalgan", pi)])])
      buckets = build([reg]).collect
      assert_equal([2020], buckets["de"].keys)
      assert_nil(buckets["fr"])
    end

    # Eine kaputte Referenz deklariert Patinfo und ist keine. is_a? auf dem
    # Wert antwortete mit ja, odba_instance sagt die Wahrheit.
    def test_a_foreign_object_where_a_patinfo_belongs_is_skipped
      other = Object.new
      def other.odba_instance
        self
      end
      reg = Registration.new("12345", [Sequence.new("01", [Package.new("002", "X", other)])])
      assert_empty(build([reg]).collect)
    end

    def test_english_feed_mirrors_the_german_history
      reg = registration("12345", "Dafalgan", de: [Date.new(2020, 3, 1)])
      builder = build([reg])
      buckets = builder.collect
      assert_equal(2, builder.write(buckets, apply: true))
      %w[de en].each { |dir|
        path = File.join(@dir, dir, "patinfo-2020.rss")
        assert(File.exist?(path), dir)
        assert_equal(1, ODDB::RssReader.new(path, :all).items.size, dir)
      }
      refute(File.exist?(File.join(@dir, "fr", "patinfo-2020.rss")))
    end

    # patinfo.rss neben den Jahresdateien: die HTML-Ansicht liest sie nie,
    # aber der Abonnent-Link auf der Startseite zeigt darauf.
    def test_the_latest_file_holds_the_newest_entries
      reg = registration("12345", "Dafalgan",
        de: [Date.new(2019, 3, 4), Date.new(2020, 3, 1), Date.new(2021, 5, 9)])
      builder = build([reg])
      buckets = builder.collect
      assert_equal(2, builder.write_latest(buckets, apply: true, limit: 2))
      items = ODDB::RssReader.new(File.join(@dir, "de", "patinfo.rss"), :all).items
      assert_equal(["09.05.2021", "01.03.2020"],
        items.collect { |item| item.date.strftime("%d.%m.%Y") })
    end

    def test_latest_reports_the_newest_month
      reg = registration("12345", "Dafalgan",
        de: [Date.new(2026, 8, 3), Date.new(2026, 8, 20), Date.new(2025, 1, 2)])
      builder = build([reg])
      assert_equal([Date.new(2026, 8, 20), 2], builder.latest(builder.collect))
    end

    def test_nothing_is_written_without_apply
      reg = registration("12345", "Dafalgan", de: [Date.new(2020, 3, 1)])
      builder = build([reg])
      buckets = builder.collect
      builder.write(buckets, apply: false)
      builder.write_latest(buckets, apply: false)
      assert_empty(Dir.glob(File.join(@dir, "**", "*.rss")))
    end

    def test_counts
      builder = build([registration("1", "A", de: [Date.new(2020, 1, 1)]),
        registration("2", "B", de: [Date.new(2020, 1, 1)], fr: [Date.new(2021, 1, 1)])])
      builder.collect
      assert_equal(2, builder.counts[:patinfos])
      assert_equal(3, builder.counts[:entries])
    end
  end
end
