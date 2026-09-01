#!/usr/bin/env ruby

# ODDB::TestDeregistrationDates -- oddb.org -- 01.09.2026
#
# Die tragende Zusicherung: das Datum kommt aus dem ersten Swissmedic-
# Schnappschuss, in dem die Registrierung fehlt - nicht aus dem Tag, an
# dem jemand aufgeraeumt hat. Genau daran ist der 27.09.2017 gescheitert,
# als ein einmaliger Job 2089 Registrierungen mit `inactive_date = today`
# stempelte; Cardiolite war da schon 1318 Tage weg.

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "date"
require "util/deregistration_dates"

module ODDB
  class TestDeregistrationDates < Minitest::Test
    DATES = [Date.new(2014, 1, 23), Date.new(2014, 2, 17), Date.new(2014, 6, 12),
      Date.new(2026, 8, 6)].freeze

    def setup
      # 00450 zuletzt am 17.02.2014 gesehen, 00999 steht noch in der
      # neuesten Liste.
      @index = {"00450" => Date.new(2014, 2, 17), "00999" => Date.new(2026, 8, 6)}
    end

    def fixer(apply: false)
      DeregistrationDates.new(@index, DATES, apply: apply)
    end

    def registration(opts = {})
      reg = flexmock("registration")
      reg.should_receive(:iksnr).and_return(opts.fetch(:iksnr, "00450"))
      reg.should_receive(:inactive?).and_return(opts.fetch(:inactive, true))
      reg.should_receive(:manual_inactive_date).and_return(opts[:manual])
      reg.should_receive(:inactive_date).and_return(opts.fetch(:current, Date.new(2017, 9, 27)))
      reg
    end

    # Der erste Snapshot NACH dem letzten Auftritt - bis dahin war sie da,
    # dort nicht mehr.
    def test_the_date_is_the_first_snapshot_that_misses_it
      assert_equal(Date.new(2014, 6, 12), fixer.deregistered_on("00450"))
    end

    def test_a_registration_still_listed_has_no_date
      assert_nil(fixer.deregistered_on("00999"))
    end

    def test_a_registration_never_listed_has_no_date
      assert_nil(fixer.deregistered_on("12345"))
    end

    # Der Produktionsfall: 2017-09-27 gegen 2014-06-12.
    def test_the_cleanup_day_is_replaced_by_the_measured_day
      reg = registration
      reg.should_receive(:inactive_date=).with(Date.new(2014, 6, 12)).once
      reg.should_receive(:odba_isolated_store).once
      f = fixer(apply: true)
      assert_equal(Date.new(2014, 6, 12), f.examine(reg))
      assert_equal(1, f.counts[:korrigiert])
    end

    def test_a_dry_run_counts_but_does_not_write
      reg = registration
      reg.should_receive(:inactive_date=).never
      reg.should_receive(:odba_isolated_store).never
      f = fixer
      f.examine(reg)
      assert_equal(1, f.counts[:korrigiert])
    end

    # Innerhalb des Monatsrasters der Listen ist nichts zu korrigieren.
    def test_a_date_within_tolerance_is_left_alone
      f = fixer(apply: true)
      f.examine(registration(current: Date.new(2014, 7, 1)))
      assert_equal(1, f.counts[:stimmt])
      assert_equal(0, f.counts[:korrigiert])
    end

    # Ein frueheres Datum heisst, jemand wusste mehr als die Liste.
    def test_a_date_earlier_than_the_evidence_is_left_alone
      f = fixer(apply: true)
      f.examine(registration(current: Date.new(2014, 1, 30)))
      assert_equal(1, f.counts[:frueher_als_beleg])
    end

    # Von Hand gesetzt ist eine Entscheidung, keine Messung.
    def test_a_manual_date_is_never_touched
      f = fixer(apply: true)
      f.examine(registration(manual: Date.new(2020, 1, 1)))
      assert_equal(1, f.counts[:manuell])
    end

    def test_an_active_registration_is_skipped
      f = fixer(apply: true)
      f.examine(registration(inactive: false))
      assert_equal(1, f.counts[:aktiv])
    end

    def test_a_registration_that_vanished_before_2014_is_skipped
      f = fixer(apply: true)
      f.examine(registration(iksnr: "12345"))
      assert_equal(1, f.counts[:nicht_datierbar])
    end

    def test_the_snapshot_date_comes_from_the_file_name
      assert_equal(Date.new(2026, 8, 6),
        DeregistrationDates.date_of("data/xls/Packungen-2026.08.06.xlsx"))
      assert_nil(DeregistrationDates.date_of("data/xls/Packungen-latest.xlsx"))
    end

    # Die IKSNR steht in der Datei als blanke Zahl - `00450` als `450`.
    # Ohne das Auffuellen findet man die 199 Registrierungen mit fuehrender
    # Null nicht wieder.
    def test_leading_zeros_are_restored
      path = File.expand_path("../data/xls/Packungen-latest.xlsx", File.dirname(__FILE__))
      skip "keine Fixture" unless File.exist?(path)
      iksnrs = DeregistrationDates.iksnrs_in(path)
      refute_empty(iksnrs)
      assert(iksnrs.all? { |n| n.length == 5 },
        "jede IKSNR muss fuenfstellig sein, auch die mit fuehrender Null")
    end
  end
end
