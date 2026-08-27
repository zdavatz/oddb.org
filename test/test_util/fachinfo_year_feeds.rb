#!/usr/bin/env ruby

# ODDB::TestFachinfoYearFeeds -- oddb.org -- 27.08.2026

$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))

require "minitest/autorun"
require "fileutils"
require "tmpdir"
require "date"
require "util/fachinfo_year_feeds"
require "util/rss_reader"

module ODDB
  class TestFachinfoYearFeeds < Minitest::Test
    # Die echten Objekte haengen an ODBA. Hier stehen die drei Eigenschaften,
    # auf die es ankommt: eine Registrierung mit Nummer und Namen, ein
    # Dokument je Sprache und ein change_log mit Zeitpunkten.
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

    class Registration
      attr_reader :iksnr, :name_base
      attr_accessor :fachinfo
      def initialize(iksnr, name_base, fachinfo = nil)
        @iksnr = iksnr
        @name_base = name_base
        @fachinfo = fachinfo
      end
    end

    class Fachinfo
      attr_reader :registrations
      def initialize(registrations, documents)
        @registrations = registrations
        @documents = documents
        registrations.each { |reg| reg.fachinfo ||= self }
      end

      def de
        @documents["de"]
      end

      def fr
        @documents["fr"]
      end

      def odba_id
        nil
      end
    end

    class App
      attr_reader :sorted_fachinfos
      def initialize(fachinfos)
        @sorted_fachinfos = fachinfos
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

    def build(fachinfos)
      FachinfoYearFeeds.new(App.new(fachinfos), root: @dir)
    end

    def fachinfo(iksnr, name, de: [], fr: [])
      Fachinfo.new([Registration.new(iksnr, name)],
        {"de" => Document.new(de), "fr" => Document.new(fr)})
    end

    # Der Kern: ein Dokument, das dreimal geaendert wurde, gehoert in drei
    # Jahre. Die alte Fassung stellte es nach seiner letzten Revision in
    # genau eines und liess die anderen leer.
    def test_one_document_reaches_every_year_it_changed_in
      fi = fachinfo("12345", "Lucentis",
        de: [Date.new(2017, 4, 19), Date.new(2018, 1, 26), Date.new(2019, 12, 20)])
      buckets = build([fi]).collect
      assert_equal([2017, 2018, 2019], buckets["de"].keys.sort)
      assert_equal(1, buckets["de"][2017].size)
      assert_equal("Lucentis", buckets["de"][2017].first.name)
      assert_equal("12345", buckets["de"][2017].first.iksnr)
    end

    def test_languages_are_collected_separately
      fi = fachinfo("12345", "Lucentis",
        de: [Date.new(2020, 3, 1)],
        fr: [Date.new(2020, 3, 1), Date.new(2021, 6, 1)])
      buckets = build([fi]).collect
      assert_equal([2020], buckets["de"].keys)
      assert_equal([2020, 2021], buckets["fr"].keys.sort)
    end

    # Zwei Aenderungen am selben Tag ergeben eine Zeile: der Diff wird ueber
    # das Datum adressiert, zwei Eintraege zeigten auf dieselbe Seite.
    def test_two_changes_on_one_day_are_one_entry
      fi = fachinfo("12345", "Lucentis",
        de: [Date.new(2020, 3, 1), Date.new(2020, 3, 1)])
      assert_equal(1, build([fi]).collect["de"][2020].size)
    end

    def test_a_fachinfo_without_registration_is_skipped
      fi = Fachinfo.new([], {"de" => Document.new([Date.new(2020, 3, 1)]), "fr" => Document.new([])})
      assert_empty(build([fi]).collect)
    end

    # Der englische Feed trug immer schon den deutschen Bestand - eine
    # englische Fachinformation gibt es nicht.
    def test_english_feed_mirrors_the_german_history
      fi = fachinfo("12345", "Lucentis", de: [Date.new(2020, 3, 1)])
      builder = build([fi])
      buckets = builder.collect
      # de und en, nicht fr: die franzoesische Fassung hat sich nicht
      # geaendert, also gibt es dort auch keine Datei fuer das Jahr.
      assert_equal(2, builder.write(buckets, apply: true))
      %w[de en].each { |dir|
        path = File.join(@dir, dir, "fachinfo-2020.rss")
        assert(File.exist?(path), dir)
        assert_equal(1, ODDB::RssReader.new(path, :all).items.size, dir)
      }
      refute(File.exist?(File.join(@dir, "fr", "fachinfo-2020.rss")))
    end

    # Was geschrieben wird, muss der Leser der Seite auch wieder auseinander
    # nehmen koennen - Titel, Datum und die Nummer in ihrer eigenen Spalte.
    def test_the_written_feed_reads_back
      fi = fachinfo("12345", "Lucentis", de: [Date.new(2019, 12, 20), Date.new(2019, 3, 4)])
      builder = build([fi])
      builder.write(builder.collect, apply: true)
      items = ODDB::RssReader.new(File.join(@dir, "de", "fachinfo-2019.rss"), :all).items
      assert_equal(2, items.size)
      # Neueste zuerst.
      assert_equal([20, 4], items.collect { |i| i.date.day })
      assert_equal("Lucentis", items.first.title)
      assert_equal("Swissmedic-Registration 12345", items.first.description)
      assert_match(%r{/de/gcc/show/fachinfo/12345/diff/20\.12\.2019\z}, items.first.link)
    end

    def test_nothing_is_written_without_apply
      fi = fachinfo("12345", "Lucentis", de: [Date.new(2020, 3, 1)])
      builder = build([fi])
      builder.write(builder.collect, apply: false)
      assert_empty(Dir.glob(File.join(@dir, "**", "*.rss")))
    end

    def test_counts
      builder = build([fachinfo("1", "A", de: [Date.new(2020, 1, 1)]),
        fachinfo("2", "B", de: [Date.new(2020, 1, 1)], fr: [Date.new(2021, 1, 1)])])
      builder.collect
      assert_equal(2, builder.counts[:fachinfos])
      assert_equal(3, builder.counts[:entries])
    end
  end
end
